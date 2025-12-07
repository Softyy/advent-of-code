day = 7
dayString = day |> Integer.to_string() |> String.pad_leading(2, "0")
file = "./_2025/src/day#{dayString}/input.txt"

IO.puts("Day #{day}")

defmodule AOC do
  def read_input(filePath) do
    File.read!(filePath)
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
    end)
  end

  def start_location(grid) do
    grid
    |> Enum.at(0)
    |> Enum.find_index(fn c -> c == "S" end)
  end

  def count_beams(paths, grid, x, y) do
    cond do
      paths |> Map.has_key?({x, y}) ->
        paths

      y >= Enum.count(grid) - 1 ->
        paths

      true ->
        cell = grid |> Enum.at(y) |> Enum.at(x)

        case cell do
          "^" ->
            Map.put(paths, {x, y}, 1)
            |> count_beams(grid, x - 1, y)
            |> count_beams(grid, x + 1, y)

          _ ->
            Map.put(paths, {x, y}, 0)
            |> count_beams(grid, x, y + 1)
        end
    end
  end

  def count_timelines(paths, grid, x, y) do
    length = Enum.count(grid)

    cond do
      paths |> Map.has_key?({x, y}) ->
        {Map.get(paths, {x, y}), paths}

      y >= length - 1 ->
        {1, paths}

      true ->
        cell = grid |> Enum.at(y) |> Enum.at(x)

        {val, paths} =
          case cell do
            "^" ->
              {left, paths} = count_timelines(paths, grid, x - 1, y)
              {right, paths} = count_timelines(paths, grid, x + 1, y)
              {left + right, paths}

            _ ->
              count_timelines(paths, grid, x, y + 1)
          end

        {val, Map.put(paths, {x, y}, val)}
    end
  end
end

data = AOC.read_input(file)

start_x = AOC.start_location(data)
start_y = 0
part1 = AOC.count_beams(%{}, data, start_x, start_y) |> Map.values() |> Enum.sum()

{part2, _} = AOC.count_timelines(%{}, data, start_x, start_y)

IO.puts("Part 1: #{part1}")

IO.puts("Part 2: #{part2}")
