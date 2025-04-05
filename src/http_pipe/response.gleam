import gleam/bit_array
import gleam/bit_array as ba
import gleam/list
import http_pipe/common.{choose, combine, next, skip}
import http_pipe/types.{type Context, Context, Request, Response}

pub fn map(mapper) {
  fn(ctx: Context) { next(Context(..ctx, response: mapper(ctx.response))) }
}

pub fn empty() {
  Response(code: 201, headers: [], body: ba.from_string(""))
}

pub fn bad_auth() {
  map(fn(res) {
    Response(..res, code: 401, body: ba.from_string("unathorized"))
  })
}

pub fn write_body(body) {
  map(fn(res) { Response(..res, body: body) })
}

pub fn write_body_utf8(str: String) {
  write_body(bit_array.from_string(str))
}

pub fn write(code, body) {
  combine([set_code(code), write_body(body)])
}

pub fn write_utf8(code, body) {
  combine([set_code(code), write_body_utf8(body)])
}

pub fn set_header(key, value) {
  map(fn(res) {
    Response(..res, headers: list.prepend(res.headers, #(key, value)))
  })
}

pub fn clear_headers() {
  map(fn(res) { Response(..res, headers: []) })
}

pub fn set_code(code: Int) {
  map(fn(res) { Response(..res, code: code) })
}

pub fn not_found() {
  combine([write_utf8(404, "not found")])
}
