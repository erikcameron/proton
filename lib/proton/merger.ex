defmodule Proton.Merger do
  @moduledoc """
  Functions for merging spec data (which are maps) intelligently.
  """
  
  @clobber_key :_clobber!

  @doc """
  Merge spec structures intelligently. Strategy: In the cases where
  the old and new versions are maps, either replace the old one
  outright if the clobber option is set, or recursively call
  self on the old and new maps if not; in the cases where the 
  old and new versions are both lists, either replace the old one
  outright if the clobber option is set, or append the incoming
  values to the existing list. In any other case---including cases
  where the value was unset, cases where the two values differ in
  type, or cases where both values are scalars---the old value is
  overwritten.

  The "clobber option": If the first element of a list is the atom `:_clobber!`,
  or if that atom keys a truth-y value in a map, then the option
  is set. Not sure how I feel about this sort of in-band configuration
  in general, but in this case it seems like the best solution, as
  it lets you specify that behavior (or not) on any complex type,
  at any level of nested mapping.  
  """

  def smart_merge(%{} = left, %{} = right) do
    if clobber?(right) do
      declobber(right)
    else
      Map.merge(left, right, &smart_resolve/3)
    end
  end

  defp smart_resolve(_key, left, right) when is_map(left) and is_map(right) do
    if clobber?(right), do: declobber(right), else: smart_merge(left, right)
  end

  defp smart_resolve(_key, left, right) when is_list(left) and is_list(right) do
    if clobber?(right), do: declobber(right), else: left ++ right
  end

  defp smart_resolve(_key, _left, right), do: right

  defp clobber?(incoming) when is_map(incoming) do
    !!incoming[@clobber_key]
  end

  defp clobber?([h | _]), do: h === @clobber_key
  defp clobber?([]), do: false

  defp declobber(incoming) when is_list(incoming) do
    if clobber?(incoming), do: List.delete(incoming, @clobber_key)
  end

  defp declobber(incoming) when is_map(incoming) do
    Map.delete(incoming, @clobber_key)
  end
end
