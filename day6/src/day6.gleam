import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile.{read}

pub fn main() {
  parse(file: "input.txt")
  |> fn(a) {
    part1(a) |> io.debug()
    part2(a) |> io.debug()
  }
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

fn part1(map: Grid(String)) {
  let pos = get_initial_position(map)
  walk(map, at: pos, looking_for: #(0, -1), and: set.new())
  |> set.size()
}

fn part2(map: Grid(String)) {
  let pos = get_initial_position(map)
  walk(map, at: pos, looking_for: #(0, -1), and: set.new())
  |> set.filter(fn(a) { a != pos })
  |> set.filter(fn(a) {
    let new_map = dict.insert(map, a, "#")
    is_in_loop(new_map, pos, #(0, -1), set.new())
  })
  |> set.size()
}

fn is_in_loop(
  map: Grid(String),
  position: Point,
  direction: Point,
  past: Set(#(Point, Point)),
) {
  case set.contains(past, #(position, direction)) {
    True -> True
    False -> {
      case map |> dict.get(position) {
        Ok(v) -> {
          let #(new_pos, new_direction, pset) =
            walk_teste(v, position, direction, past)
          is_in_loop(map, new_pos, new_direction, pset)
        }
        Error(_) -> False
      }
    }
  }
}

fn walk_teste(
  char: String,
  position: Point,
  direction: Point,
  past: Set(#(Point, Point)),
) {
  let new_direction = get_direction(char, direction)
  let #(new_position, pset) = case new_direction != direction {
    True -> #(sub(position, direction), past)
    False -> #(
      add(position, direction),
      set.insert(past, #(position, direction)),
    )
  }
  #(new_position, new_direction, pset)
}

fn get_initial_position(map: Grid(String)) {
  list.range(0, 129)
  |> list.map(fn(i) {
    list.range(0, 129)
    |> list.filter_map(fn(j) {
      case dict.get(map, #(j, i)) {
        Ok("^") -> Ok(#(j, i))
        _ -> Error(Nil)
      }
    })
  })
  |> list.flatten()
  |> list.first()
  |> result.unwrap(#(0, 0))
}

fn walk(
  map: Grid(String),
  at position: Point,
  looking_for direction: Point,
  and past: Set(Point),
) {
  case map |> dict.get(position) {
    Ok(v) -> {
      let new_direction = get_direction(v, direction)
      let #(new_position, pset) = case new_direction != direction {
        True -> #(sub(position, direction), past)
        False -> #(add(position, direction), set.insert(past, position))
      }
      walk(map, at: new_position, looking_for: new_direction, and: pset)
    }
    Error(_) -> past
  }
}

fn get_direction(char: String, direction: Point) {
  case char {
    "#" -> turn(at: direction)
    _ -> direction
  }
}

fn turn(at direction: Point) {
  case direction {
    #(0, -1) -> #(1, 0)
    #(0, 1) -> #(-1, 0)
    #(1, 0) -> #(0, 1)
    #(-1, 0) -> #(0, -1)
    _ -> #(0, 0)
  }
}

fn sub(f: Point, g: Point) {
  #(f.0 - g.0, f.1 - g.1)
}

fn add(f: Point, g: Point) {
  #(f.0 + g.0, f.1 + g.1)
}
