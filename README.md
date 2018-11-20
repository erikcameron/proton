# Proton

A tool for data structure reuse. Or something. Easier to just illustrate.
Suppose you need some relatively complex map, say as a slice of application
state:

```
pizza = %{
  size: "large",
  verticality: "deep",
  crust: "cornmeal",
  sauce: "tomato",
  toppings: [
    %{name: "spinach", extra: 0},
    %{name: "giardiniera", spiciness: "hot", half: "left"}
  ],
  order: %{
    type: "pickup",
    placed_at: "19:30PM CST"
    customer: "Erik"
  }
```

Suppose you want to specify a bunch of these that share many things
but also diverge in many particulars. Rather than writing that sort
of thing over and over, it would be easier and more resistant to 
errors and the ravages of time if you could just do this:

```
%{
  protos: ["large_spinach_deep_dish", "cornmeal_crust"]
  toppings: ["spinach"
    
     


##

To do:
  - `proton_test`, esp. children nodes 
  - documentation updates
  - ...

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `proton` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:proton, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/proton](https://hexdocs.pm/proton).

