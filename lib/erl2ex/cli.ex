
defmodule Erl2ex.Cli do

  @moduledoc """
  This module provides the command line interface for the erl2ex binary and
  the mix erl2ex task.
  """


  @doc """
  Runs the erl2ex binary, given a set of command line arguments.
  Returns the OS result code, which is 0 for success or nonzero for failure.
  """

  @spec run([String.t]) :: non_neg_integer

  def run(argv) do
    {options, args, errors} =
      OptionParser.parse(argv,
        strict: [
          output: :string,
          verbose: :boolean,
          help: :boolean
        ],
        aliases: [
          v: :verbose,
          "?": :help,
          o: :output
        ]
      )

    verbose_count = options
      |> Keyword.get_values(:verbose)
      |> Enum.count
    case verbose_count do
      0 -> Logger.configure(level: :warn)
      1 -> Logger.configure(level: :info)
      _ -> Logger.configure(level: :debug)
    end

    cond do
      not Enum.empty?(errors) ->
        display_errors(errors)
      Keyword.get(options, :help) ->
        display_help
      true ->
        run_conversion(args, options)
    end
  end


  @doc """
  Runs the erl2ex binary, given a set of command line arguments.
  Does not return. Instead, halts the VM on completion with the appropriate
  OS result code.
  """

  @spec main([String.t]) :: none

  def main(argv) do
    argv
      |> run
      |> System.halt
  end


  defp run_conversion([], options) do
    :all
      |> IO.read
      |> Erl2ex.convert_str(options)
      |> IO.write
  end

  defp run_conversion([path], options) do
    output = Keyword.get(options, :output)
    cond do
      File.dir?(path) ->
        Erl2ex.convert_dir(path, output, options)
        0
      File.regular?(path) ->
        Erl2ex.convert_file(path, output, options)
        0
      true ->
        IO.puts(:stderr, "Could not find input: #{path}")
        1
    end
  end

  defp run_conversion(paths, _) do
    IO.puts(:stderr, "Got too many input paths: #{inspect(paths)}\n")
    display_help
    1
  end


  defp display_errors(errors) do
    Enum.each(errors, fn
      {switch, val} ->
        IO.puts(:stderr, "Unrecognized switch: #{switch} #{val}")
      end)
    IO.puts(:stderr, "")
    display_help
    1
  end


  defp display_help do
    IO.write :stderr, """
      Usage: erl2ex [options] [input path]

        --output, -o "path"  Set the output file or directory path
        --verbose, -v        Display verbose status
        --help, -?           Display help text

      erl2ex is a Erlang to Elixir transpiler.

      When no input path is provided, erl2ex reads from stdin and writes to
      stdout. Any output path is ignored.

      When the input path is a file, erl2ex reads from the file and writes to
      the specified output path. If no output path is present, erl2ex creates
      an output file in the same directory as the input file.

      When the input path is a directory, erl2ex recursively searches the
      directory and reads from every Erlang (*.erl) file it finds. It writes
      the results in the same directory structure under the given output path,
      which must also be a directory. If no output path is provided, the
      results are written in the same directories as the input files.
      """
  end

end
