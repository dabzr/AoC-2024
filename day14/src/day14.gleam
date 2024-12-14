import gleam/io
import simplifile.{read}
import gleam/regexp
import gleam/result
import gleam/list
import gleam/int.{absolute_value}
import gleam/string
import gleam/set

pub fn main() {
  "input.txt"
  |> parse()
  |> part2(101, 103)
}

type Point = #(Int, Int)
type Robot = #(Point, Point)

fn parse(file path: String) {
  path
  |> read()
  |> result.unwrap("")
  |> string.split("\n")
  |> list.filter_map(fn (c) {
    let assert Ok(re) = regexp.from_string("[^\\d-]")
    case regexp.split(re, c) |> list.filter_map(int.parse) {
      [] -> Error(Nil)
      a -> Ok(a)
    }
  })
  |> list.map(make_pairs)
}

fn make_pairs(lst: List(Int)) {
  let assert [first, second, third, fourth] = lst
  #(#(first, second), #(third, fourth))
}

fn part1(input: List(Robot), grid_width: Int, grid_height: Int) {
  input
  |> list.map(fn(a){ walk(a, grid_width, grid_height, 100) })
  |> list.filter(fn(a) {!{{a.0 == grid_width/2} || {a.1 == grid_height/2}}})
  |> count_elements(grid_width, grid_height)
}

fn part2(input: List(Robot), grid_width: Int, grid_height: Int) {
  use i <- list.map(list.range(0, 10000))
  let str =
  input
  |> list.map(fn(a){ walk(a, grid_width, grid_height, i) })
  |> draw_grid(grid_width, grid_height)
  case string.contains(str, "###############################"){
    True -> {
      io.println(str)
      io.println(int.to_string(i))
    }
    False -> Nil
  }
}

fn draw_grid(positions: List(Point), grid_width: Int, grid_height: Int) {
  let s = set.from_list(positions)
  list.range(0, {grid_width-1})
  |> list.flat_map(fn(i) {
    list.range(0, {grid_height-1})
    |> list.map(fn(j) {
      case set.contains(s, #(j, i)) {
        True -> "#"
        False -> "."
      }
    })
    |> list.append(["\n"])
  })
  |> string.concat()
}

fn walk(robot: Robot, grid_width: Int, grid_height: Int, seconds: Int) -> Point {
  let #(x, y) = add(robot.0, robot.1 |> times(seconds))
  let x_limit = grid_width * seconds
  let y_limit = grid_height * seconds
  case x >= 0, y >= 0 {
    True, True -> #(x%grid_width, y%grid_height)
    False, False -> #({x+x_limit}%grid_width, {y+y_limit}%grid_height)
    False, True -> #({x+x_limit}%grid_width, y%grid_height)
    True, False -> #(x%grid_width, {y+y_limit}%grid_height)
  }
}

fn count_elements(positions: List(Point), grid_width: Int, grid_height:Int) {
  list.range(0, 3)
  |> list.map(fn(i) { count_element_in_quadrant(positions, i, grid_width, grid_height) })
  |> int.product()
}

fn count_element_in_quadrant(positions: List(Point), q: Int, grid_width: Int, grid_height: Int) {
  let medw = grid_width/2
  let medy = grid_height/2
  positions 
  |> list.count(fn(a){ is_in_quadrant(a, to_quadrant(q), medw, medy) })
}

fn to_quadrant(q: Int) {
  case q {
    1 -> #(0, 1)
    2 -> #(1, 0)
    3 -> #(1, 1)
    _ -> #(0, 0)
  }
}

fn is_in_quadrant(p: Point, quadrant: Point, mw: Int, mh: Int) {
  let condx = {p.0 >= quadrant.0*mw} && {p.0 <= {quadrant.0+1}*mw}
  let condy = {p.1 >= quadrant.1*mh} && {p.1 <= {quadrant.1+1}*mh}
  condx && condy
}

fn add(f: Point, g: Point) {
  #(f.0 + g.0, f.1 + g.1)
}

fn times(f: Point, num: Int) {
  #(f.0*num, f.1*num)
}


