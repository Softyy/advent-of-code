day = 6
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
    |> Enum.reject(&Enum.empty?/1)
  end

  def transpose(m) do
    m
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def group(m) do
    m
    |> transpose()
    |> Enum.reduce([[]], fn line, acc ->
      if Enum.all?(line, fn c -> c == " " end) do
        [[] | acc]
      else
        [current | rest] = acc

        if Enum.empty?(rest) do
          [current ++ [line]]
        else
          [current ++ [line] | rest]
        end
      end
    end)
  end

  def solvePart1(p) do
    [op_list | val_lists] = p |> Enum.reverse()
    op = op_list |> Enum.at(0)

    vals =
      val_lists
      |> Enum.map(fn chars ->
        chars
        |> Enum.reject(fn c -> c == " " end)
        |> Enum.join()
        |> String.to_integer()
      end)

    cond do
      op == "+" ->
        vals
        |> Enum.sum()

      op == "*" ->
        vals
        |> Enum.product()
    end
  end

  def solvePart2(p) do
    op = p |> Enum.at(0) |> Enum.reverse() |> Enum.at(0)

    vals =
      p
      |> Enum.map(fn chars ->
        chars
        |> Enum.reject(fn c -> c == " " or c == "+" or c == "*" end)
        |> Enum.join()
        |> String.to_integer()
      end)

    cond do
      op == "+" ->
        vals
        |> Enum.sum()

      op == "*" ->
        vals
        |> Enum.product()
    end
  end
end

data = AOC.read_input(file)

part1 =
  data
  |> AOC.group()
  |> Enum.map(&AOC.transpose/1)
  |> Enum.map(&AOC.solvePart1/1)
  |> Enum.sum()

part2 =
  data
  |> AOC.group()
  |> Enum.map(&AOC.solvePart2/1)
  |> Enum.sum()

# 5171061464548
IO.puts("Part 1: #{part1}")

# 10189959087258
IO.puts("Part 2: #{part2}")
