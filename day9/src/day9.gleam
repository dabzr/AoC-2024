import gleam/io
import gleam/result
import gleam/string
import gleam/list
import gleam/int
import gleam/option
import gleam/pair
import gleam/deque
import gleam/dict.{type Dict}
import simplifile.{read}


type MemMap = Dict(Int, List(Int))

pub fn main() {
  "input.txt"
  |> parse()
  |> part1()
  |> io.debug()
}

fn parse(file path: String) {
  path
  |> read()
  |> result.unwrap("")
  |> string.replace("\n", "")
  |> string.to_graphemes()
  |> list.index_fold(#(dict.new(),0), fn(acc, item, index) {
    case index%2 == 0 {
      True -> {
        let assert Ok(p) = int.parse(item)
        let poslst = list.range(0, {p-1}) |> list.map(fn(a){a+acc.1})
        #(dict.insert(acc.0, index/2, poslst), {acc.1+p})
      }
      False -> {
        let assert Ok(p) = int.parse(item)
        let poslst =
          case p == 0 {
          False -> list.range(0, {p-1}) |> list.map(fn(a){a+acc.1})
          True -> []
        }
        let dic = dict.upsert(acc.0, -1, fn(x){
          case x {
            option.Some(v) -> list.flatten([v, poslst])
            option.None -> poslst
          }
        })
        #(dic, {acc.1+p})
      }
    }
  })
  |> pair.first()
}

fn part1(dic: MemMap){ 
  let enqueded_dict = dict.map_values(dic, fn(_key, value) { deque.from_list(value) })
  let num = dict.keys(dic) |> max_list() 
  let memmap =
  list.range(num, 0)
  |> list.fold(enqueded_dict, fn(acc, key) {
    let assert Ok(empty_space_deque) = dict.get(acc, -1)
    let assert Ok(num_deque) = dict.get(acc, key)
    let #(new_edq, new_ndq) = 
    list.range(1, deque.length(num_deque))
    |> list.fold_until(#(empty_space_deque, num_deque), fn(acc, _){
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
    dict.upsert(acc, -1, fn(x) {
      case x {
        option.Some(i) -> new_edq
        option.None -> new_edq
      }
    })
    |>
    dict.upsert(key, fn(y) {
      case y {
        option.Some(i) -> new_ndq
        option.None -> new_ndq
      }
    })
  })
  list.range(0, num)
  |> list.flat_map(fn(i){
    let assert Ok(lst) = dict.get(memmap, i)
    list.map(deque.to_list(lst), fn(j){i*j})
  })
  |> int.sum()
}

fn max_list(lst: List(Int)) {
  lst |> list.fold(0, int.max)
}

