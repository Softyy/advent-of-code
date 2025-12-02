day = 2
dayString = day |> Integer.to_string() |> String.pad_leading(2, "0")
file = "./_2025/src/day#{dayString}/input.txt"

IO.puts("Day #{day}")

readInput = fn filePath ->
  File.read!(filePath)
  |> String.split(",", trim: true)
  |> Enum.map(fn ids ->
    String.split(ids, "-", trim: true)
    |> Enum.map(fn id ->
      cleanId = String.replace(id, "\n", "")
      String.to_integer(cleanId)
    end)
  end)
end

data = readInput.(file)

invalidIdPart1 = fn id ->
  strId = Integer.to_string(id)
  length = String.length(strId)

  if rem(length, 2) == 0 do
    mid = div(length, 2)
    {firstHalf, secondHalf} = String.split_at(strId, mid)
    firstHalf == secondHalf
  else
    false
  end
end

fillIds = fn [id1, id2] ->
  Enum.to_list(id1..id2)
end

tryRepeating = fn s, length ->
  pattern = String.slice(s, 0, length)
  chars = String.graphemes(s)
  chunks = Enum.chunk_every(chars, length)
  Enum.all?(chunks, fn chunk -> Enum.join(chunk) == pattern end)
end

invalidIdPart2 = fn id ->
  strId = Integer.to_string(id)
  length = String.length(strId)

  if length < 2 do
    false
  else
    1..div(length, 2) |> Enum.any?(fn l -> tryRepeating.(strId, l) end)
  end
end

part1 =
  data |> Enum.map(fillIds) |> List.flatten() |> Enum.filter(&invalidIdPart1.(&1)) |> Enum.sum()

part2 =
  data |> Enum.map(fillIds) |> List.flatten() |> Enum.filter(&invalidIdPart2.(&1)) |> Enum.sum()

# 5398419778
IO.puts("Part 1: #{part1}")

# 15704845910
IO.puts("Part 2: #{part2}")
