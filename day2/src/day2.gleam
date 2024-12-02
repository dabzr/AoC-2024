import gleam/int
import gleam/io
import gleam/bool.{or, negate}
import gleam/list.{is_empty, filter, all, count, filter_map, map, window_by_2}
import gleam/result.{unwrap}
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
    |> filter_map(int.parse)
  })
  |> filter(fn(x){negate(is_empty(x))})
}

fn part1(lst: List(List(Int))) {
  lst
  |> count(fn(a) {
      a
      |> window_by_2()
      |> map(fn(b) {b.0 - b.1})
      |> fn(w) {
        all(w, fn(i){i <= 3 && i >= 1})
        |> or(all(w, fn(i) {i >= -3 && i <= -1}))
      }
  })
}
