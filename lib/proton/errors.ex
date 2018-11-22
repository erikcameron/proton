defmodule Proton.Errors do
  defmodule PrototypeRegress, do: defexception message: "can't prototype self"
  defmodule InvalidPrototypeType, do: defexception message: "prototype must be either a map or a string"
  defmodule CheckFailed, do: defexception message: "check failed", spec: %{}, errors: []
  defmodule SpecNotFound, do: defexception message: "spec not found"
end

