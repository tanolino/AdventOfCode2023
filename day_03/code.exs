defmodule In do
  def read(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
  end
end

defmodule Num do
  def gen_arr([], out_arr, _offset) do out_arr end
  def gen_arr([num| no_num_tail], out_arr, offset) do
    res = out_arr ++ [{offset, num}]
    if (no_num_tail == nil) do
      res
    else
      [no_num| num_tail] = no_num_tail
      Num.gen_arr(num_tail, res, offset + String.length(num) + String.length(no_num))
    end
  end

  def gen_from_line(line_tup) do
    line_nr = elem(line_tup, 1)
    text = elem(line_tup, 0)
    [no_num| num_tail] = Regex.split(~r/[0-9]+/, text, include_captures: true)
    Num.gen_arr(num_tail, [], String.length(no_num))
    |> Enum.map(fn x -> {elem(x, 0), line_nr, elem(x, 1)} end)
  end

  def gen(grid) do
    Enum.with_index(grid)
    |> Enum.map(&Num.gen_from_line/1)
    |> Enum.filter(fn x -> !Enum.empty?(x) end)
    |> List.flatten()
  end
end

defmodule Part do
  def gen_arr([], out_arr, _offset) do out_arr end
  def gen_arr([part| no_part_tail], out_arr, offset) do
    res = out_arr ++ [{offset, part}]
    if (no_part_tail == nil) do
      res
    else
      [no_part| part_tail] = no_part_tail
      Part.gen_arr(part_tail, res, offset + String.length(part) + String.length(no_part))
    end
  end

  def gen_from_line(line_tup) do
    line_nr = elem(line_tup, 1)
    text = elem(line_tup, 0)
    text = Regex.replace(~r/[0-9]/, text, " ")
    text = String.replace(text, ".", " ")
    [no_part| part_tail] = Regex.split(~r/[^[:space:]]/, text, include_captures: true)
    Part.gen_arr(part_tail, [], String.length(no_part))
    |> Enum.map(fn x -> {elem(x, 0), line_nr, elem(x, 1)} end)
  end

  def gen(grid) do
    Enum.with_index(grid)
    |> Enum.map(&Part.gen_from_line/1)
    |> Enum.filter(fn x -> !Enum.empty?(x) end)
    |> List.flatten()
  end
end

defmodule Find do
  def is_close(num, parts) do
    min_x = elem(num, 0) -1
    max_x = min_x + 1 + String.length(elem(num, 2))
    min_y = elem(num, 1) -1
    max_y = min_y + 2
    Enum.any?(parts, fn p ->
      part_x = elem(p, 0)
      part_y = elem(p, 1)
      part_x >= min_x && part_x <= max_x && part_y >= min_y && part_y <= max_y
    end)
  end

  def partnumbers([], _parts, res) do res end
  def partnumbers([num| tail], parts, res) do
    if (Find.is_close(num, parts)) do
      partnumbers(tail, parts, [elem(num, 2)| res])
    else
      partnumbers(tail, parts, res)
    end
  end
end

defmodule Gear do
  def conv(part, numbers) do
    part_x = elem(part, 0)
    part_y = elem(part, 1)
    name = elem(part, 2)
    
    filtered = Enum.filter(numbers, fn num ->
      min_x = elem(num, 0) -1
      max_x = min_x + 1 + String.length(elem(num, 2))
      min_y = elem(num, 1) -1
      max_y = min_y + 2
      name == "*" && part_x >= min_x && part_x <= max_x && part_y >= min_y && part_y <= max_y
    end)
    if (length(filtered) == 2) do
      Enum.map(filtered, fn x ->
        String.to_integer(elem(x, 2))
      end)
      |>List.foldl(1, fn x, acc -> acc * x end)
    else
      0
    end
  end

  def identify_gears(parts, numbers) do 
    Enum.map(parts, fn part -> Gear.conv(part, numbers) end)
    |> Enum.sum()
  end
end

files = ["example_1.txt", "input_1.txt"]

IO.puts("Part 1")
Enum.map(files, fn file ->
  content = In.read(file)
  numbers = Num.gen(content)
  parts = Part.gen(content)
  legit = Find.partnumbers(numbers, parts, [])
  result = List.foldl(legit, 0, fn x, acc -> acc + String.to_integer(x) end)
  IO.puts(file <> " : " <> to_string(result))
end)

IO.puts("\nPart 2")
Enum.map(files, fn file ->
  content = In.read(file)
  numbers = Num.gen(content)
  parts = Part.gen(content)
  gears = Gear.identify_gears(parts, numbers)
  IO.inspect(gears)
end)
