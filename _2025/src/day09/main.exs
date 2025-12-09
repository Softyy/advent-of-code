day = 9
dayString = day |> Integer.to_string() |> String.pad_leading(2, "0")
file = "./_2025/src/day#{dayString}/input.txt"

IO.puts("Day #{day}")

defmodule AOC do
  def read_input(filePath) do
    File.read!(filePath)
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> Enum.reject(fn p -> p == {} end)
  end

  def rect_area({x1, y1}, {x2, y2}) do
    (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
  end

  def all_rect_areas(points) do
    length = points |> Enum.count()

    0..(length - 2)
    |> Enum.reduce(%{}, fn n, acc1 ->
      point1 = Enum.at(points, n)

      (n + 1)..(length - 1)
      |> Enum.reduce(acc1, fn m, acc2 ->
        point2 = Enum.at(points, m)

        if point1 != point2 do
          Map.put(acc2, [point1, point2], rect_area(point1, point2))
        else
          acc2
        end
      end)
    end)
  end
end

data = AOC.read_input(file) |> IO.inspect()

part1 = data |> AOC.all_rect_areas() |> Map.values() |> Enum.max()

part2 = 0

# 4741848414
IO.puts("Part 1: #{part1}")

# 7893123992
IO.puts("Part 2: #{part2}")
