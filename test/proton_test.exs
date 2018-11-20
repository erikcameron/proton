defmodule ProtonTest do
  use ExUnit.Case
  doctest Proton


  defmodule MapSource do
    @behaviour Proton.Source
    @map_argument %{foo: "bar"}

    def map_argument, do: @map_argument
    def resolve(_), do: %{}
  end

  test "returns first arg unchanged when first arg is a map" do
    assert Proton.build(MapSource.map_argument, MapSource) == MapSource.map_argument
  end

  defmodule BasicSource do
    @behaviour Proton.Source
    @repo %{ 
      local_node: %{
        local_value: "local",
        some_list: ["local"],
        protos: ["a", "b", "c"],
        over: 1
      },
      a: %{some_list: ["a"], over: 2},
      b: %{some_list: ["b"], over: 3},
      c: %{some_list: ["c"], protos: ["d"], over: 4},
      d: %{some_list: ["d"], over: 5}
          
    }
    def resolve(path), do: @repo[String.to_atom(path)]
  end

  test "expands/merges prototypes" do
    {:ok, spec} = Proton.build("local_node", BasicSource)
    assert spec[:some_list] == ["a", "b", "d", "c", "local"]
  end


  defmodule ChildSource do
    @behaviour Proton.Source
  end

  test "expands/merges children"



  test "filters results when a filter is given and no checker"
  test "checks results when a checker is given and no filter"
  test "filters and checks when both are given"
  test "allows filter to bail by returning an error tuple" 
  test "allows checker to bail by returning an error tuple" 
end
