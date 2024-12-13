import gleam/io
import simplifile.{read}
import gleam/result
import gleam/list
import gleam/dict.{type Dict}
import gleam/string
import gleam/int
import gleam/set.{type Set}
import gleam/bool.{negate}
type Point = #(Int, Int)
type Grid(a) = Dict(Point, a)

pub fn main() {
  "input.txt"
  |> parse()
  |> part1(140)
  |> io.debug()
}

fn parse(file path: String) {
  path
  |> read()
  |> result.unwrap("")
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> list.index_map(fn (lst, i) {
    list.index_map(lst, fn(char, j) { #(#(j, i), char) })
  })
  |> list.flatten()
  |> dict.from_list()
}

fn part1(grid: Grid(String), size: Int) {
  list.range(0, {size-1})
  |> list.fold([], fn(acc, i) {
    list.range(0, {size-1})
    |> list.filter_map(fn(j){
      case is_already_satisfied(#(j, i), acc) {
        False -> Ok(group(grid, #(j, i), set.new()))
        True -> Error(Nil)
      }
    })
    |> list.append(acc)
  })
  |> list.unique()
  |> list.map(fn(a) {set.size(a) * perimeter(grid, a)})
  |> int.sum()
}

fn group(grid: Grid(String), point: Point, s: Set(Point)) {
  let new_set = set.insert(s, point)
  let adj = get_adjacents(grid, point) |> list.filter(fn(x){negate(set.contains(new_set, x))})
  case adj {
    [] ->  new_set
    _ -> {
      use acc, pos <- list.fold(adj, new_set)
      set.union(acc, group(grid, pos, acc))
    } 
  }
}
fn is_already_satisfied(point: Point, lst: List(Set(Point))) {
  list.any(lst, fn(i) {set.contains(i, point)})
}
fn perimeter(grid: Grid(String), grp: Set(Point)) {
  use acc, pos <- set.fold(grp, 0)
  let size = 4 - {get_adjacents(grid, pos) |> list.length()}
  acc + size
}

fn get_adjacents(grid: Grid(String), point: Point) {
  let assert Ok(char) = dict.get(grid, point)
  close_pos(point, [#(-1, 0), #(1, 0), #(0, 1), #(0, -1)])
  |> list.filter(fn (pos) {dict.get(grid, pos) == Ok(char)})
}

fn close_pos(p: Point, directions: List(Point)) {
  list.map(directions, fn(a){ #(p.0+a.0, p.1+a.1) })
}



