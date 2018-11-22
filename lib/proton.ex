defmodule Proton do
  @moduledoc """
  """

  import Proton.Expander, only: [expand: 2]
  import Proton.Merger, only: [smart_merge: 2]

  def build(literal, _) when is_map(literal), do: literal
  def build(path, source) do
    with {:ok, expanded_protos } <- expand(path, &source.find!/1),
      {:ok, unfiltered_spec } <- merge_protos(expanded_protos),
      {:ok, filtered_spec} <- filter(unfiltered_spec, source),
      {:ok, checked_spec} <- check(filtered_spec, source)
    do
      {:ok, checked_spec}
    else
      {:error, error} -> {:error, error}
    end
  end

  def build!(path, source) do
    case build(path, source) do
      {:ok, spec} -> spec
      {:error, error} -> raise error
    end
  end

  defp merge_protos(protos) do
    merged_protos = protos
    |> List.flatten
    |> Enum.reverse
    |> List.foldl(%{}, &smart_merge/2)
    {:ok, merged_protos}
  end

  defp filter(spec, source) do
    case Kernel.function_exported?(source, :filter, 1) do
      true -> source.filter(spec)
      false -> {:ok, spec}
    end
  end

  defp check(spec, source) do
    case Kernel.function_exported?(source, :check, 1) do
      true -> source.check(spec)
      false -> {:ok, spec}
    end
  end
end
