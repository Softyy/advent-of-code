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

  @doc """
  Counts the 1's centered around x
  0 1 0
  1 x 0
  1 0 1
  """
  def neighbours(grid, x, y) do
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
  end

  @doc """
  checks every cell in grid and produce a grid of the same dimensions
  where 1's represent cells that are accessable by the forklift
  """
  def removable_grid(grid) do
    height = grid |> Enum.count()
    width = grid |> Enum.at(0) |> Enum.count()

    0..(height - 1)
    |> Enum.map(fn y ->
      0..(width - 1)
      |> Enum.map(fn x ->
        cell = Enum.at(grid, y) |> Enum.at(x)

        if cell == 1 do
          if AOC.neighbours(grid, x, y) < 4 do
            1
          else
            0
          end
        else
          0
        end
      end)
    end)
  end

  def subtract(grid1, grid2) do
    height = grid1 |> Enum.count()
    width = grid1 |> Enum.at(0) |> Enum.count()

    0..(height - 1)
    |> Enum.map(fn y ->
      0..(width - 1)
      |> Enum.map(fn x ->
        cell1 = Enum.at(grid1, y) |> Enum.at(x)
        cell2 = Enum.at(grid2, y) |> Enum.at(x)

        cell1 - cell2
      end)
    end)
  end

  def repeat_until_stable(grid) do
    new_grid = AOC.removable_grid(grid)

    removable_cells = new_grid |> List.flatten() |> Enum.sum()

    if removable_cells == 0 do
      grid
    else
      next_grid = AOC.subtract(grid, new_grid)
      AOC.repeat_until_stable(next_grid)
    end
  end
end

grid = AOC.read_input(file)

part1 =
  AOC.removable_grid(grid)
  |> List.flatten()
  |> Enum.sum()

part2 =
  AOC.subtract(grid, AOC.repeat_until_stable(grid))
  |> List.flatten()
  |> Enum.sum()

IO.puts("Part 1: #{part1}")

IO.puts("Part 2: #{part2}")
