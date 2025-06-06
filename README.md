# API Gateway

This repository contains a small demo with Nginx acting as a reverse proxy for multiple backend applications.

## Log configuration

Logging is controlled by the YAML file `nginx/log_config.yaml`. The file has a single key `mode` with the following values:

- `headers` – log request/response headers (default)
- `body` – also log the request body
- any other value – disable logging

After editing `log_config.yaml`, run:

```bash
python3 nginx/generate_log_conf.py
```

to regenerate `nginx/log_format.conf`. The `docker-compose` setup mounts this generated file and disables the default Nginx logs (`access.log` and `error.log`).
