import gleam/bool.{negate, or}
import gleam/int
import gleam/io
import gleam/list.{
  all, any, combinations, count, filter, filter_map, is_empty, length, map,
  window_by_2,
}
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
  lst |> part2() |> io.debug()
}

fn parse_input(input: String) {
  input
  |> split(on: "\n")
  |> map(fn(a) {
    a
    |> split(on: " ")
    |> filter_map(int.parse)
  })
  |> filter(fn(x) { negate(is_empty(x)) })
}

fn part1(lst: List(List(Int))) {
  lst |> count(aux)
}

fn part2(lst: List(List(Int))) {
  lst
  |> filter(fn(line) { any(combinations(line, length(line) - 1), aux) })
  |> list.length
}

fn aux(a: List(Int)) {
  a
  |> window_by_2()
  |> map(fn(b) { b.0 - b.1 })
  |> fn(w) {
    all(w, fn(i) { i <= 3 && i >= 1 })
    |> or(all(w, fn(i) { i >= -3 && i <= -1 }))
  }
}
