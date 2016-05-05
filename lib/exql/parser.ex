defmodule Exql.Parser do

  use Combine, parsers: [:text]

  defp tag(parser, tag) do
    map(parser, fn x -> {tag, x} end)
  end

  defp as(parser, as) do
    map(parser, fn _ -> as end)
  end

  defp to_sql(tokens) do
    Enum.reduce(tokens, {"", []}, fn (x, {sql, vars}) ->
      case x do
        {:var, [name, type]} -> {"#{sql}$#{1+Enum.count vars}", vars ++ [{name, type}]}
        _ -> {sql <> x, vars}
      end
    end)
  end

  @doc """
  [[name: :name,
    sql: "sql", [{var: type}]}
  ]]
  """
  def parse(input) do
    fn_name = skip(string("--"))
      |> skip(many(space))
      |> skip(string("name:"))
      |> skip(many(space))
      |> label(word_of(~r/[a-zA-Z0-9>_<$]+[!?]?/), "fn_name")
      |> map(&String.to_atom(&1))
      |> tag(:name)
    type = [skip(string("::")), word, as(string("[]"), :array)]
      |> sequence
      |> tag(:type)
    var = [skip(char(":")), (word|>map(&String.to_atom(&1))), option(type)]
      |> sequence
      |> tag(:var)
    statement = [word_of(~r/[a-zA-Z0-9_(),=*;| ]+/), var]
      |> choice
      |> many1
    sql = sep_by1(statement, many1(newline))
      |> map(&Enum.intersperse(&1, "\n"))
      |> map(&List.flatten(&1))
      |> map(&to_sql(&1))
      |> tag(:sql)
    parser = skip(many(newline))
      |> sep_by1(sequence([fn_name, skip(many1(newline)), sql]), many(newline))
      |> skip(many(newline))
      |> eof
    with [result] <- Combine.parse(input, parser) do
      result
    end
  end

end
