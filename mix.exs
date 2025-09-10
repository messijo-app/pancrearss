defmodule PancreaRSS.MixProject do
  use Mix.Project

  def project do
    [
      app: :liverss,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        name: :liverss,
        licenses: ["MIT"],
        description: "Stream RSS feeds with this GenServer",
        source_url: "https://github.com/vinibrsl/liverss",
        homepage_url: "https://github.com/vinibrsl/liverss",
        links: %{"GitHub" => "https://github.com/vinibrsl/liverss"}
      ],
      docs: [
        name: "PancreaRSS",
        main: "PancreaRSS",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:inets, :ssl],
      extra_applications: [:logger, :feeder_ex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:feeder_ex, "~> 1.1"},

      {:fast_rss, "~> 0.5.0"},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end
end
