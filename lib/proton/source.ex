defmodule Proton.Source do
  @moduledoc """
  Behaviour for calling applications to implement
  in order to use Proton. 
  """

  alias Proton.Errors.CheckFailed

  @type kind   :: String.t
  @type handle :: String.t
  @type child  :: kind
  @type path   :: {kind, handle}
  @type spec   :: map()

  @callback resolve(path)   :: spec
  @callback children(kind)  :: [child]
  @callback filter(spec)    :: spec
  @callback checker(spec)   :: {:ok, spec} | {:error, %CheckFailed{}}
  @optional_callbacks children: 1, filter: 1, checker: 1
end
