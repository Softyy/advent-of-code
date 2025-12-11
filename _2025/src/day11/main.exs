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

  def traverse_part1(map, path, visited) do
    if path == "out" do
      1
    else
      # Placeholder for traversal logic
      next_paths = Map.get(map, path)
      next_visited = MapSet.put(visited, path)

      next_paths
      |> Enum.reduce(0, fn next, acc ->
        if MapSet.member?(next_visited, next) do
          acc
        else
          acc + traverse_part1(map, next, next_visited)
        end
      end)
    end
  end

  def traverse_part2(map, path, visited) do
    saw_dac_and_fft = MapSet.member?(visited, "dac") && MapSet.member?(visited, "fft")

    cond do
      path == "out" && saw_dac_and_fft ->
        1

      path == "out" && !saw_dac_and_fft ->
        0

      true ->
        # Placeholder for traversal logic
        next_paths = Map.get(map, path)
        next_visited = MapSet.put(visited, path)

        next_paths
        |> Enum.reduce(0, fn next, acc ->
          if MapSet.member?(next_visited, next) do
            acc
          else
            acc + traverse_part2(map, next, next_visited)
          end
        end)
    end
  end
end

data = AOC.read_input(file)

# part1 = data |> AOC.traverse_part1("you", MapSet.new())
part2 = data |> AOC.traverse_part2("svr", MapSet.new())

# 375
# IO.puts("Part 1: #{part1}")

# 7893123992
IO.puts("Part 2: #{part2}")
