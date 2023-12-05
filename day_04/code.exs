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

defmodule Part2 do
  def value_one_card(card) do
    win = elem(card, 1)
    my = elem(card, 2)
    length(win -- (win -- my))
  end

  def count_cards([], _doubles_list, acc) do acc end
  def count_cards([first| tail], doubles_list, acc) do
    draw_amount = (1 + length(doubles_list))
    score = Part2.value_one_card(first)
    new_doubles_list = doubles_list
                       |> Enum.map(fn x -> x - 1 end)
                       |> Enum.filter(fn x -> x > 0 end)
    duplicates = if score > 0 do 
      List.duplicate(score, draw_amount)
    else
      []
    end
    count_cards(tail, new_doubles_list ++ duplicates, acc + draw_amount)
  end
end

files = ["example_1.txt", "input_1.txt"]
IO.puts("Part 1:")  
Enum.map(files, fn file ->
  score = In.get_cards(file)
          |>Part1.value_cards()
  IO.puts(file <> " score: " <> to_string(score))
end)
IO.puts("\nPart 2:")
Enum.map(files, fn file ->
  score = In.get_cards(file)
          |>Part2.count_cards([], 0)
  IO.puts(file <> " score: " <> to_string(score))
end)
