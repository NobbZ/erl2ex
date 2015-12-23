defmodule StructureTest do
  use ExUnit.Case


  test "Record operations" do
    input = """
      -record(foo, {field1, field2=123}).
      foo() ->
        A = #foo{field1="Ada"},
        B = A#foo{field2=234},
        C = #foo{field1="Lovelace", _=345},
        #foo{field1=D} = B,
        #foo.field2,
        B#foo.field2.
      """

    expected = """
      require Record

      # The record_info function is auto-generated by the Erlang compiler.
      def record_info(:fields, :foo), do: [:field1, :field2]
      def record_info(:size, :foo), do: 3

      Record.defrecordp :erlrecord_foo, :foo, [field1: :undefined, field2: 123]


      defp foo() do
        a = erlrecord_foo(field1: 'Ada')
        b = erlrecord_foo(a, field2: 234)
        c = erlrecord_foo(field1: 'Lovelace', field2: 345)
        erlrecord_foo(field1: d) = b
        2
        erlrecord_foo(b, :field2)
      end
      """

    assert Erl2ex.convert_str(input) == expected
  end


  test "Override record_info" do
    input = """
      -record(foo, {field1, field2=123}).
      record_info(A, B) -> 1.
      """

    expected = """
      require Record

      Record.defrecordp :erlrecord_foo, :foo, [field1: :undefined, field2: 123]


      defp record_info(a, b) do
        1
      end
      """

    assert Erl2ex.convert_str(input) == expected
  end


  test "on_load attribute" do
    input = """
      -on_load(foo/0).
      """

    expected = """
      @on_load :foo
      """

    assert Erl2ex.convert_str(input) == expected
  end


  test "vsn attribute" do
    input = """
      -vsn(123).
      """

    expected = """
      @vsn 123
      """

    assert Erl2ex.convert_str(input) == expected
  end

end
