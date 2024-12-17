import simplifile.{read}
import gleam/result
import gleam/io
import gleam/string
import gleam/dict.{type Dict}
import gleam/pair
import gleam/list

pub fn main() {
  "input.txt"
  |> parse(parse_grid_p1)
  |> part1()
  |> io.debug()
}

type Point = #(Int, Int)
type Grid = Dict(Point, String)

fn parse(path: String, parse_grid: fn(String)->Grid) {
  path
  |> read()
  |> result.unwrap("")
  |> string.split_once("\n\n")
  |> result.unwrap(#("", ""))
  |> pair.map_first(parse_grid)
  |> pair.map_second(parse_direction)
}

fn parse_grid_p1(s: String) {
  s
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> list.index_map(fn(lst, i) {
    lst |> list.index_map(fn(char, j) { #(#(j, i), char) })
  })
  |> list.flatten()
  |> dict.from_list()
}

fn parse_grid_p2(s: String) {
  s
  |> string.replace("@", "@.")
  |> string.replace("O", "[]")
  |> string.replace("#", "##")
  |> string.replace(".", "..")
  |> parse_grid_p1()
}

fn parse_direction(s: String) {
  s
  |> string.replace("\n", "")
  |> string.to_graphemes()
  |> list.map(char_to_direction)
}

fn char_to_direction(char: String) {
  case char {
    "^" -> #(0, -1)
    "v" -> #(0, 1)
    "<" -> #(-1, 0)
    ">" -> #(1, 0)
    _ -> #(0, 0)
  }
}

fn part1(t: #(Grid, List(Point))) {
  let #(grid, directions) = t
  list.fold(directions, grid, fn(acc, d) {
    let w = walk(acc, find_at(acc), d, [])
    case w {
      [] -> acc
      _ -> {
        let new_dict = w |> dict.from_list()
        dict.combine(acc, new_dict, fn(_a, b){b})
      }
    }
  })
  |> dict.filter(fn(_key, value) {value == "O"})
  |> dict.keys()
  |> list.fold(0, fn(acc, a) { acc + a.0 + 100 * a.1 })
}

fn find_at(grid: Grid) {
  let assert Ok(at_pos) = 
  grid
  |> dict.to_list()
  |> list.find(fn(a){a.1 == "@"})
  at_pos |> pair.first()
}

fn walk(grid: Grid, point: Point, direction: Point, acc: List(#(Point, String))) {
  let p = add(point, direction)
  case dict.get(grid, point), dict.get(grid, p) {
    Ok("@"), Ok("O") -> walk(grid, p, direction, [#(p, "@")])
    Ok("O"), Ok("O") -> walk(grid, p, direction, [#(p, "O"), ..acc])
    Ok("O"), Ok(".") -> {
      let assert Ok(last) = list.last(acc)
      let first_pos = sub(last.0, direction)
      [#(p, "O"), #(first_pos, "."), ..acc]
    }
    Ok("O"), Ok("#") -> []
    Ok("@"), Ok(".") -> [#(point, "."), #(p, "@")]
    Ok("@"), Ok("#") -> []
    _, _ -> []
  }

}

fn add(f: Point, g: Point) {
  #(f.0 + g.0, f.1 + g.1)
}

fn sub(f: Point, g: Point) {
  #(f.0 - g.0, f.1 - g.1)
}


