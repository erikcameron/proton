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
  - resolver: A function from a path to that node's spec data; this abstracts
    both the type of the node (which is necessary knowledge for parsing its
    path) and the actual, material cache itself.
  - current_paths: a list of the paths we are currently expanding; we prevent
    infinite loops by bailing if our own path is included here. 
  """
  def expand(path, resolver, current_paths \\ []) do
    {:ok, _expand!(path, resolver, current_paths)}
  rescue
    error -> {:error, error}
  end

  def expand!(path, resolver, current_paths \\ []) do
    case expand(path, resolver, current_paths) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  defp _expand!(path, resolver, current_paths) do
    {kind, handle} = path
    case Enum.member?(current_paths, path) do
      true ->  
        raise PrototypeRegress, message: "#{handle} (#{kind})"
      false ->
        Enum.map(proto_list(resolver.(path)), fn p -> 
          case p do
            p when is_map(p) -> p
            p when is_binary(p) -> _expand!({kind, p}, resolver, [path | current_paths])
            _ -> raise InvalidPrototypeType, message: inspect(p)
          end
      end)
    end
  end

  defp proto_list(spec) do
    listed_protos = spec[:protos] || []
    local_data    = Map.delete(spec, :protos)
    listed_protos ++ [local_data]
  end
end
