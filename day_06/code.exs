files = ["example.txt", "input.txt"]
defmodule In1 do
  def parse_line(line) do
    line
    |> String.split(" ", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
  end

  def read(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&In1.parse_line/1)
    |> List.zip()
  end
end

defmodule Part1 do
  def ceil_above(num) do
    c = ceil(num)
    if c == num do
      c + 1
    else
      c
    end
  end

  def floor_below(num) do
    f = floor(num)
    if f == num do
      f - 1
    else
      f
    end
  end

  def ways_to_win(pair) do
    time = elem(pair, 0)
    distance = elem(pair, 1)
    plus_minus = :math.sqrt((time * time / 4) - distance)
    t1 = Part1.ceil_above((time / 2) - plus_minus)
    t2 = Part1.floor_below((time / 2) + plus_minus)
    # IO.inspect({t1, t2})
    t2 - t1 + 1
  end

  def solve(data) do
    data
    |> Enum.map(&Part1.ways_to_win/1)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end
end

IO.puts("Part 1")
files
|> Enum.map(fn file ->
  score = In1.read(file)
          |> Part1.solve()
  IO.puts("File:\t" <> file <> "\tScore:\t" <> to_string(score))
end)

