defmodule In do
  def read(file) do
    content = file
              |> File.read!()
              |> String.split("\n", trim: true)
              |> Enum.map(&String.trim/1)
    moves = content
            |> List.first()
    paths = content
            |> Enum.drop(1)
            |> Enum.reduce(%{}, &In.do_line/2)
    {moves, paths}
  end
  def do_line(line, map) do
    [name|[rest|_]] = String.split(line, " = (", trim: true)
    [left|[right|_]] = String.split(rest, ", ", trim: true)
                       |> Enum.map(&(String.trim(&1, ")")))
    Map.put(map, name, {left, right})
  end
end

defmodule Walk do
  def left_or_right(path, steps) do
    dir = path
          |> String.at(rem(steps, String.length(path)))
    if dir == "L", do: 0, else: 1
  end
  def walk(path, map, pos, steps) do
    dir = Walk.left_or_right(path, steps)
    next_pos = map
               |> Map.get(pos)
               |> elem(dir)
    if next_pos == "ZZZ" do
      steps + 1
    else
      Walk.walk(path, map, next_pos, steps + 1)
    end
  end
end

defmodule Walk2 do
  def walk(path, map) do
    start_pos = map
                |> Map.keys()
                |> Enum.filter(&(String.ends_with?(&1,"A")))
    Walk2.walk(path, map, start_pos, 0)
  end
  def walk(path, map, pos, steps) do
    dir = Walk.left_or_right(path, steps)
    #IO.inspect(pos)
    next_pos = pos
               |> Enum.map(fn x ->
                 map
                 |> Map.get(x)
                 |> elem(dir)
               end)
    #IO.inspect(next_pos)
    done = next_pos
           |> Enum.map(&(String.ends_with?(&1,"Z")))
           |> Enum.all?()
    if done do
      steps + 1
    else
      Walk2.walk(path, map, next_pos, steps + 1)
    end
  end
end

IO.puts("Part 1")
["example.txt", "example2.txt", "input.txt"]
|> Enum.map(fn file ->
  field = In.read(file)
  # IO.inspect({:field, field})
  res = Walk.walk(elem(field, 0), elem(field, 1), "AAA", 0)
  IO.puts("File:\t" <> file <> "\tSteps:\t" <> to_string(res))
end)

IO.puts("\nPart 2")
["example3.txt"] #, "input.txt"]
|> Enum.map(fn file ->
  field = In.read(file)
  res = Walk2.walk(elem(field, 0), elem(field, 1))
  IO.puts("File:\t" <> file <> "\tSteps:\t" <> to_string(res))
end)

