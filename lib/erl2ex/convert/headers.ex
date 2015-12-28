
defmodule Erl2ex.Convert.Headers do

  @moduledoc false

  alias Erl2ex.ExAttr
  alias Erl2ex.ExClause
  alias Erl2ex.ExFunc
  alias Erl2ex.ExHeader
  alias Erl2ex.ExMacro

  alias Erl2ex.Convert.Context


  def build_header(context, forms) do
    header = forms
      |> Enum.reduce(%ExHeader{}, &header_check_form/2)
    %ExHeader{header |
      records: Context.map_records(context, fn(name, fields) -> {name, fields} end),
      record_info_available: not Context.is_local_func?(context, :record_info, 2)
    }
  end


  defp header_check_form(%ExFunc{clauses: clauses}, header), do:
    clauses |> Enum.reduce(header, &header_check_clause/2)
  defp header_check_form(%ExMacro{expr: expr}, header), do:
    header_check_expr(expr, header)
  defp header_check_form(%ExAttr{arg: arg}, header), do:
    header_check_expr(arg, header)
  defp header_check_form(_form, header), do: header


  defp header_check_clause(%ExClause{exprs: exprs}, header), do:
    exprs |> Enum.reduce(header, &header_check_expr/2)


  defp header_check_expr(expr, header) when is_tuple(expr) and tuple_size(expr) == 2, do:
    header_check_expr(elem(expr, 1), header)

  defp header_check_expr(expr, header) when is_tuple(expr) and tuple_size(expr) >= 3 do
    imported = expr |> elem(1) |> Keyword.get(:import, nil)
    if imported == Bitwise do
      header = %ExHeader{header | use_bitwise: true}
    end
    expr
      |> Tuple.to_list
      |> Enum.reduce(header, &header_check_expr/2)
  end

  defp header_check_expr(expr, header) when is_list(expr), do:
    expr |> Enum.reduce(header, &header_check_expr/2)

  defp header_check_expr(_expr, header), do: header

end
