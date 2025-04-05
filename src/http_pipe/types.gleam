import gleam/dict
import gleam/dynamic

pub type Request {
  Request(
    path: String,
    method: String,
    body: BitArray,
    headers: List(#(String, String)),
  )
}

pub type Response {
  Response(body: BitArray, code: Int, headers: List(#(String, String)))
}

pub type Context {
  Context(
    request: Request,
    response: Response,
    data: dict.Dict(String, dynamic.Dynamic),
  )
}
