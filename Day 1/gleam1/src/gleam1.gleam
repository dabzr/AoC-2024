import gleam/int
import gleam/io
import gleam/list.{count, map, map2, sort, unique, unzip}
import gleam/result.{unwrap}
import gleam/string.{split, split_once}
import simplifile.{read}

pub fn main() {
  let #(a, b) = unwrap(read("input.txt"), "") |> parse_input()
  io.debug(part1(a, b))
  io.debug(part2(a, b))
}

fn parse_input(s: String) {
  s
  |> split(on: "\n")
  |> map(fn(i) {
    let #(a, b) = split_once(i, on: "   ") |> unwrap(#("0", "0"))
    #(a |> int.parse() |> unwrap(0), b |> int.parse() |> unwrap(0))
  })
  |> unzip()
}

fn part1(l1: List(Int), l2: List(Int)) {
  let l1 = sort(l1, by: int.compare)
  let l2 = sort(l2, by: int.compare)
  map2(l1, l2, fn(a, b) { a |> int.subtract(b) |> int.absolute_value() })
  |> int.sum()
}

fn part2(l1: List(Int), l2: List(Int)) {
  l1
  |> unique()
  |> map(fn(a) { l2 |> count(fn(b) { a == b }) |> int.multiply(a) })
  |> int.sum()
}
