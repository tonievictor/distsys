import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/yielder.{filter, from_list, map, to_list}

pub fn main() {
  from_list([
    1, 4, 6, 7, 75_654_596_987_987_976_987, 68_756_756_757_657_656_987,
    98_789_798_798_789_796_546, 54_654_564_217_541_236_547,
    65_421_378_512_736_521_765, 73_658_765_123_765_123_786,
    512_378_657_852_319_179,
  ])
  |> map(fn(x) { is_prime(x) })
  |> filter(fn(x) { x > 0 })
  |> to_list
  |> io.debug
}

fn is_prime(n) -> Int {
  let subj = process.new_subject()
  case n {
    0 -> 0
    1 | 2 | 3 -> n
    _ -> {
      process.start(
        fn() {
          let v = fermat(n)
          process.send(subj, v)
        },
        False,
      )
      case process.receive(subj, 1000) {
        Ok(v) -> {
          case v {
            Some(v) -> {
              v
            }
            None -> 0
          }
        }
        Error(_) -> 0
      }
    }
  }
}

fn fermat(n: Int) -> Option(Int) {
  let a = random(n - 1)
  let exp = get_exp(a, n - 1)
  case int.modulo(exp, n) {
    Ok(v) -> {
      case v {
        1 -> Some(n)
        _ -> None
      }
    }
    Error(_) -> None
  }
}

fn get_exp(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    1 -> base
    i if i % 2 == 0 -> get_exp(base * base, exp / 2)
    _ -> {
      let diff = exp - 1
      base * get_exp(base * base, diff / 2)
    }
  }
}

@external(erlang, "rand", "uniform")
pub fn random(x: Int) -> Int
