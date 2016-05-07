defmodule Eno do

  defp defquery(name, sql, vars) do
    case vars do
      [] ->
        quote do
          @doc """
          """
          def unquote(name)() do
            @adapter.query __MODULE__, unquote(sql), []
          end
        end
      [{varname, _}] ->
        varname = Macro.var varname, nil
        quote do
          @doc """
          """
          def unquote(name)(unquote varname) do
            @adapter.query __MODULE__, unquote(sql), [unquote varname]
          end
        end
      _ ->
        args = Enum.map vars, fn {name, _}-> Macro.var name, nil end
        kwargs = Enum.map vars, fn {name, _}-> quote do: params[unquote name] end
        quote do
          @doc """
          """
          def unquote(name)(params) when is_list params do
            @adapter.query __MODULE__, unquote(sql), [unquote_splicing kwargs]
          end

          @doc """
          """
          def unquote(name)(unquote_splicing args) do
            @adapter.query __MODULE__, unquote(sql), [unquote_splicing args]
          end
        end
    end
  end

  defp defqueries(input) do
    Enum.map(Eno.Parser.parse(input), fn [name: name, sql: {sql, vars}] ->
      defquery name, sql, vars end)
  end

  def loadqueries(path) do
    case File.read path do
      {:error, :enoent} -> raise "Cant load sql at #{path}"
      {:ok, content} -> defqueries content
    end
  end

  defmacro defqueries(:path, path) do
    loadqueries path
  end

  defmacro defqueries(app, path) do
    loadqueries Path.join :code.priv_dir(app), path
  end

  defmacro __using__(opts) do
    sqls = case opts[:sql] do
             pathes when is_list pathes -> pathes
             path when is_binary path -> [path]
             nil -> ["#{__CALLER__.module |> Module.split |> List.last |> Macro.underscore}.sql"]
           end |> Enum.map(&Path.join(Path.dirname(__CALLER__.file), &1))

    quote do
      config = Eno.Supervisor.get_config __MODULE__

      unquote_splicing Enum.map sqls, fn x ->
        quote do: @external_resource unquote(x)
      end

      @adapter config[:adapter]

      def config do
        Eno.Supervisor.get_config __MODULE__
      end

      def start_link() do
        Eno.Supervisor.start_link(__MODULE__, Application.get_application(__MODULE__), @adapter)
      end

      unquote_splicing Enum.map(sqls, &loadqueries(&1))
    end
  end
end
