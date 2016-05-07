# Eno

[![Build Status][travis-image]][travis-url]

Lightweight SQL toolkit for elixir inspired by [yesql](https://github.com/krisajenkins/yesql) and [ragtime](https://github.com/weavejester/ragtime).

For the moment only PostgreSQL is supported, and you need to add [postgrex](http://github.com/ericmj/postgrex) as a dependency.

## Installation

It's [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add eno to your list of dependencies in `mix.exs`:

        def deps do
          [{:eno, "~> 0.0.1"}]
        end

## Usage

lib/yourapp/repo.ex

    defmodule YourApp.Repo do
      use Eno
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

    config :eno, YourApp.Repo,
      adapter: Eno.Adapters.Postgres,
      hostname: "localhost",
      username: "user",
      password: "pass",
      database: "db"

finally

    iex> YourApp.Repo.user_list offset: 0, limit: 10

    iex> YourApp.Repo.user_get 1

## Migration

    $ mix eno.gen.migration init_users

priv/migrations/repo/20160507022535_init_users.up.sql

    create table users (id SERIAL PRIMARY KEY, name varchar(255) NOT NULL UNIQUE);

priv/migrations/repo/20160507022535_init_users.down.sql

    drop table users;

config/config.ex

    config :yourapp,
      eno_repos: [YourApp.Repo]

up

    $ mix eno.migrate [-r YourApp.Repo]

down

    $ mix eno.rollback [-r YourApp.Repo]

## Status

Not ready for production use yet. The API is subject to change.


[travis-image]: https://img.shields.io/travis/zweifisch/eno.svg?style=flat
[travis-url]: https://travis-ci.org/zweifisch/eno
