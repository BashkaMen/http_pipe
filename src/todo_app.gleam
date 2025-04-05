import birl
import gleam/bit_array
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/io
import gleam/json as gj
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import http_pipe/auth
import http_pipe/common.{choose, combine}
import http_pipe/context.{from_request}
import http_pipe/cors
import http_pipe/json
import http_pipe/response.{
  empty, not_found, set_code, set_header, write_body_utf8, write_utf8,
}
import http_pipe/router.{get, method, post}
import http_pipe/types.{type Context, type Request, type Response, Context}

pub fn auth_check(ctx: Context) {
  let headers = ctx.request.headers
  use auth_token <- result.try(list.key_find(headers, "Authorization"))
  //todo parse jwt or other validation
  Ok(Nil)
}

pub type Echo {
  Echo(message: String)
}

fn my_app() {
  let start = birl.to_iso8601(birl.now())
  combine([
    // all responses with 'Server' header
    set_header("Server", "http_pipe"),
    choose([
      combine([method("OPTIONS"), cors.allow_any()]),
      combine([get("/"), write_utf8(200, "start time: " <> start)]),
      combine([get("/hello"), write_utf8(200, "hello")]),
      combine([post("/json"), json.write_body(echo_encoder, Echo("hello"))]),
      combine([post("/json-handler"), simple_json_handler]),
      combine([
        post("/api/auth"),
        auth.simple(auth_check),
        write_utf8(200, "hello"),
      ]),
      not_found(),
    ]),
  ])
}

pub fn simple_json_handler(ctx: Context) {
  let json =
    ctx.request.body |> bit_array.to_string |> result.unwrap("invalid data")
  let model = echo_decoder(json)

  json.write_body(echo_encoder, Echo(string.reverse(model.message)))(ctx)
}

pub fn main() {
  let app = my_app()

  start_server(app, 5000)
}

pub fn start_server(app: fn(Context) -> Option(Context), port: Int) {
  todo
  // integrate with custom http server
}

pub fn parse_request() -> Request {
  todo
}

pub fn echo_encoder(x: Echo) -> String {
  gj.object([#("message", gj.string(x.message))])
  |> gj.to_string
}

pub fn echo_decoder(json: String) -> Echo {
  let decoder = {
    use message <- decode.field("message", decode.string)
    decode.success(Echo(message))
  }
  gj.parse(json, decoder)
  |> result.lazy_unwrap(fn() { panic("error json") })
}
