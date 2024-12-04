import gleam/io
import gleam/regexp.{scan}
import gleam/result.{unwrap}
import gleam/list.{map, filter_map, first, last}
import simplifile.{read}
import gleam/int
import gleam/string.{split}
pub fn main() {
  "input.txt"
  |> read()
  |> unwrap("")
  |> string.replace("\n", "")
  |> part1_no_regex()
  |> io.debug()
}

fn part1(s: String) {
  let assert Ok(re) = regexp.from_string("mul\\(\\d{1,3},\\d{1,3}\\)")
  scan(with: re, content: s)
  |> map(fn(a){
    let assert Ok(r) = regexp.from_string("\\d{1,3}")
    scan(with: r, content: a.content)
    |> filter_map(fn(b){
      int.parse(b.content)
    })
    |> fn (b) {unwrap(first(b), 0) * unwrap(last(b), 0)}
  })
  |> int.sum()

}

fn part2(s: String) {
  let assert Ok(re) = regexp.from_string("don't\\(\\).*?(do\\(\\)|$)")
  regexp.replace(re, s, "")
  |> part1()
}

// WORK IN PROGRESS
fn part1_no_regex(s: String) {
  s
  |> split("mul(")
  |> filter_map(fn(a) { a |> split(")") |> first()})
  |> filter_map(fn(a) { 
    let b = a |> split(",") |> filter_map(int.parse)
    case b {
      [first, second] -> Ok(first * second)
      _               -> Error(Nil)
    }
  })
  |> int.sum()
}

