day = 5
dayString = day |> Integer.to_string() |> String.pad_leading(2, "0")
file = "./_2025/src/day#{dayString}/example.txt"

IO.puts("Day #{day}")

defmodule AOC do
  def read_input(filePath) do
    [id_range_strs | available_ids] =
      File.read!(filePath)
      |> String.split("\n\n", trim: true)

    bounds =
      String.split(id_range_strs, "\n", trim: true)
      |> Enum.map(fn range ->
        String.split(range, "-", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)

    ids =
      available_ids
      |> List.first()
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    {bounds, ids}
  end

  def is_fresh(id, bounds) do
    Enum.any?(bounds, fn [low, high] ->
      id >= low and id <= high
    end)
  end

  def fold_bounds(bounds) do
    bounds
    |> Enum.sort_by(fn [low, _high] -> low end)
    |> Enum.reduce([], fn [low, high], acc ->
      case acc do
        [] ->
          [[low, high]]

        [[last_low, last_high] | rest] ->
          if low <= last_high + 1 do
            # merge
            new_high = max(high, last_high)
            [[last_low, new_high] | rest]
          else
            [[low, high] | acc]
          end
      end
    end)
  end
end

{bounds, ids} = AOC.read_input(file)

part1 =
  ids
  |> Enum.filter(&AOC.is_fresh(&1, bounds))
  |> Enum.count()

part2 =
  AOC.fold_bounds(bounds)
  |> Enum.map(fn [low, high] -> high - low + 1 end)
  |> Enum.sum()

# 529 
IO.puts("Part 1: #{part1}")

# 344260049617193
IO.puts("Part 2: #{part2}")
