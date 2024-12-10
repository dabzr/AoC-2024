import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

pub fn main() {
  let dic = "input.txt" |> parse()
  dic |> part1(140) |> io.debug()
  dic |> part2(140) |> io.debug()
}

type Grid(a) =
  Dict(#(Int, Int), a)

fn parse(path: String) {
  path
  |> read()
  |> result.unwrap("")
  |> string.split("\n")
  |> list.index_map(fn(a, i) {
    a
    |> string.to_graphemes()
    |> list.index_map(fn(b, j) { #(#(i, j), b) })
  })
  |> list.flatten()
  |> dict.from_list()
}

fn part1(grid: Grid(String), size: Int) {
  list.range(from: 0, to: { size * size - 1 })
  |> list.map(fn(i) {
    let word = fn(a: List(#(Int, Int))) {
      a |> list.filter_map(fn(b) { dict.get(grid, b) }) |> string.concat()
    }
    let row = line(i, size, 4) |> word()
    let col = column(i, size, 4) |> word()
    let diag1 = main_diagonal(i, size, 4) |> word()
    let diag2 = reverse_diagonal(i, size, 4) |> word()
    [row, col, diag1, diag2]
    |> list.filter(fn(a) { a == "XMAS" || a == "SAMX" })
    |> list.length()
  })
  |> int.sum()
}

fn part2(grid: Grid(String), size: Int) {
  list.range(from: 0, to: { size * size - 1 })
  |> list.count(fn(i) {
    let word = fn(a: List(#(Int, Int))) {
      a |> list.filter_map(fn(b) { dict.get(grid, b) }) |> string.concat()
    }
    let row = line(i, size, 3) |> word()
    let col = column(i, size, 3) |> word()
    let diag = main_diagonal(i, size, 3) |> word()
    case filter_middle(row), filter_middle(col), diag {
      "MS", "MM", "MAS" -> True
      "MM", "MS", "MAS" -> True
      "SM", "SS", "SAM" -> True
      "SS", "SM", "SAM" -> True
      _, _, _ -> False
    }
  })
}

fn filter_middle(s: String) {
  case string.first(s), string.last(s) {
    Ok(a), Ok(b) -> a <> b
    _, _ -> ""
  }
}

fn line(i: Int, size: Int, slice: Int) {
  list.range(from: 0, to: { slice - 1 })
  |> list.map(fn(a) { #(i / size + a, i % size) })
}

fn column(i: Int, size: Int, slice: Int) {
  list.range(from: 0, to: { slice - 1 })
  |> list.map(fn(a) { #(i / size, i % size + a) })
}

fn main_diagonal(i: Int, size: Int, slice: Int) {
  list.range(from: 0, to: { slice - 1 })
  |> list.map(fn(a) { #(i / size + a, i % size + a) })
}

fn reverse_diagonal(i: Int, size: Int, slice: Int) {
  list.range(from: 0, to: { slice - 1 })
  |> list.map(fn(a) { #(i / size - a, i % size + a) })
}
