import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/string
import simplifile.{read}

pub fn main() {
  "input.txt"
  |> parse()
  |> part2()
  |> io.debug()
}

fn parse(file path: String) {
  path
  |> read()
  |> result.unwrap("")
  |> string.replace("\n", "")
  |> string.split(" ")
  |> list.filter_map(int.parse)
}

fn part1(lst: List(Int)) {
  cache_stones(dict.new(), lst, 25)
}

fn part2(lst: List(Int)) {
  cache_stones(dict.new(), lst, 75)
}

fn cache_stones(cache: Dict(#(Int, Int), Int), lst: List(Int), blink: Int) {
  list.fold(lst, #(cache, []), fn(acc, i) {
    let #(new_dict, n) = stones_cached(acc.0, [i], blink)
    #(new_dict, list.append(acc.1, [n]))
  })
  |> pair.second()
  |> int.sum()
}

fn stones_cached(cache: Dict(#(Int, Int), Int), lst: List(Int), count: Int) {
  case count {
    0 -> #(cache, list.length(lst))
    _ -> {
      list.fold(lst, #(cache, []), fn(acc, item) {
        case dict.get(acc.0, #(item, count)) {
          Ok(result) -> #(acc.0, list.append(acc.1, [result]))
          Error(Nil) -> {
            let result = num_analyze(item)
            let #(ncache, nlist) = stones_cached(acc.0, result, count - 1)
            #(
              dict.insert(ncache, #(item, count), nlist),
              list.append(acc.1, [nlist]),
            )
          }
        }
      })
      |> pair.map_second(fn(a) { int.sum(a) })
    }
  }
}

fn num_analyze(n: Int) {
  case n {
    0 -> [1]
    n -> {
      let strn = int.to_string(n)
      let digits = string.length(strn)
      case digits % 2 == 0 {
        True -> {
          let assert Ok(n1) = string.slice(strn, 0, digits / 2) |> int.parse()
          let assert Ok(n2) =
            string.slice(strn, digits / 2, digits / 2) |> int.parse()
          [n1, n2]
        }
        False -> [n * 2024]
      }
    }
  }
}
