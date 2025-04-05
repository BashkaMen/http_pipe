import gleam/bit_array
import http_pipe/common.{next, skip}
import http_pipe/response.{map}
import http_pipe/types.{type Context, Response}

pub fn bad_auth() {
  map(fn(res) {
    Response(..res, code: 401, body: bit_array.from_string("unathorized"))
  })
}

pub fn require(checker, good_auth_handler, bad_auth_handler) {
  fn(ctx: Context) {
    case checker(ctx) {
      Ok(data) -> good_auth_handler(data)(ctx)
      Error(e) -> bad_auth_handler(e)(ctx)
    }
  }
}

pub fn simple(checker) {
  let good = fn(_) { next }
  let bad = fn(_) { bad_auth() }

  require(checker, good, bad)
}
