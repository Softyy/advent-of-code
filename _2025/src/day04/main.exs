day = 4
dayString = day |> Integer.to_string() |> String.pad_leading(2, "0")
file = "./_2025/src/day#{dayString}/input.txt"

IO.puts("Day #{day}")

defmodule AOC do
  def read_input(filePath) do
    File.read!(filePath)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.graphemes(line)
      |> Enum.map(fn char ->
        if char == "@" do
          1
        else
          0
        end
      end)
    end)
  end

  def is_accessable(grid, x, y) do
    neighbours =
      -1..1
      |> Enum.map(fn dx ->
        -1..1
        |> Enum.map(fn dy ->
          if dx == 0 and dy == 0 do
            0
          else
            nx = x + dx
            ny = y + dy

            if nx < 0 or ny < 0 do
              0
            else
              Enum.at(grid, ny, [])
              |> Enum.at(nx, 0)
            end
          end
        end)
      end)
      |> List.flatten()
      |> Enum.sum()

    if neighbours < 4 do
      1
    else
      0
    end
  end
end

grid = AOC.read_input(file)
height = grid |> Enum.count()
width = grid |> Enum.at(0) |> Enum.count()

part1 =
  0..(height - 1)
  |> Enum.map(fn y ->
    0..(width - 1)
    |> Enum.map(fn x ->
      cell = Enum.at(grid, y) |> Enum.at(x)

      if cell == 1 do
        AOC.is_accessable(grid, x, y)
      else
        0
      end
    end)
  end)
  |> List.flatten()
  |> Enum.sum()

part2 = 0

IO.puts("Part 1: #{part1}")

IO.puts("Part 2: #{part2}")
