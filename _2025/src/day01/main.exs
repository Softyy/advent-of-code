day = 1
dayString = day |> Integer.to_string() |> String.pad_leading(2, "0")
file = "./_2025/src/day#{dayString}/example.txt"

IO.puts("Day #{day}")

readInput = fn filePath ->
  File.read!(filePath)
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    {rotation, numberStr} = String.split_at(line, 1)
    number = String.to_integer(numberStr)

    cond do
      rotation == "R" ->
        number

      rotation == "L" ->
        -number
    end
  end)
end

data = readInput.(file)
startingDialNum = 50

countZeros = fn change, acc ->
  [dialNum, zeros] = acc
  newDialNum = rem(dialNum + change, 100)

  if newDialNum == 0 do
    [newDialNum, zeros + 1]
  else
    [newDialNum, zeros]
  end
end

countTicks = fn change, acc ->
  [dialNum, ticks] = acc

  newDialNum = dialNum + change

  old = Integer.floor_div(dialNum, 100)
  new = Integer.floor_div(newDialNum, 100)
  turns = abs(new - old)

  cond do
    # -5 -> 0, turns over count by 1
    old < new and rem(newDialNum, 100) == 0 ->
      [newDialNum, ticks + turns - 1]

    # 100 -> 95, turns over count by 1
    old > new and rem(dialNum, 100) == 0 ->
      [newDialNum, ticks + turns - 1]

    # general case
    true ->
      [newDialNum, ticks + turns]
  end
end

[_, part1] = Enum.reduce(data, [startingDialNum, 0], countZeros)
[_, part2] = Enum.reduce(data, [startingDialNum, 0], countTicks)

# 1147
IO.puts("Part 1: #{part1}")
# 6789
IO.puts("Part 2: #{part1 + part2}")
