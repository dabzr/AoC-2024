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
  "input.txt"
  |> parse()
  |> part2()
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
  grid
  |> dict.filter(fn(_, n) { n == 0 })
  |> dict.keys()
  |> list.fold(0, fn(acc, pos) {
    grid
    |> walk(pos, [])
    |> list.unique()
    |> list.length()
    |> int.add(acc)
  })
}

fn part2(grid: Grid) {
  grid
  |> dict.filter(fn(_, n) { n == 0 })
  |> dict.keys()
  |> list.fold(0, fn(acc, pos) {
    grid
    |> walk(pos, [])
    |> list.length()
    |> int.add(acc)
  })
}

fn walk(grid: Grid, point: Point, lst: List(Point)) {
  let assert Ok(value) = dict.get(grid, point)
  case value {
    9 -> [point, ..lst]
    n -> {
      point
      |> close_pos([#(0, 1), #(0, -1), #(1, 0), #(-1, 0)])
      |> list.fold(lst, fn(acc, a){
        case dict.get(grid, a) == Ok(n+1) {
          True -> walk(grid, a, acc)
          False -> acc
        }
      })
    } 
  }
}

pub fn close_pos(p: Point, directions: List(Point)) {
  list.map(directions, fn(a){ #(p.0+a.0, p.1+a.1) })
}

