defmodule Exql.Mixfile do
  use Mix.Project

  def project do
    [app: :exql,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :postgrex]]
  end

  defp deps do
    [{:combine, "~> 0.7.0"},
     {:mariaex, "~> 0.7.1", optional: true},
     {:postgrex, "~> 0.11.1", optional: true}]
  end
end
