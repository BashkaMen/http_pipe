import gleam/string
import http_pipe/common.{choose, combine, next, skip}
import http_pipe/types.{type Context}

pub fn route(path: String) {
  fn(ctx: Context) {
    case string.lowercase(path) == string.lowercase(ctx.request.path) {
      True -> next(ctx)
      _ -> skip(ctx)
    }
  }
}

pub fn method(method: String) {
  fn(ctx: Context) {
    case string.uppercase(method) == string.uppercase(ctx.request.method) {
      True -> next(ctx)
      _ -> skip(ctx)
    }
  }
}

pub fn get(path) {
  combine([method("GET"), route(path)])
}

pub fn post(path) {
  combine([method("POST"), route(path)])
}

pub fn delete(path) {
  combine([method("DELETE"), route(path)])
}

pub fn path(path) {
  combine([method("PATH"), route(path)])
}

pub fn put(path) {
  combine([method("PUT"), route(path)])
}
