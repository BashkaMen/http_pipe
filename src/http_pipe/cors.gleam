import http_pipe/common.{combine}
import http_pipe/response.{set_header}

pub fn set_headers(origin, method, header) {
  combine([
    set_header("Access-Control-Allow-Origin", origin),
    set_header("Access-Control-Allow-Methods", method),
    set_header("Access-Control-Allow-Headers", header),
  ])
}

pub fn allow_any() {
  set_headers("*", "*", "*")
}
