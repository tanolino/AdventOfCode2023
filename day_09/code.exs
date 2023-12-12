defmodule In do
  def read(file) do
    file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&In.line/1)
  end
  def line(line) do
    line
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule Part1 do
  def extrapolate([h|t]) do
    extrapolate(t, [h])
  end
  def extrapolate([], stack) do
    #IO.inspect({:result, stack})
    stack
  end
  def extrapolate([h|t], stack) do
    new_stack = update(h, stack)
    #IO.inspect({:add, h})
    #IO.inspect({:new_stack, new_stack})
    extrapolate(t, new_stack)
  end
  def update(val, []) do [val] end
  def update(val, [old|tail]) do
    diff = val - old
    if diff == 0 and tail == [] do
      [val|[diff]]
    else
      [val|update(diff, tail)]
    end
  end
  def speculate([]) do 0 end
  def speculate([stack| tail]) do
    #IO.inspect({:speculate, [stack|tail]})
    stack + speculate(tail)
  end
end

defmodule Part2 do
  def extrapolate([h|t]) do
    [h|t]
    |> Enum.reverse()
    |> Part1.extrapolate()
  end

  def speculate([h|t]) do
    #IO.inspect({:spec2, [h|t]})
    Part1.speculate([h|t])
  end
end

IO.puts("Part 1")
["example.txt", "input.txt"]
|> Enum.map(fn file ->
  speculation = In.read(file)
                |> Enum.map(&(
                  &1
                  |> Part1.extrapolate()
                  |> Part1.speculate()
                ))
  sum = Enum.sum(speculation)
  #IO.inspect({:speculation, speculation})
  IO.puts("File: " <> file <> " Score: " <> to_string(sum))
end)

IO.puts("\nPart 2")
["example.txt", "input.txt"]
|> Enum.map(fn file ->
  speculation = In.read(file)
                |> Enum.map(&(
                  &1
                  |> Part2.extrapolate()
                  |> Part2.speculate()
                ))
  sum = Enum.sum(speculation)
  IO.puts("File: " <> file <> " Score: " <> to_string(sum))
end)

