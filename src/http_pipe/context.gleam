import gleam/dict
import http_pipe/response.{empty}
import http_pipe/types.{type Context, Context}

pub fn from_request(req) {
  Context(request: req, response: empty(), data: dict.new())
}
