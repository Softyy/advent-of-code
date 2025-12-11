day = 10
dayString = day |> Integer.to_string() |> String.pad_leading(2, "0")
file = "./_2025/src/day#{dayString}/example.txt"

IO.puts("Day #{day}")

defmodule AOC do
  def read_input(filePath) do
    File.read!(filePath)
    |> String.split("\n")
    |> Enum.reject(fn p -> p == "" end)
    |> Enum.map(fn line ->
      [lights_string | buttons_joltage] =
        line
        |> String.split(" ", trim: true)

      [joltage_string | buttons] = buttons_joltage |> Enum.reverse()

      lights_string_length = String.length(lights_string)
      joltage_string_length = String.length(joltage_string)

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

      joltage =
        String.slice(joltage_string, 1, joltage_string_length - 2)
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)

      {lights, buttons, joltage}
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

  def permutations_with_repetition(_, 0) do
    [[]]
  end

  def permutations_with_repetition(list, count) do
    for(elem <- list, rest <- permutations_with_repetition(list, count - 1)) do
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

  def buttons_that_work(buttons, button_index) do
    buttons
    |> Enum.reduce([], fn button, acc ->
      case Enum.find(button, fn c -> c == button_index end) do
        nil -> acc
        _ -> [button | acc]
      end
    end)
  end

  def get_joltage_options(buttons, joltage) do
    for({jotlage_value, index} <- Enum.with_index(joltage)) do
      options = buttons_that_work(buttons, index)
      permutations_with_repetition(options, jotlage_value)
    end
  end

  def button_to_joltage_form(button, joltage) do
    joltage
    |> Enum.with_index()
    |> Enum.map(fn {_, idx} ->
      case Enum.any?(button, fn b -> b == idx end) do
        true -> 1
        false -> 0
      end
    end)
  end

  def sub(x, y) do
    Enum.zip(x, y)
    |> Enum.map(fn {a, b} ->
      cond do
        a < b ->
          :infinity

        true ->
          a - b
      end
    end)
  end

  def count_buttons(buttons, joltage, cache) do
    {count, new_cache} =
      cond do
        joltage == [0, 0, 0, 0] ->
          {0, cache}

        Map.has_key?(cache, joltage) ->
          {Map.get(cache, joltage), cache}

        Enum.any?(joltage, fn j -> j == :infinity end) ->
          {:infinity, cache}

        true ->
          buttons
          |> Enum.scan({0, cache}, fn button, {_, next_cache} ->
            {count, new_cache} = count_buttons(buttons, sub(joltage, button), next_cache)

            case count do
              :infinity -> {:infinity, new_cache}
              _ -> {count + 1, new_cache}
            end
          end)
          |> Enum.min_by(fn {count, _} -> count end)
      end

    {count, Map.put(new_cache, joltage, count)}
  end

  def solve_machine_part2({_, buttons, joltage}) do
    buttons_joltage_form =
      buttons
      |> Enum.map(fn button -> button_to_joltage_form(button, joltage) end)

    cache = %{[0, 0, 0, 0] => 0}
    {count, _} = count_buttons(buttons_joltage_form, joltage, cache)
    IO.inspect(count)
    count
  end
end

data = AOC.read_input(file)

part1 = data |> Enum.map(&AOC.solve_machine/1) |> Enum.sum()
part2 = data |> Enum.map(&AOC.solve_machine_part2/1) |> Enum.sum()

# 375
IO.puts("Part 1: #{part1}")

# 7893123992
IO.puts("Part 2: #{part2}")
