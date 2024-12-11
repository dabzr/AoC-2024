import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

pub fn main() {
  todo
}

fn parse(file path: String) {
    path
    |> read()
    |> result.unwrap("")
    |> string.replace("\n", "")
    |> string.split(" ")
    |> list.map(int.parse)
}

fn num_analyze(n: Int) {
    case n {
        0 -> [1]
        n -> {
            let num 
        }
    }
}