local cjson = require "cjson.safe"

-- configuration flags from the environment; defaults to true
local include_headers = os.getenv("APP_LOG_INCLUDE_HEADERS")
if include_headers == nil or include_headers:lower() ~= "false" then
  include_headers = true
else
  include_headers = false
end

local include_body = os.getenv("APP_LOG_INCLUDE_BODY")
if include_body == nil or include_body:lower() ~= "false" then
  include_body = true
else
  include_body = false
end

local header_param_name = os.getenv("APP_LOG_HEADER_PARAM")

local req_body = include_body and (ngx.var.request_body or "") or nil
local req_headers = include_headers and ngx.req.get_headers() or nil
local resp_headers = include_headers and ngx.resp.get_headers() or nil
local resp_body = include_body and (ngx.ctx.resp_body or "") or nil

local header_param_value = nil
if header_param_name and req_headers then
  header_param_value = req_headers[header_param_name]
end

local log_entry = {
  timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
  request = {
    method = ngx.req.get_method(),
    uri = ngx.var.request_uri,
    headers = req_headers,
    body = req_body,
    header_param = header_param_value
  },
  response = {
    headers = resp_headers,
    body = resp_body
  },
  status = ngx.status
}

local f, err = io.open("/var/log/nginx/application.log", "a")
if f then
  f:write(cjson.encode(log_entry), "\n")
  f:close()
end

