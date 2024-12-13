import gleam/int
import gleam/io
import gleam/list
import gleam/regexp.{scan}
import gleam/result
import gleam/string
import simplifile.{read}

pub fn main() {
  "input.txt"
  |> parse()
  |> part2()
  |> io.debug()
}

fn parse(file path: String) {
  path
  |> read()
  |> result.unwrap("")
  |> string.split("\n\n")
  |> list.map(fn(a) {
    let assert Ok(re) = regexp.from_string("\\d+")
    scan(re, a)
    |> list.filter_map(fn(b) { b.content |> int.parse() })
  })
}

fn part1(lst: List(List(Int))) {
  list.map(lst, solve)
  |> int.sum()
}

fn part2(lst: List(List(Int))) {
  lst
  |> list.map(add_error)
  |> list.map(solve)
  |> int.sum()
}

fn solve(l: List(Int)) {
  let det = { at(l, 0) * at(l, 3) } - { at(l, 1) * at(l, 2) }
  let a =
    { { { { at(l, 4) * at(l, 3) } - { at(l, 5) * at(l, 2) } } } / det }
    |> int.absolute_value()
  let b =
    { { { at(l, 4) * at(l, 1) } - { at(l, 5) * at(l, 0) } } / det }
    |> int.absolute_value()
  let conda = { a * at(l, 0) + b * at(l, 2) } == at(l, 4)
  let condb = { a * at(l, 1) + b * at(l, 3) } == at(l, 5)
  case conda && condb {
    True -> { a * 3 } + b
    False -> 0
  }
}

fn add_error(l: List(Int)) {
  let assert [a, b, c, d, e, f] = l
  let error = 10_000_000_000_000
  [a, b, c, d, error + e, error + f]
}

fn at(xs: List(Int), k: Int) -> Int {
  case xs, k {
    [x, ..], 0 -> x
    [_, ..xs], k -> at(xs, k - 1)
    [], _ -> 0
  }
}
