import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile.{read}

type PageRules(a) =
  Dict(a, Set(a))

pub fn main() {
  let #(t0, t1) = "input.txt" |> parse()
  t0
  |> parse_pair()
  |> fn(a) { #(part1(a, t1), part2(a, t1)) }
  |> io.debug()
}

fn parse(path: String) {
  let tuple =
    path
    |> read()
    |> result.unwrap("")
    |> string.split_once("\n\n")
    |> result.unwrap(#("", ""))
  let t0 =
    tuple.0
    |> string.split("\n")
    |> list.filter_map(fn(a) { a |> string.split_once("|") })
  let t1 =
    tuple.1
    |> string.split("\n")
    |> list.map(fn(a) { a |> string.split(",") })
  #(t0, t1)
}

fn parse_pair(lista: List(#(String, String))) {
  lista
  |> list.unzip()
  |> fn(a) { a.1 }
  |> list.unique()
  |> list.map(fn(a) {
    lista
    |> list.filter_map(fn(b) {
      case a == b.1 {
        True -> Ok(b.0)
        False -> Error(Nil)
      }
    })
    |> set.from_list()
    |> fn(b) { #(a, b) }
  })
  |> dict.from_list()
}

fn part1(dic: PageRules(String), lst: List(List(String))) {
  lst
  |> list.filter(fn(a) { is_valid(a, dic) })
  |> list.filter_map(fn(a) {
    a |> list.filter_map(int.parse) |> at(list.length(a) / 2)
  })
  |> int.sum()
}

fn part2(dic: PageRules(String), lst: List(List(String))) {
  lst
  |> list.filter(fn(a) { is_valid(a, dic) |> bool.negate() })
  |> list.map(fn(a) { a |> correct_list(dic, 0) })
  |> list.filter_map(fn(a) {
    a |> list.filter_map(int.parse) |> at(list.length(a) / 2)
  })
  |> int.sum()
}

fn correct_list(lst: List(String), dic: PageRules(String), idx: Int) {
  case idx == list.length(lst) - 1 {
    True -> lst
    False -> {
      let invset = get_invalids_after_index(lst, dic, idx)
      case set.is_empty(invset) {
        True -> lst |> correct_list(dic, { idx + 1 })
        False ->
          [
            list.take(lst, idx),
            invset |> set.to_list(),
            list.drop(lst, idx)
              |> list.filter(fn(a) { set.contains(invset, a) |> bool.negate() }),
          ]
          |> list.flatten()
          |> correct_list(dic, idx)
      }
    }
  }
}

fn is_valid(lst: List(String), dic: PageRules(String)) {
  case lst {
    [] -> True
    [first, ..rest] -> {
      let rset = rest |> set.from_list()
      let dset = dic |> dict.get(first) |> result.unwrap(rset)
      rset
      |> set.intersection(dset)
      |> set.is_empty()
      |> bool.and(is_valid(rest, dic))
    }
  }
}

fn get_invalids_after_index(lst: List(String), dic: PageRules(String), idx: Int) {
  case lst |> list.drop(idx) {
    [first, ..rest] -> {
      let rset = rest |> set.from_list()
      let dset =
        dic |> dict.get(first) |> result.unwrap(set.from_list(["OIIII"]))
      rset |> set.intersection(dset)
    }
    _ -> set.new()
  }
}

fn at(xs: List(a), k: Int) -> Result(a, Nil) {
  case xs, k {
    [x, ..], 0 -> Ok(x)
    [_, ..xs], k -> at(xs, k - 1)
    [], _ -> Error(Nil)
  }
}
