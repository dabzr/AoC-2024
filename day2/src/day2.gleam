import gleam/int.{absolute_value}
import gleam/io
import gleam/bool.{and}
import gleam/list.{count, filter_map, map, window_by_2, fold, first}
import gleam/result.{unwrap, try}
import gleam/string.{split}
import simplifile.{read}

pub fn main() {
  let lst =
    "input.txt"
    |> read()
    |> unwrap("")
    |> parse_input()
  lst |> part1() |> io.debug()

}

fn parse_input(input: String) {
  input
  |> split(on: "\n")
  |> map(fn(a) {
    a
    |> split(on: " ")
    |> filter_map(fn(b) { int.parse(b) })
  })
}
fn sign(n: Int) {
  case n < 0 {
    True -> -1
    False -> 1
  }
}
fn part1(lst: List(List(Int))) {
  lst
  |> count(fn(a) {
    let windowed = a |> window_by_2()
    let first_windowed = unwrap(first(windowed), #(0, 0))
    let #(cond, _) = windowed |> fold (from:#(True, sign(first_windowed.0)), with:
      fn(acc, b) {
        let abs_diff = absolute_value(b.0-b.1)
        let s = sign(b.0-b.1)
        let condition = acc.0 |> and(abs_diff > 0) |> and (abs_diff < 4) |> and (s == acc.1)
        #(condition, s)
    })
    cond
  })
}
