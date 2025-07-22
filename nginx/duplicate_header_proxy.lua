-- Proxy request to upstream while tolerating duplicate headers
local http = require "resty.http"

local upstream = "http://host.docker.internal:58084"

local httpc = http.new()
local res, err = httpc:request_uri(upstream .. ngx.var.request_uri, {
    method = ngx.req.get_method(),
    headers = ngx.req.get_headers(),
    body = ngx.req.get_body_data(),
})

if not res then
    ngx.log(ngx.ERR, "failed to request upstream: ", err)
    return ngx.exit(502)
end

ngx.status = res.status
for k, v in pairs(res.headers) do
    if k:lower() == "transfer-encoding" then
        -- ignore duplicate Transfer-Encoding headers by setting only once
        if not ngx.header[k] then
            ngx.header[k] = v
        end
    else
        ngx.header[k] = v
    end
end
ngx.print(res.body or "")

