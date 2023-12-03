defmodule Input do
  def get(filename) do
    File.read!(filename) \
    |> String.split("\n", trim: true) \
    |> Stream.map(&String.trim/1)
  end
end

defmodule Processing do
  def is_number(txt) do
    String.match?(txt, ~r/[0-9]/)
  end

  def numbers(line) do
    String.codepoints(line) \
    |> Enum.filter(&Processing.is_number/1)
  end

  def line_value(line) do
    nums = numbers(line)
    left = List.first(nums, default: "0")
    right = List.last(nums, default: "0")
    String.to_integer(left <> right)
  end

  def file_value(lines) do
    Enum.map(lines, &Processing.line_value/1) \
    |> List.foldl(0, fn (x, acc) -> x + acc end)
  end

  def for_each_file(files) do
    Enum.map(files, fn (file) ->
      value = Input.get(file) \
              |> Processing.file_value()
      IO.puts(file <> " : " <> to_string(value)) 
    end)
  end
end

Processing.for_each_file(["example_1.txt", "input_1.txt"])
