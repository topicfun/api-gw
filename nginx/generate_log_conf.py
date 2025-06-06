import os

CONFIG_PATH = os.environ.get('LOG_CONFIG_PATH', 'log_config.yaml')
OUTPUT_PATH = os.environ.get('LOG_OUTPUT_PATH', 'log_format.conf')

with open(os.path.join(os.path.dirname(__file__), CONFIG_PATH)) as f:
    lines = f.readlines()

config = {}
for line in lines:
    if ':' in line:
        key, value = line.split(':', 1)
        config[key.strip()] = value.strip()

mode = config.get('mode', 'headers')

if mode == 'body':
    log_format = """log_format custom_log '$remote_addr - $remote_user [$time_local]' "$request" $status $body_bytes_sent "$upstream_addr" "$upstream_response_time" '$request_body';
"""
elif mode == 'headers':
    log_format = """log_format custom_log '$remote_addr - $remote_user [$time_local]' "$request" $status $body_bytes_sent "$upstream_addr" "$upstream_response_time";
"""
else:
    log_format = "log_format custom_log '';\n"

output_file = os.path.join(os.path.dirname(__file__), OUTPUT_PATH)
with open(output_file, 'w') as out:
    out.write(log_format)
