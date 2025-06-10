if ngx.ctx.resp_body then
  ngx.ctx.resp_body = ngx.ctx.resp_body .. (ngx.arg[1] or "")
else
  ngx.ctx.resp_body = ngx.arg[1] or ""
end
if ngx.arg[2] then
  -- end of body
end
