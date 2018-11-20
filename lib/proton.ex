defmodule Proton do
  @moduledoc """
  """

  import Proton.Expander, only: [expand: 2]
  import Proton.Merger, only: [smart_merge: 2]

  def build(literal, _) when is_map(literal), do: literal
  def build(path, source) when is_binary(path) do
    with {:ok, first_pass_sources } <- expand(path, &source.resolve/1),
      {:ok, first_pass_merged } <- merge_sources(first_pass_sources),
      {:ok, fully_merged } <- build_children(first_pass_merged, source), 
      {:ok, filtered} <- filter(fully_merged, source),
      {:ok, checked} <- check(filtered, source)
    do
      {:ok, checked}
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

  defp merge_sources(sources) do
    merged_sources = sources
    |> List.flatten
    |> Enum.reverse
    |> List.foldl(%{}, &smart_merge/2)
    {:ok, merged_sources}
  end

  defp build_children(spec, source) do
    for f <- child_fields(source), is_list(spec[f]), into: spec do
      {f, Enum.map(spec[f], fn child -> build(child, f) end)}
    end
    {:ok, spec}
  end

  defp child_fields(source) do
    case Kernel.function_exported?(source, :children, 0) do
      true -> source.children
      false -> []
    end
  end


  defp filter(spec, source) do
    case Kernel.function_exported?(source, :filter, 1) do
      true -> source.filter(spec)
      false -> {:ok, spec}
    end
  end

  defp check(spec, source) do
    case Kernel.function_exported?(source, :checker, 1) do
      true -> source.checker(spec)
      false -> {:ok, spec}
    end
  end
end
