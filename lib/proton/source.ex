defmodule Proton.Source do
  @moduledoc """
  Behaviour for calling applications to implement
  in order to use Proton. 
  """

  alias Proton.Errors.CheckFailed

  @type path :: String.t
  @type spec :: map()

  @callback resolve(path) :: spec
  @callback children() :: [atom]
  @callback filter(spec) :: spec
  @callback checker(spec) :: {:ok, spec} | {:error, %CheckFailed{}}
  @optional_callbacks children: 0, filter: 1, checker: 1
end
