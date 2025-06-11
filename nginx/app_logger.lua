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

local header_param_env = os.getenv("APP_LOG_HEADER_PARAM")
local header_param_names = {}
if header_param_env then
  for name in string.gmatch(header_param_env, "[^,%s]+") do
    header_param_names[#header_param_names+1] = name
  end
end

local req_headers = include_headers and ngx.req.get_headers() or nil
local req_body = include_body and (ngx.var.request_body or "") or nil
local resp_headers = include_headers and ngx.resp.get_headers() or nil
local resp_body = include_body and (ngx.ctx.resp_body or "") or nil

local header_param_value
if #header_param_names > 0 then
  local header_source = req_headers or ngx.req.get_headers()
  if #header_param_names == 1 then
    header_param_value = header_source[header_param_names[1]]
  else
    header_param_value = {}
    for _, name in ipairs(header_param_names) do
      header_param_value[name] = header_source[name]
    end
  end
end

-- build request JSON manually so headers come before body
local req_parts = {}
if req_headers then req_parts[#req_parts+1] = '"headers":' .. cjson.encode(req_headers) end
req_parts[#req_parts+1] = '"method":' .. cjson.encode(ngx.req.get_method())
req_parts[#req_parts+1] = '"uri":' .. cjson.encode(ngx.var.request_uri)
if req_body ~= nil then req_parts[#req_parts+1] = '"body":' .. cjson.encode(req_body) end
if header_param_value then req_parts[#req_parts+1] = '"header_param":' .. cjson.encode(header_param_value) end
local request_json = '{' .. table.concat(req_parts, ',') .. '}'

local resp_parts = {}
if resp_headers then resp_parts[#resp_parts+1] = '"headers":' .. cjson.encode(resp_headers) end
if resp_body ~= nil then resp_parts[#resp_parts+1] = '"body":' .. cjson.encode(resp_body) end
local response_json = '{' .. table.concat(resp_parts, ',') .. '}'

-- build JSON string manually to keep key order
local parts = {}
parts[#parts+1] = '"timestamp":' .. cjson.encode(os.date("!%Y-%m-%dT%H:%M:%SZ"))
parts[#parts+1] = '"request":' .. request_json
parts[#parts+1] = '"response":' .. response_json
parts[#parts+1] = '"status":' .. tostring(ngx.status)

local log_line = "{" .. table.concat(parts, ",") .. "}\n"

local f = io.open("/var/log/nginx/application.log", "a")
if f then
  f:write(log_line)
  f:close()
end
