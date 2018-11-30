defmodule Proton do
  @moduledoc """
  """

  import Proton.Expander, only: [expand: 2]
  import Proton.Merger, only: [smart_merge: 2]

  def build(path, finder, options \\ [])
  def build(literal, _, _) when is_map(literal), do: literal
  def build(path, finder, options) when is_function(finder) do
    with {:ok, expanded_protos } <- expand(path, finder),
      {:ok, unfiltered_spec } <- merge_protos(expanded_protos),
      {:ok, filtered_spec} <- filter(unfiltered_spec, options[:filter]),
      {:ok, checked_spec} <- check(filtered_spec, options[:check])
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

  defp filter(%{} = spec, filter) when is_nil(filter), do: {:ok, spec}
  defp filter(%{} = spec, filter) when is_function(filter), do: filter.(spec)

  defp check(%{} = spec, checker) when is_nil(checker), do: {:ok, spec}
  defp check(%{} = spec, checker) when is_function(checker), do: checker.(spec)
end
