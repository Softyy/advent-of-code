day = 10
dayString = day |> Integer.to_string() |> String.pad_leading(2, "0")
file = "./_2025/src/day#{dayString}/input.txt"

IO.puts("Day #{day}")

defmodule AOC do
  def read_input(filePath) do
    File.read!(filePath)
    |> String.split("\n")
    |> Enum.reject(fn p -> p == "" end)
    |> Enum.map(fn line ->
      [lights_string | buttons_plus] =
        line
        |> String.split(" ", trim: true)

      [plus | buttons] = buttons_plus |> Enum.reverse()
      lights_string_length = String.length(lights_string)

      lights =
        String.slice(lights_string, 1, lights_string_length - 2)
        |> String.graphemes()
        |> Enum.map(fn c -> c == "#" end)

      buttons =
        buttons
        |> Enum.map(fn b ->
          length = String.length(b)

          String.slice(b, 1, length - 2)
          |> String.split(",", trim: true)
          |> Enum.map(&String.to_integer/1)
        end)

      {lights, buttons, plus}
    end)
  end

  def permutations([], _) do
    [[]]
  end

  def permutations(_, 0) do
    [[]]
  end

  def permutations(list, count) do
    for(elem <- list, rest <- permutations(list -- [elem], count - 1)) do
      [elem | rest]
    end
  end

  def xor_buttons(buttons, lights) do
    Enum.reduce(buttons, lights, fn button, acc1 ->
      button
      |> Enum.reduce(acc1, fn index, acc2 ->
        List.update_at(acc2, index, fn light -> not light end)
      end)
    end)
    |> Enum.all?(fn light -> light == false end)
  end

  def solve_machine({lights, buttons, _}) do
    num_of_buttons = buttons |> Enum.count()

    Enum.reduce_while(0..num_of_buttons, nil, fn count, _ ->
      result =
        permutations(buttons, count)
        |> Enum.find(fn combo ->
          xor_buttons(combo, lights)
        end)

      case result do
        nil -> {:cont, nil}
        _ -> {:halt, count}
      end
    end)
  end
end

data = AOC.read_input(file)

part1 = data |> Enum.map(&AOC.solve_machine/1) |> Enum.sum()
part2 = 0

# 375
IO.puts("Part 1: #{part1}")

# 7893123992
IO.puts("Part 2: #{part2}")
