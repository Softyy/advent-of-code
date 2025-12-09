day = 8
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

  def sq_dist({x1, y1, z1}, {x2, y2, z2}) do
    (x1 - x2) ** 2 + (y1 - y2) ** 2 + (z1 - z2) ** 2
  end

  def get_dists(boxes) do
    length = boxes |> Enum.count()

    0..(length - 2)
    |> Enum.reduce(%{}, fn n, acc1 ->
      box1 = Enum.at(boxes, n)

      (n + 1)..(length - 1)
      |> Enum.reduce(acc1, fn m, acc2 ->
        box2 = Enum.at(boxes, m)

        if box1 != box2 do
          Map.put(acc2, [box1, box2], sq_dist(box1, box2))
        else
          acc2
        end
      end)
    end)
  end

  def boxes_to_wire(boxes, count) do
    boxes
    |> get_dists()
    |> Map.to_list()
    |> Enum.sort_by(fn {_, dist} -> dist end)
    |> Enum.take(count)
  end

  def wire_boxes(boxes_to_write, count_of_boxes) do
    boxes_to_write
    |> Enum.reduce_while([], fn {[box1, box2], _}, acc ->
      c_with_box1 = Enum.find_index(acc, fn circuit -> Enum.member?(circuit, box1) end)
      c_with_box2 = Enum.find_index(acc, fn circuit -> Enum.member?(circuit, box2) end)

      result =
        cond do
          c_with_box1 == nil and c_with_box2 == nil ->
            acc ++ [[box1, box2]]

          c_with_box1 != nil and c_with_box2 == nil ->
            List.update_at(acc, c_with_box1, fn circuit -> [box2] ++ circuit end)

          c_with_box1 == nil and c_with_box2 != nil ->
            List.update_at(acc, c_with_box2, fn circuit -> [box1] ++ circuit end)

          c_with_box1 == c_with_box2 ->
            acc

          # merge lists
          c_with_box1 != c_with_box2 ->
            box1_circuit = Enum.at(acc, c_with_box1)
            box2_circuit = Enum.at(acc, c_with_box2)

            old_list =
              cond do
                c_with_box1 > c_with_box2 ->
                  List.delete_at(acc, c_with_box1) |> List.delete_at(c_with_box2)

                c_with_box1 < c_with_box2 ->
                  List.delete_at(acc, c_with_box2) |> List.delete_at(c_with_box1)
              end

            [box1_circuit ++ box2_circuit] ++ old_list
        end

      if Enum.at(result, 0, []) |> Enum.count() == count_of_boxes do
        {:halt, {box1, box2}}
      else
        {:cont, result}
      end
    end)
  end
end

data = AOC.read_input(file)

count_of_boxes = data |> Enum.count()

part1 =
  data
  |> AOC.boxes_to_wire(1000)
  |> AOC.wire_boxes(count_of_boxes)
  |> Enum.map(&Enum.count/1)
  |> Enum.sort(:desc)
  |> Enum.take(3)
  |> Enum.product()

{{x1, _, _}, {x2, _, _}} =
  data
  |> AOC.boxes_to_wire(100_000)
  |> AOC.wire_boxes(count_of_boxes)

part2 = x1 * x2

# 121770  
IO.puts("Part 1: #{part1}")

# 7893123992
IO.puts("Part 2: #{part2}")
