import gleam/io
import gleam/regexp.{scan}
import gleam/result.{unwrap}
import gleam/list
import simplifile.{read}
import gleam/int
import gleam/string
pub fn main() {
  "input.txt"
  |> read()
  |> unwrap("")
  |> string.replace("\n", "")
  |> part2()
  |> io.debug()
}

fn part1(s: String) {
  let assert Ok(re) = regexp.from_string("mul\\(\\d{1,3},\\d{1,3}\\)")
  scan(with: re, content: s)
  |> list.map(fn(a){
    let assert Ok(r) = regexp.from_string("\\d{1,3}")
    scan(with: r, content: a.content)
    |> list.filter_map(fn(b){
      int.parse(b.content)
    })
    |> fn (b) {unwrap(list.first(b), 0) * unwrap(list.last(b), 0)}
  })
  |> int.sum()

}

fn part2(s: String) {
  let assert Ok(re) = regexp.from_string("don't\\(\\).*?(do\\(\\)|$)")
  regexp.replace(re, s, "")
  |> part1()
}

