import gleam/io
import gleam/result
import gleam/string
import simplifile.{read}
import gleam/dict.{type Dict}
import gleam/list
import gleam/set.{type Set}
import gleam/erlang/process

pub fn main() {
  parse(file: "input.txt")
  |> part1()
  |> io.debug()
}

type Point =
  #(Int, Int)

type Grid(a) =
  Dict(Point, a)

fn parse(file path: String) {
  path
  |> read()
  |> result.unwrap("")
  |> string.split("\n")
  |> list.index_map(fn(a, i) {
    a
    |> string.to_graphemes()
    |> list.index_map(fn(b, j) { #(#(j, i), b) })
  })
  |> list.flatten()
  |> dict.from_list()
}

fn get_initial_position(map: Grid(String)) {
    list.range(0, 129)
    |> list.map(fn(i) {
      list.range(0, 129)
      |> list.filter_map(fn(j) {
        case dict.get(map, #(j, i)) {
          Ok("^") -> Ok(#(j, i))
          _  -> Error(Nil)
        }
      })
    })
    |> list.flatten()
    |> list.first()
    |> result.unwrap(#(0, 0))
}

fn part1(map: Grid(String)) {
  let pos = get_initial_position(map)
  walk(map, at: pos, looking_for: #(0,-1), and: set.new())
  |> set.size()
}

fn walk(
  map: Grid(String),
  at position: Point,
  looking_for direction: Point,
  and past: Set(Point)
) {
  case map |> dict.get(position) {
      Ok(v) -> {
        let new_direction = get_direction(v, direction)
        let #(new_position, pset) = 
          case new_direction != direction {
            True -> #(sub(position, direction), past) 
            False -> #(add(position, direction), set.insert(past, position)) 
          }
        walk(map, at: new_position, looking_for: new_direction, and: pset) 
      } 
      Error(_) -> past
  }
}

fn get_direction(char: String, direction: Point){
  case char {
    "#" -> turn(at: direction)
    _ -> direction
  }
}

fn turn(at direction: Point) {
  case direction {
    #(0,-1)  -> #(1,0)
    #(0,1)   -> #(-1,0)
    #(1,0)   -> #(0,1)
    #(-1, 0) -> #(0,-1)
    _ -> #(0, 0)
  }
}

fn sub(f: Point, g: Point){
  #(f.0-g.0, f.1-g.1)
}

fn add(f: Point, g: Point){
  #(f.0+g.0, f.1+g.1)
}