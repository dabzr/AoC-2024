import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import simplifile.{read}

pub fn main() {
  "input.txt"
  |> parse()
  |> fn(a) {
    part1(a) |> io.debug()
    part2(a) |> io.debug()
  }
}

fn parse(file path: String) {
  let tuple_list =
    path
    |> read()
    |> result.unwrap("")
    |> string.split("\n")
    |> list.filter_map(fn(a) { string.split_once(a, ": ") })
  use a <- list.map(tuple_list)
  pair.map_second(a, fn(b) { string.split(b, " ") })
  |> fn(b) {
    let assert Ok(b0) = int.parse(b.0)
    let b1 = b.1 |> list.filter_map(int.parse)
    #(b0, b1)
  }
}

fn part1(nums: List(#(Int, List(Int)))) {
  calculate(nums, combinate_op1)
}

fn part2(nums: List(#(Int, List(Int)))) {
  calculate(nums, combinate_op2)
}

fn calculate(
  nums: List(#(Int, List(Int))),
  callback: fn(List(Int)) -> List(Int),
) {
  nums
  |> list.filter(fn(a) {
    let #(val, lst) = a
    callback(lst)
    |> list.contains(val)
  })
  |> list.map(pair.first)
  |> int.sum()
}

fn combinate_op1(nums: List(Int)) {
  let assert [first, ..rest] = nums
  rest
  |> list.fold([first], fn(acc, a) {
    list.flat_map(acc, fn(prev) { [prev + a, prev * a] })
  })
}

fn combinate_op2(nums: List(Int)) {
  let assert [first, ..rest] = nums
  rest
  |> list.fold([first], fn(acc, a) {
    list.flat_map(acc, fn(prev) {
      let assert Ok(concated) =
        [int.to_string(prev), int.to_string(a)]
        |> string.concat()
        |> int.parse()
      [prev + a, prev * a, concated]
    })
  })
}
