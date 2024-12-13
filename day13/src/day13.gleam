import gleam/io
import simplifile.{read}
import gleam/result
import gleam/list
import gleam/regexp.{scan}
import gleam/string
import gleam/int
import gleam/dict
import gleam/pair
import gleam/option

pub fn main() {
  "example.txt"
  |> parse()
  |> part1()
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
    |> list.filter_map(fn(b){b.content |> int.parse()})
  })
}

fn part1(lst: List(List(Int))) {
  let #(a, b) = list.map(lst, solve) |> io.debug() |> most_repeated_item() |> io.debug()
  {a*3}+b
}

fn solve(l: List(Int)) {
  let det = {at(l,0) * at(l,3)} - {at(l,1) * at(l,2)} 
  let a = {{at(l,4) * at(l,3)} - {at(l,5) * at(l,2)}} / det
  let b = {{at(l,4) * at(l,1)} - {at(l,5) * at(l,0)}} / det
  #(a, b)
}

fn gen_count(lst: List(#(Int, Int))) {
  use acc, i <- list.fold(lst, dict.new())
  use x <- dict.upsert(acc, i)
  case x {
    option.Some(i) -> i + 1
    option.None -> 1
  }
}

fn most_repeated_item(lst: List(#(Int, Int))) {
  gen_count(lst)
  |> dict.fold(#(#(0, 0), 0), fn(acc, key, value) {
    case value > acc.1 {
      True -> #(key, value)
      False -> acc
    }
  })
  |> pair.first()
}

fn at(xs: List(Int), k: Int) -> Int {
  case xs, k {
    [x, ..], 0 -> x
    [_, ..xs], k -> at(xs, k - 1)
    [], _ -> 0
  }
}
