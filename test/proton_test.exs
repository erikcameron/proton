defmodule ProtonTest do
  use ExUnit.Case
  doctest Proton

  test "returns first arg unchanged when first arg is a map" do
    assert Proton.build(%{foo: "bar"}, fn _ -> nil end) == %{foo: "bar"}
  end

  alias Proton.Errors.SpecNotFound

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
    
    def find!(path) do
      case @repo[String.to_atom(path)] do
        spec when is_map(spec) -> spec
        _ -> raise %SpecNotFound{message: Kernel.inspect(path)}
      end
    end
  end

  test "expands/merges prototypes" do
    {:ok, spec} = Proton.build("local_node", &BasicSource.find!/1)
    assert spec[:some_list] == ["a", "b", "d", "c", "local"]
  end

  test "bang version returns bare spec on success" do
    spec = Proton.build!("local_node", &BasicSource.find!/1)
    assert spec[:some_list] == ["a", "b", "d", "c", "local"]
  end

  test "bang version raises given error on failure" do 
    assert_raise(SpecNotFound, fn -> Proton.build!("foo", &BasicSource.find!/1) end)
  end
     


  defmodule FilterSource do 
    @behaviour Proton.Source

    def find!(path), do: BasicSource.find!(path)
    def filter(_), do: {:ok, %{filtered: true}}
  end      

  test "filters results when a filter is given and no checker" do
    {:ok, spec} = Proton.build(
      "local_node", 
      &FilterSource.find!/1, 
      filter: &FilterSource.filter/1
    )
    assert spec == %{filtered: true}
  end



  defmodule CheckSource do
    @behaviour Proton.Source
    
    def find!(path), do: BasicSource.find!(path)
    def check(_), do: {:ok, %{checked: true}}
  end

  test "checks results when a checker is given and no filter" do
    {:ok, spec} = Proton.build(
      "local_node", &CheckSource.find!/1, 
      check: &CheckSource.check/1
    )
    assert spec == %{checked: true}
  end



  defmodule FilterCheckSource do
    @behaviour Proton.Source
    
    def find!(path), do: BasicSource.find!(path)
    def filter(spec), do: {:ok, Map.merge(spec, %{filtered: true})}
    def check(spec), do: {:ok, Map.merge(spec, %{checked: true})}
  end

  test "filters and checks when both are given" do
    {:ok, spec} = Proton.build(
      "local_node", 
      &FilterCheckSource.find!/1, 
      filter: &FilterCheckSource.filter/1, 
      check: &FilterCheckSource.check/1
    )
    assert spec[:filtered] == true and spec[:checked] == true
  end



  defmodule BadFilterSource do
    @behaviour Proton.Source

    def find!(path), do: BasicSource.find!(path)
    def filter(_), do: {:error, "clogged filter"}
  end

  test "allows filter to bail by returning an error tuple" do
    {:error, reason} = Proton.build(
      "local_node", 
      &BadFilterSource.find!/1, 
      filter: &BadFilterSource.filter/1
    )
    assert reason == "clogged filter"
  end



  defmodule BadCheckSource do
    @behaviour Proton.Source

    def find!(path), do: BasicSource.find!(path)
    def check(_), do: {:error, "check bounced"}
  end

  test "allows checker to bail by returning an error tuple" do
    {:error, reason} = Proton.build(
      "local_node", 
      &BadCheckSource.find!/1, 
      check: &BadCheckSource.check/1
    )
    assert reason == "check bounced"
  end



  alias Proton.Errors.CheckFailed

  defmodule CheckFailedWithErrorsSource do
    @behaviour Proton.Source

    def find!(path), do: BasicSource.find!(path)
    def check(_), do: {:error, %CheckFailed{errors: error_list()}}
    
    def error_list do
      ["field 1 is too short", "field 2 is too long"]
    end
  end

  test "CheckFailed error allows individual errors to be attached" do
    {:error, %CheckFailed{} = reason} = Proton.build(
      "local_node", 
      &CheckFailedWithErrorsSource.find!/1, 
      check: &CheckFailedWithErrorsSource.check/1
    )
    assert reason.errors == CheckFailedWithErrorsSource.error_list()
  end
end
