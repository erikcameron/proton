defmodule ProtonTest.Merger do
  use ExUnit.Case
  doctest Proton.Merger
  alias Proton.Merger

  test "merges two maps with no conflicts" do
    m1 = %{a: 1, b: 2}
    m2 = %{c: 3, d: 4}
    merged = Merger.smart_merge(m1, m2)
    assert merged[:a] == 1 and merged[:d] == 4
  end

  test "prefers incoming value on type mismatch" do
    m1 = %{a: [1, 2, 3]}
    m2 = %{a: "a string"}
    assert Merger.smart_merge(m1, m2)[:a] == "a string"
  end

  test "returns incoming map on top level clobber (and declobbers)" do
    m1 = %{foo: "bar"}
    m2 = %{_clobber!: true}
    assert Merger.smart_merge(m1, m2) == %{}
  end

  test "merges two maps which conflict on top-level scalar values" do
    m1 = %{a: "foo"}
    m2 = %{a: "bar"}
    assert Merger.smart_merge(m1, m2)[:a] == "bar"
  end
    
  test "merges two maps which conflict on top-level list values" do
    m1 = %{a: [1, 2, 3], b: "bee"}
    m2 = %{a: [4], c: "cee"}
    merged = Merger.smart_merge(m1, m2) 
    assert merged[:a] == [1, 2, 3, 4]
      and merged[:b] == "bee"
      and merged[:c] == "cee"
  end 

  test "merges two maps which conflict on top-level map values" do
    m1 = %{a: %{foo: "bar", baz: "quux"}, b: "bee"}
    m2 = %{a: %{narf: "ok", foo: "updated"}, c: "cee"}
    merged = Merger.smart_merge(m1, m2) 
    assert merged[:a][:foo] == "updated" 
      and merged[:a][:baz]  == "quux"
      and merged[:a][:narf] == "ok"
      and merged[:b] == "bee"
      and merged[:c] == "cee"
  end

  test "merges two maps which conflict on top-level clobbering list values" do
    m1 = %{a: [1, 2, 3], b: "bee"}
    m2 = %{a: [:_clobber!, 4], c: "cee"}
    merged = Merger.smart_merge(m1, m2) 
    assert merged[:a] == [4]
      and merged[:b] == "bee"
      and merged[:c] == "cee"
  end 

  test "merges two maps which conflict on top-level clobbering map values" do
    m1 = %{a: %{foo: "bar", baz: "quux"}, b: "bee"}
    m2 = %{a: %{foo: "updated", _clobber!: true}, c: "cee"}
    merged = Merger.smart_merge(m1, m2) 
    assert merged[:a] == %{foo: "updated"}
      and merged[:b] == "bee"
      and merged[:c] == "cee"
  end

  test "merges two maps which conflict on nested scalar values" do
    m1 = %{outer: %{inner: "orig", i1: "eye one"}, o1: "oh one"}
    m2 = %{outer: %{inner: "updated", i2: "eye two"}, o2: "oh two"}
    merged = Merger.smart_merge(m1, m2)
    assert merged[:outer][:inner] == "updated"
      and merged[:outer][:i1] == "eye one"
      and merged[:outer][:i2] == "eye two"
      and merged[:o1] == "oh one"
      and merged[:o2] == "oh two"
  end

  test "merges two maps which conflict on nested list values" do
    m1 = %{outer: %{inner: [1, 2, 3], i1: "eye one"}, o1: "oh one"}
    m2 = %{outer: %{inner: [4], i2: "eye two"}, o2: "oh two"}
    merged = Merger.smart_merge(m1, m2)
    assert merged[:outer][:inner] == [1, 2, 3, 4]
      and merged[:outer][:i1] == "eye one"
      and merged[:outer][:i2] == "eye two"
      and merged[:o1] == "oh one"
      and merged[:o2] == "oh two"
  end

  test "merges two maps which conflict on nested map values" do 
    m1 = %{outer: %{inner: %{value: "orig", canary: "tweet"}, i1: "eye one"}, o1: "oh one"}
    m2 = %{outer: %{inner: %{value: "updated"}, i2: "eye two"}, o2: "oh two"}
    merged = Merger.smart_merge(m1, m2)
    assert merged[:outer][:inner][:value] == "updated"
      and merged[:outer][:inner][:canary] == "tweet"
      and merged[:outer][:i1] == "eye one"
      and merged[:outer][:i2] == "eye two"
      and merged[:o1] == "oh one"
      and merged[:o2] == "oh two"
  end

  test "merges two maps which conflict on nested clobbering list values (and declobbers)" do
    m1 = %{outer: %{inner: [1, 2, 3], i1: "eye one"}, o1: "oh one"}
    m2 = %{outer: %{inner: [:_clobber!, 4], i2: "eye two"}, o2: "oh two"}
    merged = Merger.smart_merge(m1, m2)
    assert merged[:outer][:inner] == [4]
      and merged[:outer][:i1] == "eye one"
      and merged[:outer][:i2] == "eye two"
      and merged[:o1] == "oh one"
      and merged[:o2] == "oh two"
  end

  test "merges two maps which conflict on nested clobbering map values (and declobbers)" do
    m1 = %{outer: %{inner: %{value: "orig"}, i1: "eye one"}, o1: "oh one"}
    m2 = %{outer: %{inner: %{_clobber!: true}, i2: "eye two"}, o2: "oh two"}
    merged = Merger.smart_merge(m1, m2)
    assert merged[:outer][:inner] == %{}
      and merged[:outer][:i1] == "eye one"
      and merged[:outer][:i2] == "eye two"
      and merged[:o1] == "oh one"
      and merged[:o2] == "oh two"
  end
end
