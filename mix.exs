defmodule Simhash.Mixfile do
  use Mix.Project

  def project do
    [app: :simhash,
     version: "0.1.0",
     elixir: "~> 1.2",
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :siphash]]
  end

  def package do
    %{
      files: ["lib", "mix.exs", "README.md"],
      links: %{"GitHub" => "https://github.com/UniversalAvenue/simhash",
               "Docs" => "https://hexdocs.pm/simhash"},
      licenses: [ "MIT" ],
      maintainers: [ "Universal Avenue" ]
    }
  end

  defp description do
    """
    Simhash implementation using Siphash and N-grams.
    """
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:siphash, "~> 3.1.1"},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end
end
