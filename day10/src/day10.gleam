import gleam/io
import simplifile.{read}
import gleam/result
import gleam/list
import gleam/dict.{type Dict}
import gleam/string
import gleam/int

type Point = #(Int, Int)
type Grid = Dict(Point, Int)

pub fn main() {
  "example.txt"
  |> parse()
  |> io.debug()
}

fn parse(file path: String) {
  path
  |> read()
  |> result.unwrap("")
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> list.index_map(fn (lst, i) {
    list.index_map(lst, fn(char, j) {
      let assert Ok(n) = int.parse(char)
      #(#(j, i), n)
    })
  })
  |> list.flatten()
  |> dict.from_list()
}

fn part1(grid: Grid) {
  todo
}

fn walk(grid: Grid, at point: Point) {
  todo
}
