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
      use Exql
    end

lib/yourapp/repo.sql

    -- name: user_list
    select * from users offset :offset limit :limit;

    -- name: user_get
    select * from users where user_id = :id;

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

finally

    iex> YourApp.Repo.user_list offset: 0, limit: 10

    iex> YourApp.Repo.user_get 1

## Migration

    $ mix exql.gen.migration init_users

priv/migrations/repo/20160507022535_init_users.up.sql

    create table users (id SERIAL PRIMARY KEY, name varchar(255) NOT NULL UNIQUE);

priv/migrations/repo/20160507022535_init_users.down.sql

    drop table users;

config/config.ex

    config :yourapp,
      exql_repos: [YourApp.Repo]

up

    $ mix exql.migrate [-r YourApp.Repo]

down

    $ mix exql.rollback [-r YourApp.Repo]


[travis-image]: https://img.shields.io/travis/zweifisch/exql.svg?style=flat
[travis-url]: https://travis-ci.org/zweifisch/exql
