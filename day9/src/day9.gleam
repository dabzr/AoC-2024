import gleam/bool
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import simplifile.{read}

type MemMap =
  Dict(Int, List(Int))

pub fn main() {
  "input.txt"
  |> parse()
  |> pair.first()
  |> part2()
  |> io.debug()
}

fn parse(file path: String) {
  let num_list =
    path
    |> read()
    |> result.unwrap("")
    |> string.replace("\n", "")
    |> string.to_graphemes()
  use acc, item, index <- list.index_fold(num_list, #(dict.new(), 0))
  case index % 2 == 0 {
    True -> {
      let assert Ok(p) = int.parse(item)
      let poslst = list.range(0, { p - 1 }) |> list.map(fn(a) { a + acc.1 })
      #(dict.insert(acc.0, index / 2, poslst), { acc.1 + p })
    }
    False -> {
      let assert Ok(p) = int.parse(item)
      let poslst = case p == 0 {
        False -> list.range(0, { p - 1 }) |> list.map(fn(a) { a + acc.1 })
        True -> []
      }
      let dic =
        dict.upsert(acc.0, -1, fn(x) {
          case x {
            option.Some(v) -> list.flatten([v, poslst])
            option.None -> poslst
          }
        })
      #(dic, { acc.1 + p })
    }
  }
}

fn part1(dic: MemMap) {
  let enqueded_dict =
    dict.map_values(dic, fn(_key, value) { deque.from_list(value) })
  let num = dict.keys(dic) |> max_list()
  list.range(num, 0)
  |> list.fold(enqueded_dict, fn(acc, key) {
    let assert Ok(empty_space_deque) = dict.get(acc, -1)
    let assert Ok(num_deque) = dict.get(acc, key)
    let #(new_edq, new_ndq) =
      list.range(1, deque.length(num_deque))
      |> list.fold_until(#(empty_space_deque, num_deque), fn(acc, _) {
        let assert Ok(nq) = deque.pop_back(acc.1)
        let assert Ok(esq) = deque.pop_front(acc.0)
        case nq.0 > esq.0 {
          True -> {
            let new_esq = esq |> pair.second() |> deque.push_back(nq.0)
            let new_nq = nq |> pair.second() |> deque.push_front(esq.0)
            list.Continue(#(new_esq, new_nq))
          }
          False -> list.Stop(acc)
        }
      })
    dict.upsert(acc, -1, fn(_) { new_edq })
    |> dict.upsert(key, fn(_) { new_ndq })
  })
  |> dict.map_values(fn(_key, value) { deque.to_list(value) })
  |> checksum(num)
}

fn checksum(dic: Dict(Int, List(Int)), max_element: Int) {
  list.range(0, max_element)
  |> list.flat_map(fn(i) {
    let assert Ok(lst) = dict.get(dic, i)
    list.map(lst, fn(j) { i * j })
  })
  |> int.sum()
}

fn sequential_space(lst: List(Int), space: Int) {
  lst
  |> list.window(space)
  |> list.filter(is_sequential)
  |> list.first()
}

fn is_sequential(lst: List(Int)) {
  case list.first(lst), list.last(lst) {
    Ok(first), Ok(last) -> lst == list.range(first, last)
    _, _ -> False
  }
}

fn part2(dic: MemMap) {
  let num = dict.keys(dic) |> max_list()
  list.range(num, 0)
  |> list.fold(dic, fn(acc, key) {
    let assert Ok(empty_space_deque) = dict.get(acc, -1)
    let assert Ok(num_deque) = dict.get(acc, key)
    let #(new_edq, new_ndq) = case
      sequential_space(empty_space_deque, list.length(num_deque))
    {
      Ok(pos) -> {
        let assert Ok(first) = list.first(pos)
        let assert Ok(f) = list.first(num_deque)
        case first < f {
          True -> {
            let new_empty_space =
              empty_space_deque
              |> list.filter(fn(a) { list.contains(pos, a) |> bool.negate() })
              |> list.append(num_deque)
              |> list.sort(int.compare)
            #(new_empty_space, pos)
          }
          False -> #(empty_space_deque, num_deque)
        }
      }
      _ -> #(empty_space_deque, num_deque)
    }
    dict.upsert(acc, -1, fn(_) { new_edq })
    |> dict.upsert(key, fn(_) { new_ndq })
  })
  |> checksum(num)
}

fn max_list(lst: List(Int)) {
  lst |> list.fold(0, int.max)
}
