import gleam/dynamic.{type Dynamic}
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/result
import http_pipe/auth
import http_pipe/common.{choose, combine}
import http_pipe/context.{from_request}
import http_pipe/cors.{allow_any}
import http_pipe/response.{
  empty, not_found, set_code, set_header, write_body_utf8, write_utf8,
}
import http_pipe/router.{get, method, post}
import http_pipe/types.{type Context, type Request, type Response, Context}

pub fn my_app() {
  choose([
    combine([method("OPTIONS"), allow_any()]),
    combine([get("/api/hello"), write_utf8(200, "hello")]),
    combine([post("/api/v2/hello"), write_utf8(200, "hello-v2")]),
    combine([
      post("/api/auth"),
      auth.simple(auth_check),
      write_utf8(200, "hello"),
    ]),
    not_found(),
  ])
}

pub fn auth_check(ctx: Context) {
  let headers = ctx.request.headers
  use auth_token <- result.try(list.key_find(headers, "Authorization"))
  //todo parse jwt or other validation
  Ok(Nil)
}

pub fn main() {
  start_server(my_app(), 5000)
}

pub fn start_server(app: fn(Context) -> Option(Context), port: Int) {
  todo
  // integrate with custom http server
}

pub fn parse_request() -> Request {
  todo
}
