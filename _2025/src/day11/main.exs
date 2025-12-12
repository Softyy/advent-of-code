day = 11
dayString = day |> Integer.to_string() |> String.pad_leading(2, "0")
file = "./_2025/src/day#{dayString}/input.txt"

IO.puts("Day #{day}")

defmodule AOC do
  def read_input(filePath) do
    File.read!(filePath)
    |> String.split("\n")
    |> Enum.reject(fn p -> p == "" end)
    |> Enum.reduce(%{}, fn line, acc ->
      [input | [outputs_string]] = String.split(line, ":", trim: true)
      outputs = String.split(outputs_string, " ", trim: true)
      Map.put(acc, input, outputs)
    end)
  end

  def traverse(map, path, out, visited, cache) do
    {count, new_cache} =
      cond do
        Map.has_key?(cache, path) ->
          {Map.get(cache, path), cache}

        path == out ->
          {1, cache}

        path != out && path == "out" ->
          {0, cache}

        true ->
          next_paths = Map.get(map, path)
          next_visited = MapSet.put(visited, path)

          next_paths
          |> Enum.reduce({0, cache}, fn next, {acc, r_cache} ->
            if MapSet.member?(next_visited, next) do
              {acc, cache}
            else
              {result, new_cache} = traverse(map, next, out, next_visited, r_cache)
              {result + acc, new_cache}
            end
          end)
      end

    {count, Map.put(new_cache, path, count)}
  end
end

data = AOC.read_input(file)

# part1 = data |> AOC.traverse("you", "out", MapSet.new(),Map.new()) |> elem(0)

{first_a_leg, _} = data |> AOC.traverse("svr", "dac", MapSet.new(), Map.new())
{first_b_leg, _} = data |> AOC.traverse("svr", "fft", MapSet.new(), Map.new())
{second_a_leg, _} = data |> AOC.traverse("dac", "fft", MapSet.new(), Map.new())
{second_b_leg, _} = data |> AOC.traverse("fft", "dac", MapSet.new(), Map.new())
{third_a_leg, _} = data |> AOC.traverse("fft", "out", MapSet.new(), Map.new())
{third_b_leg, _} = data |> AOC.traverse("dac", "out", MapSet.new(), Map.new())

part2 =
  first_a_leg * second_a_leg * third_a_leg +
    first_b_leg * second_b_leg * third_b_leg

# 749
# IO.puts("Part 1: #{part1}")

# 420257875695750
IO.puts("Part 2: #{part2}")
