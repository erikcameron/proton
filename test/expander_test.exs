defmodule ProtonTest.Expander do
  use ExUnit.Case
  doctest Proton.Expander
  alias Proton.Expander
  alias Proton.Errors.{PrototypeRegress, InvalidPrototypeType}

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


  def resolver(path) when is_binary(path), do: @repo[String.to_atom(path)]

  test "leaves map literals alone" do
    assert Expander.expand("literal", &resolver/1) == {:ok, [resolver("literal")]}
  end

  test "everything is lists of maps" do
    assert Expander.expand!("this_node", &resolver/1)
    |> List.flatten
    |> Enum.map(fn proto -> is_map(proto) end)
    |> Enum.reduce(fn p, q -> p && q end)
  end

  test "expands prototypes as expected" do
    assert Expander.expand!("this_node", &resolver/1) == [[[%{p: 3}], %{p: 1}], [%{p: 2}], %{local: "data"}]
  end

  test "blows up on infinite regress" do
    assert_raise PrototypeRegress, fn -> Expander.expand!("regress", &resolver/1) end
  end

  test "blows up on invalid prototype" do
    assert_raise InvalidPrototypeType, fn -> Expander.expand!("invalid", &resolver/1) end
  end
end
