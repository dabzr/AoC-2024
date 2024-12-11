import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

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
    |> string.replace("\n", "")
    |> string.split(" ")
    |> list.filter_map(int.parse)
}

fn part1(lst: List(Int)) {
  stones(lst, 25)
}

fn part2(lst: List(Int)) {
  stones(lst, 75)
}

fn stones(lst: List(Int), count: Int) {
  case count {
    0 -> list.length(lst)
    _ -> list.flat_map(lst, num_analyze) |> stones(count-1)
  }
}

fn num_analyze(n: Int) {
    case n {
        0 -> [1]
        n -> {
            let strn = int.to_string(n)
            let digits = string.length(strn)
            case digits%2 == 0 {
              True -> {
                let assert Ok(n1) = string.slice(strn, 0, digits/2) |> int.parse()
                let assert Ok(n2) = string.slice(strn, digits/2, digits/2) |> int.parse()
                [n1, n2]
              }
              False -> [n*2024]
            }
        }
    }
}
