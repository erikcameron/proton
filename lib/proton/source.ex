defmodule Proton.Source do
  @moduledoc """
  Behaviour for calling applications to implement
  in order to use Proton. 
  """

  @type path  :: any
  @type spec  :: map()
  @type error :: any

  @callback find!(path)  :: spec
  @callback filter(spec) :: {:ok, spec} | {:error, error}
  @callback check(spec)  :: {:ok, spec} | {:error, error}
  @optional_callbacks filter: 1, check: 1
end
