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

When using the PowerShell script `test-script-dockerfile.ps1` the container is
started directly with `docker run`. In this case the environment file is passed
explicitly so the logging variables take effect. The entrypoint of the image now
prints the current values of these variables when the container starts which
helps verifying that the correct configuration is applied.


## Route configuration

Routes between incoming paths and backend services are defined in `nginx/routes.conf`. This file is mounted into the container and can be modified without changing `nginx.conf`. The initial configuration contains routes for `client-backend` and `backend2`. Additional mappings from the legacy Zuul setup found in `My/application.yml` can be added to this file following the same pattern.

## Local testing with Docker Compose

Use `test-nginx-route.sh` to start the Nginx container and verify that the routing rules work. The script launches only the gateway and issues a request from a temporary curl container. A `502` status code is expected because no backend services are running.

```bash
./test-nginx-route.sh
```

## Deploying with Helm

A Helm chart is available in `charts/api-gw` for Kubernetes deployments. Build the Docker image and install the chart:

```bash
docker build -t api-gw .
helm install api-gw ./charts/api-gw \
  --set image.repository=api-gw \
  --set image.tag=latest
```

The `test-helm-chart.sh` script automates a simple test installation in a temporary namespace and performs the same route check as the compose script.

```bash
./test-helm-chart.sh
```

Both scripts require Docker and Helm to be installed.
