import gleam/int
import gleam/io
import gleam/list.{count, filter_map, map, map2, sort, unique, unzip}
import gleam/result.{try, unwrap}
import gleam/string.{split, split_once}
import simplifile.{read}

pub fn main() {
  let #(a, b) =
    "input.txt"
    |> read()
    |> unwrap("")
    |> parse_input()
  io.debug(part1(a, b))
  io.debug(part2(a, b))
}

fn parse_input(s: String) {
  s
  |> split(on: "\n")
  |> filter_map(fn(i) {
    use #(a, b) <- try(split_once(i, on: "   "))
    use a <- try(int.parse(a))
    use b <- try(int.parse(b))
    Ok(#(a, b))
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
