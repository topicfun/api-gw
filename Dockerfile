FROM openresty/openresty:alpine

COPY nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY nginx/log_format.conf /usr/local/openresty/nginx/conf/log_format.conf
COPY nginx/app_logger.lua /usr/local/openresty/nginx/conf/app_logger.lua
COPY nginx/app_logger_body.lua /usr/local/openresty/nginx/conf/app_logger_body.lua
COPY nginx/routes.conf /usr/local/openresty/nginx/route/routes.conf

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN mkdir -p /var/log/nginx

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
