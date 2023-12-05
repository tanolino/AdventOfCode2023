defmodule In do
  def to_nums(list) do
    list
    |> String.split(" ", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_line(line) do
    [card| [tail|_]] = String.split(line, ":", parts: 2)
    [win| [my|_]] = String.split(tail, "|", parts: 2)
    {card, In.to_nums(win), In.to_nums(my)}
  end

  def get_cards(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Stream.map(&String.trim/1)
    |> Enum.map(&In.parse_line/1)
  end
end

defmodule Part1 do
  def value_one_card(card) do
    win = elem(card, 1)
    my = elem(card, 2)
    n = length(win -- (win --my))
    if (n == 0) do
      0
    else
      Integer.pow(2, n-1)
    end
  end

  def value_cards(cards) do
    cards
    |> Enum.map(&Part1.value_one_card/1)
    |> Enum.sum()
  end
end


files = ["example_1.txt", "input_1.txt"]
Enum.map(files, fn file ->
  score = In.get_cards(file)
          |>Part1.value_cards()
  IO.puts(file <> " score: " <> to_string(score))
end)
