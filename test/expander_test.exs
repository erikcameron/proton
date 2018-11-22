defmodule ProtonTest.Expander do
  use ExUnit.Case
  doctest Proton.Expander
  alias Proton.Expander
  alias Proton.Errors.{
    PrototypeRegress, 
    InvalidPrototypeType, 
    SpecNotFound
  }

  @repo %{
    literal: %{just_a: "regular ole map"},
    this_node: %{
      protos: ["proto1", "proto2"],
      local: "data"
    },
    proto1: %{protos: ["proto3"], p: 1},
    proto2: %{p: 2},
    proto3: %{p: 3},
    regress: %{protos: ["proto4"]},
    proto4: %{protos: ["proto5"]},
    proto5: %{protos: ["regress"]},
    invalid: %{protos: [1, 2, 3]}
  }

  def find!(path) when is_binary(path), do: @repo[String.to_atom(path)]

  test "leaves map literals alone" do
    assert Expander.expand("literal", &find!/1) == {:ok, [find!("literal")]}
  end

  test "converts nil finder return to empty list" do
    assert {:ok, []} == Expander.expand("foo", fn _ -> nil end)
  end

  test "blows up on finder returns other than spec or nil" do
    assert_raise(CaseClauseError, fn -> Expander.expand!("foo", fn _ -> "oops" end) end)
  end

  def doomed_find!(_), do: raise SpecNotFound
  test "returns error tuple on finder meltdown" do
    {:error, error} = Expander.expand("foo", &doomed_find!/1)
    assert %SpecNotFound{} = error
  end

  test "everything is lists of maps" do
    assert Expander.expand!("this_node", &find!/1)
    |> List.flatten
    |> Enum.map(fn proto -> is_map(proto) end)
    |> Enum.reduce(fn p, q -> p && q end)
  end

  test "expands prototypes as expected" do
    assert Expander.expand!("this_node", &find!/1) == [[[%{p: 3}], %{p: 1}], [%{p: 2}], %{local: "data"}]
  end

  test "blows up on infinite regress" do
    assert_raise PrototypeRegress, fn -> Expander.expand!("regress", &find!/1) end
  end

  test "blows up on invalid prototype" do
    assert_raise InvalidPrototypeType, fn -> Expander.expand!("invalid", &find!/1) end
  end
end
