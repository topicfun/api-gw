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
* `APP_LOG_HEADER_PARAM` – comma-separated list of header names to log under
  `header_param` in both the request and response sections even when
  `APP_LOG_INCLUDE_HEADERS` is `false`.

All options default to logging everything.

The provided `docker-compose.yml` loads these variables from `.env.dev` and
passes them to the Nginx container. Adjust the values in that file to control
what the Lua logger records.


## Route configuration

Routes between incoming paths and backend services are defined in `nginx/routes.conf`. This file is mounted into the container and can be modified without changing `nginx.conf`. The initial configuration contains routes for `client-backend` and `backend2`. Additional mappings from the legacy Zuul setup found in `My/application.yml` can be added to this file following the same pattern.
