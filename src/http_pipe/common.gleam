import gleam/list
import gleam/option.{type Option}
import gleam/string
import http_pipe/types.{type Context}

pub fn next(ctx: Context) -> Option(Context) {
  option.Some(ctx)
}

pub fn skip(_ctx: Context) -> Option(Context) {
  option.None
}

pub fn choose(handlers: List(fn(Context) -> Option(Context))) {
  fn(ctx: Context) {
    list.fold(handlers, skip(ctx), fn(state, handler) {
      option.lazy_or(state, fn() { handler(ctx) })
    })
  }
}

pub fn combine(handlers: List(fn(Context) -> Option(Context))) {
  fn(ctx: Context) {
    list.fold(handlers, next(ctx), fn(state, handler) {
      option.then(state, handler)
    })
  }
}

pub fn middleware(handler: fn(Context) -> Option(Context)) {
  fn(ctx) {
    let start = "state"
    let res = handler(ctx)
    let stop = "stop"
    res
  }
}
