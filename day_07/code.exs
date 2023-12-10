files = ["example.txt", "input.txt"]

defmodule In do
  def read(file) do
    File.read!(file)
    |> String.split("\n", trim: true)
    |> Enum.map(&In.read_line/1)
  end
  def get_type(hand) do
    d = hand
        |> String.to_charlist()
        |> Enum.reduce(%{}, fn c, acc ->
            Map.put(acc, c, (acc[c] || 0) + 1)
        end)
        |> Map.to_list()
        |> Enum.map(&(elem(&1, 1)))
        |> Enum.sort()
        |> Enum.reverse()
    max = Enum.max(d)
    cond do
      max == 5 -> 10
      max == 4 -> 9
      max == 3 and 2 in d -> 8
      max == 3 -> 7
      Enum.count(d, &(&1 == 2)) > 1 -> 6
      max == 2 -> 5
      true -> 4
    end
  end
  def read_line(line) do
    [hand|[bid|_]] = String.split(line, " ", parts: 2)
    {In.get_type(hand), hand, String.to_integer(bid)}
  end
end


defmodule Part1 do
  #def char_cmp([], []) do false end
  def char_cmp([c1|t1], [c2|t2]) do
    card_lookup = %{'2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9, 'T' => 10, 'J' => 11, 'Q' => 12, 'K' => 13, 'A' => 14}
    if c1 != c2 do
      v1 = Map.get(card_lookup, [c1])
      v2 = Map.get(card_lookup, [c2])
      v1 < v2
    else
      char_cmp(t1, t2)
    end
  end

  def sort(hand1, hand2) do
    if elem(hand1, 0) != elem(hand2, 0) do
      elem(hand1, 0) < elem(hand2, 0)
    else
      s1 = elem(hand1, 1)
           |> String.to_charlist()
      s2 = elem(hand2, 1)
           |> String.to_charlist()
      Part1.char_cmp(s1, s2)
    end
  end
  def score(hands) do
    # IO.inspect(hands)
    hands
    |> Enum.sort(&Part1.sort/2)
    |> Enum.with_index()
    |> Enum.map(fn {{_,_,bid}, index} -> bid*(index+1) end)
    |> Enum.sum()
  end
end

Enum.map(files, fn file ->
  score = In.read(file)
          |> Part1.score()
  IO.puts("File:\t" <> file <> "\tScore\t" <> to_string(score))
end)
