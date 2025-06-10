local cjson = require "cjson.safe"

-- configuration flags (defaults to true)
local include_headers = true
local h_env = os.getenv("APP_LOG_INCLUDE_HEADERS")
if h_env and h_env:lower() == "false" then
  include_headers = false
end

local include_body = true
local b_env = os.getenv("APP_LOG_INCLUDE_BODY")
if b_env and b_env:lower() == "false" then
  include_body = false
end

local header_param_name = os.getenv("APP_LOG_HEADER_PARAM")

-- collect request/response data based on flags
local req_headers = include_headers and ngx.req.get_headers() or nil
local req_body = include_body and (ngx.var.request_body or "") or nil
local resp_headers = include_headers and ngx.resp.get_headers() or nil
local resp_body = include_body and (ngx.ctx.resp_body or "") or nil

local header_param_value
if header_param_name and req_headers then
  header_param_value = req_headers[header_param_name]
end

local request_tbl = {
  method = ngx.req.get_method(),
  uri = ngx.var.request_uri
}
if req_headers then request_tbl.headers = req_headers end
if req_body ~= nil then request_tbl.body = req_body end
if header_param_value then request_tbl.header_param = header_param_value end

local response_tbl = {}
if resp_headers then response_tbl.headers = resp_headers end
if resp_body ~= nil then response_tbl.body = resp_body end

-- build JSON string manually to keep key order
local parts = {}
parts[#parts+1] = '"timestamp":' .. cjson.encode(os.date("!%Y-%m-%dT%H:%M:%SZ"))
parts[#parts+1] = '"request":' .. cjson.encode(request_tbl)
parts[#parts+1] = '"response":' .. cjson.encode(response_tbl)
parts[#parts+1] = '"status":' .. tostring(ngx.status)

local log_line = "{" .. table.concat(parts, ",") .. "}\n"

local f = io.open("/var/log/nginx/application.log", "a")
if f then
  f:write(log_line)
  f:close()
end
