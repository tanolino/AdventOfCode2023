defmodule In do
  def map_out_draw([], map) do map end
  def map_out_draw([head|tail], map) do
    [number | color] = head
          |> String.trim()
          |> String.split(" ", parts: 2)
    map_out_draw(tail, Map.put(map, List.first(color), String.to_integer(number)))
  end

  def read_single_draw(draw) do
    String.split(draw, ",", trim: true)
    |> Enum.map(&String.trim/1)
    |> map_out_draw(%{})
  end

  def read_all_draws(draws) do
    Enum.map(draws, &In.read_single_draw/1)
  end

  def read_list_from_game(list) do
    String.split(list, ";", trim: true)
    |> Enum.map(&String.trim/1)
    |> read_all_draws
  end

  def read_games([], map) do map end
  def read_games([first|rest], map) do
    [name, data] = String.split(first, ":", parts: 2)
                   |> Enum.map(&String.trim/1)
    [_n, id] = String.split(name, " ", parts: 2)
    set = read_list_from_game(data)
    read_games(rest, Map.put(map, id, set))
  end

  def read_file(filename) do
    lines = File.read!(filename)
            |> String.split("\n", trim: true)
            |> Enum.map(&String.trim/1)
    read_games(lines, %{})
  end
end

defmodule Cmp do
  def is_draw_in_limit(draw, limit) do
    List.foldl(Map.keys(draw), true, fn col, acc ->
      in_draw = Map.fetch(draw, col)
      in_limit = Map.fetch(limit, col)
      acc && in_limit != nil && elem(in_draw, 1) <= elem(in_limit, 1)
    end)
  end

  def is_game_in_limit(game, limit) do
    List.foldl(game, true, fn draw, acc ->
      acc && is_draw_in_limit(draw, limit)
    end)
  end

  def get_games_in_limit(game_map, limit) do
    Enum.map(game_map, fn x ->
      in_limit = Cmp.is_game_in_limit(elem(x, 1), limit)
      {elem(x, 0), in_limit}
    end)
    |> Enum.filter(fn x -> elem(x, 1) end)
  end
end

defmodule Coll do
  def fold_minimal_set(set, draw) do
    List.foldl(Map.keys(draw), set, fn col, acc ->
      in_set = case Map.fetch(set, col) do
        :error -> 0
        {:ok, result} -> result
      end
      in_draw = case Map.fetch(draw, col) do
        :error -> 0
        {:ok, result} -> result
      end
      Map.put(acc, col, max(in_set, in_draw))
    end)
  end

  def collect_for_game(game) do
    data = elem(game, 1)
    min_set = List.foldl(data, %{}, fn draw, acc ->
      Coll.fold_minimal_set(acc, draw)
    end)
    #IO.inspect(game)
    #IO.inspect(min_set)
    game_score = List.foldl(Map.keys(min_set), 1, fn col, acc ->
      acc * min_set[col]
    end)

    #IO.puts(elem(game, 0) <> " score :" <> to_string(game_score))
    game_score
  end

  def collect_for_games(games) do
    Enum.map(games, &Coll.collect_for_game/1)
    |> Enum.sum()
  end
end

limit1 = %{"red" => 12, "green" => 13, "blue" => 14}
game_files = ["example_1.txt", "input_1.txt"]

IO.puts("Day 2 Part 1")
game_files
|> Enum.map(fn file ->
  games = In.read_file(file)
  solution = Cmp.get_games_in_limit(games, limit1)
  |> List.foldl(0, fn x, acc -> acc + String.to_integer(elem(x, 0)) end)

  IO.puts(file <> " sum: " <> to_string(solution))
end)

IO.puts("")
IO.puts("Day 2 Part 2")
game_files
|> Enum.map(fn file ->
  score = In.read_file(file)
          |> Coll.collect_for_games()

  IO.puts(file <> " score: " <> to_string(score))
end)
