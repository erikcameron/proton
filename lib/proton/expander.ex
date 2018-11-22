defmodule Proton.Expander do
  @moduledoc """
  Functions relating to the expansion of references in source specs.
    expand(spec data) -> [specdata, specdata...]
  """

  alias Proton.Errors.PrototypeRegress
  alias Proton.Errors.InvalidPrototypeType

  @doc """
  Convert a node path into a nested list(s) of spec literals (i.e., maps),
  to be flattened/merged elsewhere.

  ## Parameters

  - path: A path to another node of the same type
  - finder: A function from a path to that node's spec data; this abstracts
    both the type of the node (which is necessary knowledge for parsing its
    path) and the actual, material cache itself.
  - current_paths: a list of the paths we are currently expanding; we prevent
    infinite loops by bailing if our own path is included here. 
  """
  def expand(path, finder, current_paths \\ []) do
    {:ok, _expand!(path, finder, current_paths)}
  rescue
    error -> {:error, error}
  end

  def expand!(path, finder, current_paths \\ []) do
    case expand(path, finder, current_paths) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  defp _expand!(path, finder, current_paths) do
    case Enum.member?(current_paths, path) do
      true ->  
        raise PrototypeRegress, message: path
      false ->
        case finder.(path) do
          spec when is_map(spec) -> 
            Enum.map(prototypes(finder.(path)), fn p -> 
              case p do
                p when is_map(p) -> p
                p when is_binary(p) -> _expand!(p, finder, [path | current_paths])
                _ -> raise InvalidPrototypeType, message: inspect(p)
              end
            end)
          silent_not_found when is_nil(silent_not_found) -> []
        end
    end
  end

  defp prototypes(spec) do
    listed_protos = spec[:protos] || []
    local_data    = Map.delete(spec, :protos)
    # yeah, I know ++ is slower, but that's why you
    # compile ahead of time!
    listed_protos ++ [local_data]
  end
end
