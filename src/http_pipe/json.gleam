import http_pipe/common.{choose, combine}
import http_pipe/response.{set_code, set_header}

pub fn write_body_utf8(json: String) {
  combine([
    set_header("Content-Type", "application/json"),
    response.write_body_utf8(json),
  ])
}

pub fn write_body(encoder, obj) {
  write_body_utf8(encoder(obj))
}

pub fn write_utf8(code, json) {
  combine([set_code(code), write_body_utf8(json)])
}

pub fn write(code, encoder, obj) {
  write_utf8(code, encoder(obj))
}
