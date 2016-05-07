defmodule Eno.Mixfile do
  use Mix.Project

  def package do
    [maintainers: ["Feng Zhou"],
     licenses: ["MIT"],
     description: "lightweight SQL toolkit",
     links: %{"GitHub" => "https://github.com/zweifisch/eno"}]
  end

  def project do
    [app: :eno,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package]
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
