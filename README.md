# Exql

[![Build Status][travis-image]][travis-url]

[yesql](https://github.com/krisajenkins/yesql) and [ragtime](https://github.com/weavejester/ragtime) for Elixir

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

lib/yourapp/repo.ex

    defmodule YourApp.Repo do
      use Exql, app: :yourapp
    end

lib/yourapp.ex

    children = [
      worker(YourApp.Repo, []),
    ]

config/config.ex

    config :exql, YourApp.Repo,
      adapter: Exql.Adapters.Postgres,
      hostname: "localhost",
      username: "user",
      password: "pass",
      database: "db"

priv/queries/repo.sql

    -- name: user_list
    select * from users offset :offset limit :limit;

    -- name: user_get
    select * from users where user_id = :id;

finally

    iex> YourApp.Repo.user_list offset: 0, limit: 10

    iex> YourApp.Repo.user_get 1

## Migration(TBD)

priv/migrations/001-create-user-table.up.sql

    create table users;

priv/migrations/001-create-user-table.down.sql

    drop table users;

config/config.ex

    config :soa,
      exql_repos: [YourApp.Repo]

up

    $ mix exql.migrate [-r YourApp.Repo]

down

    $ mix exql.rollback


[travis-image]: https://img.shields.io/travis/zweifisch/exql.svg?style=flat
[travis-url]: https://travis-ci.org/zweifisch/exql
