FROM openresty/openresty:alpine

# Required for the Lua proxy that handles duplicate headers
RUN apk add --no-cache perl \
    && opm get ledgetech/lua-resty-http

COPY nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY nginx/log_format.conf /usr/local/openresty/nginx/conf/log_format.conf
COPY nginx/app_logger.lua /usr/local/openresty/nginx/conf/app_logger.lua
COPY nginx/app_logger_body.lua /usr/local/openresty/nginx/conf/app_logger_body.lua
COPY nginx/routes.conf /usr/local/openresty/nginx/route/routes.conf
COPY nginx/duplicate_header_proxy.lua /usr/local/openresty/nginx/conf/duplicate_header_proxy.lua

RUN mkdir -p /var/log/nginx

EXPOSE 80

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
