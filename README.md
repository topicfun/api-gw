# API Gateway

This repository contains a small demo with Nginx acting as a reverse proxy for multiple backend applications. The gateway uses a custom Nginx image built from the official `nginx:1.26.3-alpine` base with the Lua module installed. Pinning the Nginx version prevents module version mismatches.

## Log configuration

### Access log

`nginx/log_format.conf` generate access log  


### Application log options

Nginx also writes an `application.log` file that contains the full request and response (headers and body) using Lua scripts. The log is located under `nginx/logs/` inside the container.
The behaviour of `application.log` can be tuned through environment variables used by
the Lua logger:

* `APP_LOG_INCLUDE_HEADERS` – set to `false` to omit request/response headers.
* `APP_LOG_INCLUDE_BODY` – set to `false` to omit request/response bodies.
* `APP_LOG_HEADER_PARAM` – if set, logs the value of the named request header under `header_param`.

All options default to logging everything.

