day = 1
dayString = day |> Integer.to_string() |> String.pad_leading(2, "0")
file = "./_2025/src/day#{dayString}/input.txt"

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

turn = fn change, acc ->
  [dialNum, zeros, rotationZeros] = acc
  newDialNum = dialNum + change

  newRotationZeros = abs(floor(newDialNum / 100))
  IO.inspect({dialNum, change, newDialNum, newRotationZeros})
  newDialNum = Integer.mod(newDialNum, 100)

  if newDialNum == 0 do
    [newDialNum, zeros + 1, rotationZeros + newRotationZeros - 1]
  else
    [newDialNum, zeros, rotationZeros + newRotationZeros]
  end
end

dialNums = Enum.reduce(data, [startingDialNum, 0, 0], turn)
[_, zeros, rotationZeros] = dialNums

# 1147
IO.puts("Part 1: #{zeros}")
# 6796 - wrong missing something
# 6789
IO.puts("Part 2: #{zeros + rotationZeros}")
