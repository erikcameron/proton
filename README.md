# Proton

A tool for data structure reuse. Or something. Easier to just illustrate.
Suppose you need some relatively complex map, say as a slice of application
state:

```elixir
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

```elixir
%{
  protos: ["spinach_deep_dish", "size_large", "cornmeal_crust"]
  toppings: ["spinach", "giardiniera"]
  order: %{
    type: "pickup",
    placed_at: "19:30PM CST"
    customer: "Erik"
  }
}
```

Here `protos` is shorthand for "prototypes": i.e., data that we 
want to pull in, include, etc. Proton will expand those names into
actual maps, (along with any prototypes _they_ specify) flatten the
list, and merge them into a single data structure for you. The benefits
are:

- Encapsulation: The first example above, where the pizza order is
given as one big map literal, exposes the implementation of your
pizza machinery because it exposes the raw data it consumes. What if
you want to change formats, definitions, etc.?

- DRY: You probably sell a lot of deep dish spinach pizzas, and 
don't want to have to write it out each time.

- Extension/recombination: For all you know, `"spinach_deep_dish"` 
resolves to `["spinach", "deep_dish"]`
    
And so on. Stay tuned for more examples from real world use.

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

