files = ["example.txt", "input.txt"]

defmodule In do
  def parse_seed_numbers(content) do
    content
    |> List.first()
    |> String.split(":")
    |> List.last()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_map_entry(entry) do
    [dst | [src | [ len | _]]] = entry
                                 |> String.split(" ", parts: 3)
                                 |> Enum.map(&String.to_integer/1)
    %{dst: dst, src: src, len: len}
  end

  def parse_map(map) do
    [header | [data | _]] = map |> String.split(" map:", parts: 2)
    [from | [ into | _]] = header |> String.split("-to-", parts: 2)
    mappings = data
               |> String.split("\n", trim: true)
               |> Enum.map(&In.parse_map_entry/1)
    %{from: from, into: into, map: mappings}
  end

  def parse_maps(content) do
    [_seeds| maps] = content
    maps
    |> Enum.map(&In.parse_map/1)
  end

  def read_file(file) do
    File.read!(file)
    |> String.split("\n\n")
  end
end

defmodule Part1 do
  def inner(src, []) do src end
  def inner(src, [entry|tail]) do
    if (entry.src <= src) and (src <= (entry.src + entry.len - 1)) do
      entry.dst + src - entry.src
    else
      Part1.inner(src, tail)
    end
  end

  def do_map(src, []) do src end
  def do_map(src, [map|tail]) do
    dst = Part1.inner(src, map.map)
    Part1.do_map(dst, tail)
  end

  def get_closest(seed_list, map) do
    seed_list
    |> Enum.map(fn seed -> Part1.do_map(seed, map) end)
    |> Enum.min()
  end
end

IO.puts("Part 1")
Enum.map(files, fn file ->
  content = In.read_file(file)
  seeds = In.parse_seed_numbers(content)
  maps = In.parse_maps(content)
  closest_seed = Part1.get_closest(seeds, maps)
  IO.puts("File: " <> file <> " closest: " <> to_string(closest_seed))
end)

defmodule Part2 do
  def input_conv([]) do [] end
  def input_conv(list) do
    [start | [length | tail]] = list
    [%{start: start, length: length} | input_conv(tail)]
  end

  def map_range_split(ran, map) do
    #IO.puts("map_range_split")
    #IO.inspect({ran, map})
    if ran.start < map.src do
      off = map.src - ran.start
      res = map_range(%{start: ran.start, length: off}, [map])
      res = res ++ map_range(%{start: map.src, length: ran.length - off}, [map])
      res
    else
      leng = map.src + map.len - ran.start
      res = map_range(%{start: ran.start, length: leng}, [map])
      res = res ++ map_range(%{start: map.src + map.len, length: ran.length - leng}, [map])
      res
    end
  end

  def map_range(ran, []) do [ran] end
  def map_range(ran, [map|tail]) do
    cond do
      (map.src + map.len <= ran.start) ->
        map_range(ran, tail)
      (ran.start + ran.length <= map.src) ->
        map_range(ran, tail)
      (ran.start >= map.src and ran.start + ran.length <= map.src + map.len) ->
        [%{start: (ran.start - map.src) + map.dst, length: ran.length}]
      true -> map_range_split(ran, map)
    end
  end

  def get_closest(in_ranges, []) do
    in_ranges
    |> Enum.map(fn x -> x.start
    end)
    |> Enum.min()
  end
  def get_closest(in_ranges, [map|maps]) do
    out_ranges = in_ranges
                 |> Enum.map(fn x -> Part2.map_range(x, map.map) end)
                 |> Enum.filter(&(&1 != nil))
                 |> List.flatten()
    out_ranges
    |> get_closest(maps)
  end
end

IO.puts("\nPart 2")
Enum.map(files, fn file ->
  content = In.read_file(file)
  maps = In.parse_maps(content)
  closest = In.parse_seed_numbers(content)
            |> Part2.input_conv()
            |> Part2.get_closest(maps)
  IO.puts("File: " <> file <> " closest: " <> to_string(closest))
end)
