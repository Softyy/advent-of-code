day = 3
dayString = day |> Integer.to_string() |> String.pad_leading(2, "0")
file = "./_2025/src/day#{dayString}/example.txt"

IO.puts("Day #{day}")

defmodule AOC do
  def read_input(filePath) do
    File.read!(filePath)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.graphemes(line)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def largest_joltage_with_leftovers(bank, remaining) do
    length = bank |> Enum.count()

    nums =
      bank
      |> Enum.slice(0..(length - remaining - 1))
      |> Enum.with_index()

    {largestNum, index} =
      Enum.max_by(nums, fn {el, _idx} -> el end)

    leftovers = bank |> Enum.slice((index + 1)..length)

    {largestNum, leftovers}
  end

  def over9000(bank, 0, joltage) do
    joltage + Enum.max(bank)
  end

  def over9000(bank, digit, joltage) do
    {d, leftovers} = largest_joltage_with_leftovers(bank, digit)
    over9000(leftovers, digit - 1, joltage + d * floor(:math.pow(10, digit)))
  end
end

data = AOC.read_input(file)

part1 = data |> Enum.map(fn bank -> AOC.over9000(bank, 1, 0) end) |> Enum.sum()

part2 = data |> Enum.map(fn bank -> AOC.over9000(bank, 11, 0) end) |> Enum.sum()

# 16842
IO.puts("Part 1: #{part1}")

# 167523425665348
IO.puts("Part 2: #{part2}")
