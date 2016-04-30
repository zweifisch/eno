# Exql

[![Build Status][travis-image]][travis-url]

[yesql](https://github.com/krisajenkins/yesql) for Elixir

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add exql to your list of dependencies in `mix.exs`:

        def deps do
          [{:exql, "~> 0.0.1"}]
        end

  2. Ensure exql is started before your application:

        def application do
          [applications: [:exql]]
        end

## Usage

    defmodule App.Db do
      import Exql only: :macros
      defqueries "/path/to/queries.sql"
    end

[travis-image]: https://img.shields.io/travis/zweifisch/exql.svg?style=flat
[travis-url]: https://travis-ci.org/zweifisch/exql
