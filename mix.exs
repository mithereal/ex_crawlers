defmodule ExCrawlers.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_crawlers,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExCrawlers.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:crawly, git: "https://github.com/oltarasenko/crawly.git"},
      {:cachex, "> 0.0.0"},
      {:html_query, "~> 1.4"},
      {:tesla, ">= 0.0.0", only: :dev}
      #  {:chroxy, "~> 0.7.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
