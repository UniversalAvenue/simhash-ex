# Simhash
An Elixir implementation of [Moses Charikar's](http://www.cs.princeton.edu/courses/archive/spring04/cos598B/bib/CharikarEstim.pdf) Simhash.

## Examples

```elixir
iex> Simhash.similarity("Universal Avenue", "Universe Avenue")
0.71875
iex> Simhash.similarity("hocus pocus", "pocus hocus")
0.8125
iex> Simhash.similarity("Sankt Eriksgatan 1", "S:t Eriksgatan 1")
0.8125
iex> Simhash.similarity("Purple flowers", "Green grass")
0.5625
```

By default trigrams (N-gram of size 3) are used as language features, but you can set a different N-gram size:

```elixir
iex> Simhash.similarity("hocus pocus", "pocus hocus", 1)
1.0
iex> Simhash.similarity("Sankt Eriksgatan 1", "S:t Eriksgatan 1", 6)
0.859375
iex> Simhash.similarity("Purple flowers", "Green grass", 6)
0.546875
```

## Installation

The package can be installed as:

1. Add simhash to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:simhash, "~> 0.1.2"}]
end
```

2. Ensure simhash is started before your application:

```elixir
def application do
  [applications: [:simhash]]
end
```
