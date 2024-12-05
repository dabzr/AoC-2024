import gleam/io
import simplifile.{read}
import gleam/result
import gleam/string
import gleam/list
pub fn main() {
  "input.txt"
  |> parse()
  |> io.debug()
}

pub fn parse(path: String){
  let tuple = path
  |> read()
  |> result.unwrap("")
  |> string.split_once("\n\n")
  |> result.unwrap(#("", ""))
  let t0 = tuple.0
  |> string.split("\n")
  |> list.filter_map(fn(a) { a |> string.split_once("|") })
  let t1 = tuple.1
  |> string.split("\n")
  |> list.map(fn (a) {a |> string.split(",")})
  #(t0, t1)
}

pub fn parse_pair(p: List(#(String, String))) {
  todo
}


