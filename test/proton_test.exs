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
    def resolve({_, handle}), do: @repo[String.to_atom(handle)]
  end

  test "expands/merges prototypes" do
    {:ok, spec} = Proton.build({nil, "local_node"}, BasicSource)
    assert spec[:some_list] == ["a", "b", "d", "c", "local"]
  end


  defmodule ChildSource do
    @behaviour Proton.Source

    @repo %{
      nodes: %{
        local: %{tags: ["foo", "bar"]}
      },
      tags: %{
        foo: %{tag_attr: "foo", protos: ["baz"]},
        bar: %{tag_attr: "bar"},
        baz: %{tag_attr: "baz"}
      }
    }
    
    def children(_), do: ["tags"]
    def resolve({kind, handle}), do: @repo[Strieg.to_atom(kind)][String.to_atom(handle)]
  end

  test "expands/merges children" do
    {:ok, spec} = Proton.build({"nodes", "local"}, ChildSource)
    assert spec[:tags] == "foo"
  end



  test "filters results when a filter is given and no checker"
  test "checks results when a checker is given and no filter"

  test "filters and checks when both are given"
  test "allows filter to bail by returning an error tuple" 
  test "allows checker to bail by returning an error tuple" 
end
