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


  @nums %{"one" => "1", "two" => "2", "three" => "3", "four" => "4", "five" => "5", "six" => "6", "seven" => "7", "eight" => "8", "nine" => "9"}

  def string_to_numbers_from_left(line) do
    index = Enum.min_by(@nums, fn x -> 
      String.split(line, elem(x, 0)) \
      |> List.first() \
      |> String.length()
    end)
    String.replace(line, elem(index, 0), elem(index, 1), global: false)
  end

  def string_to_numbers_from_right(line) do
    index = Enum.min_by(@nums, fn x -> 
      String.split(line, elem(x, 0)) \
      |> List.last() \
      |> String.length()
    end)
    String.replace(line, elem(index, 0), elem(index, 1))

  end

  def line_value_part1(line) do
    nums = numbers(line)
    left = List.first(nums) || "0"
    right = List.last(nums) || "0"
    
    #IO.puts(left <> " " <> right)
    String.to_integer(left <> right)
  end

  def line_value_part2(line) do
    left = Processing.string_to_numbers_from_left(line) \
           |> numbers() \
           |> List.first() || "0"
    right = Processing.string_to_numbers_from_right(line) \
            |> numbers() \
            |> List.last() || "0"
    
    #IO.puts(left <> " " <> right)
    String.to_integer(left <> right)
  end

  def file_value(lines, func) do
    Enum.map(lines, func) \
    |> List.foldl(0, fn (x, acc) -> x + acc end)
  end

  def for_each_file(files, func) do
    Enum.map(files, fn (file) ->
      value = Input.get(file) \
              |> Processing.file_value(func)
      IO.puts(file <> " : " <> to_string(value)) 
    end)
  end
end

files = ["example_1.txt", "example_2.txt", "input_1.txt"]

IO.puts("Day 1")
Processing.for_each_file(files, &Processing.line_value_part1/1)
IO.puts("")
IO.puts("Day 2")
Processing.for_each_file(files, &Processing.line_value_part2/1)
