import gleam/io
import gleam/result
import gleam/string
import gleam/list
import gleam/bool
import gleam/option
import gleam/dict.{type Dict}
import simplifile.{read}

pub fn main() {
  "input.txt"
  |> parse()
  |> part1(50)
  |> io.debug()
}

type Point = #(Int, Int)
type Grid(a) = Dict(a, List(Point))

fn parse(file path: String) -> Grid(String) {
  path
  |> read()
  |> result.unwrap("")
  |> string.split("\n")
  |> list.map(string.to_graphemes)
  |> list.index_fold(dict.new(), fn(acc, row, row_idx) {
    list.index_fold(row, acc, fn(grid, char, col_idx) {
      case char {
        "." -> grid
        _ ->
          grid
          |> dict.upsert(char, fn(points) {
            case points {
              option.Some(p) -> [#(row_idx, col_idx), ..p]
              option.None -> [#(row_idx, col_idx)]
            }
          })
      }
    })
  })
}

fn part1(grid: Grid(String), map_bound: Int) {
  grid
  |> dict.map_values(fn(_key, lst){
    lst 
    |> list.combination_pairs()
    |> list.flat_map(fn(pair) {
      [add(sub(pair.0, pair.1), pair.0),
       add(sub(pair.1, pair.0), pair.1)]
    })
  })
  |> dict.values()
  |> list.flatten()
  |> list.filter(fn(a){
    bool.negate(a.0 >= map_bound || a.1 >= map_bound || a.0 < 0 || a.1 < 0)
  })
  |> list.unique()
  |> list.length()
}

fn sub(f: Point, g: Point) {
  #(f.0 - g.0, f.1 - g.1)
}

fn add(f: Point, g: Point) {
  #(f.0 + g.0, f.1 + g.1)
}
