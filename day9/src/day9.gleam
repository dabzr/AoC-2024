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
  "example.txt"
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
        let poslst = list.range(0, {p-1}) |> list.map(fn(a){a+acc.1})
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
  list.range(num, 0)
}

fn max_list(lst: List(Int)) {
  lst |> list.fold(0, int.max)
}
