import gleam/io
import gleam/regexp.{split}
import gleam/result.{unwrap}
import simplifile.{read}

pub fn main() {
  let lst =
    "input.txt"
    |> read()
    |> unwrap("")
    |> parse_input()
    |> io.debug()
}

fn parse_input(s: String) {
  let assert Ok(re) = regexp.from_string("mul\\(\\d+,\\d+\\)")
  split(with: re, content: s)
}
