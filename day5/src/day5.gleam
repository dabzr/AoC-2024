import gleam/io
import simplifile.{read}
import gleam/result
import gleam/string
import gleam/list
import gleam/int
import gleam/bool
import gleam/set.{type Set}
import gleam/dict.{type Dict}
pub fn main() {
  let #(t0, t1) = "input.txt" |> parse()
  t0 
  |> parse_pair()
  |> fn(a) {part1(a, t1)}
  |> io.debug() 
}

fn parse(path: String){
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

fn parse_pair(lista: List(#(String, String))) {
  lista 
  |> list.unzip()
  |> fn(a) {a.1}
  |> list.unique()
  |> list.map(fn(a){
    lista 
    |> list.filter_map(fn(b) {
      case a == b.1 {
        True -> Ok(b.0)
        False -> Error(Nil)
      }
    })
    |> set.from_list()
    |> fn(b) {#(a,b)}
  })
  |> dict.from_list()
}

fn part1(dic: Dict(String, Set(String)), lst: List(List(String))) {
  lst 
  |> list.filter(fn(a) {aux(dic, a)})
  |> list.filter_map(fn(a) {
    a |> list.filter_map(int.parse) |> at(list.length(a)/2)
  })
  |> int.sum()
}

fn aux(dic: Dict(String, Set(String)), lst: List(String)) {
  case lst {
    [] | [_] -> True
    [first, ..rest] -> {
      let rset = rest |> set.from_list()
      let dset = dic |> dict.get(first) |> result.unwrap(rset)
      rset |> set.intersection(dset) |> set.is_empty() |> bool.and(aux(dic, rest))
    }
  }
}

fn at(lst, idx) {
  case lst {
    [v] -> case idx {
      0 -> Ok(v)
      _ -> Error(Nil)
    }
    [first, ..rest] -> case idx {
      0 -> Ok(first)
      _ -> at(rest, idx-1)
    }
    _ -> Error(Nil)
  }
}
