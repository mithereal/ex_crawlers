# ExCrawlers

**Crawly examples of scraping websites, results are stored via cachex**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_crawlers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_crawlers, "~> 0.1.0"}
  ]
end

```

```elixir
ExCrawlers.run(:allbud)
Cachex.get(:spiders, :allbud)
Cachex.export(:spiders)
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_crawlers>.

