import gleam/bit_array
import gleam/option.{type Option}
import gleeunit/should
import http_pipe/common.{choose, combine}
import http_pipe/context.{from_request}
import http_pipe/response.{
  empty, not_found, set_code, set_header, write_body_utf8, write_utf8,
}
import http_pipe/router.{get, post}
import http_pipe/types.{type Context, Request, Response}

pub fn run(app: fn(Context) -> Option(Context), req) {
  from_request(req)
  |> app
  |> option.map(fn(x) { x.response })
}

pub fn empty_app_test() {
  let app = choose([])
  let req = Request(method: "GET", path: "/", headers: [])
  run(app, req)
  |> should.be_none
}

pub fn not_found_test() {
  let app = choose([not_found()])
  let req = Request(method: "GET", path: "/", headers: [])
  run(app, req)
  |> should.be_some
  |> should.equal(Response(bit_array.from_string("not found"), 404, []))
}

pub fn router_works_test() {
  let app =
    choose([
      combine([get("/path"), write_body_utf8("get-/path")]),
      combine([get("/path-200"), write_utf8(200, "get-/path-200")]),
      combine([get("/path1"), set_code(200), write_body_utf8("get-/path1")]),
      combine([post("/path"), set_code(204), write_body_utf8("post-/path")]),
      not_found(),
    ])

  let check = fn(path, method, expected_code, expected_body) {
    let req = Request(method: method, path: path, headers: [])
    run(app, req)
    |> should.be_some
    |> fn(res) {
      res.body |> should.equal(bit_array.from_string(expected_body))
      res.code |> should.equal(expected_code)
    }
  }

  check("/path", "GET", 201, "get-/path")
  check("/path-200", "GET", 200, "get-/path-200")
  check("/path1", "GET", 200, "get-/path1")
  check("/path", "POST", 204, "post-/path")

  check("/path", "PATH", 404, "not found")
  check("/404", "POST", 404, "not found")
  check("/404", "GET", 404, "not found")
}

pub fn set_header_test() {
  let app = set_header("header", "value")
  let req = Request("/api", "GET", [])
  run(app, req)
  |> should.be_some
  |> should.equal(Response(..empty(), headers: [#("header", "value")]))
}
