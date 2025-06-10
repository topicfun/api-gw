local cjson = require "cjson.safe"

ngx.req.read_body()
local req_body = ngx.var.request_body or ""
local req_headers = ngx.req.get_headers()
local resp_headers = ngx.resp.get_headers()
local resp_body = ngx.ctx.resp_body or ""

local log_entry = {
  request = {
    method = ngx.req.get_method(),
    uri = ngx.var.request_uri,
    headers = req_headers,
    body = req_body
  },
  response = {
    status = ngx.status,
    headers = resp_headers,
    body = resp_body
  }
}

local f, err = io.open("/var/log/nginx/application.log", "a")
if f then
  f:write(cjson.encode(log_entry), "\n")
  f:close()
end
