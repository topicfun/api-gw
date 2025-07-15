#!/bin/sh
# Print important logging flags for visibility when the container starts
echo "APP_LOG_INCLUDE_HEADERS=$APP_LOG_INCLUDE_HEADERS"
echo "APP_LOG_INCLUDE_BODY=$APP_LOG_INCLUDE_BODY"
echo "APP_LOG_HEADER_PARAM=$APP_LOG_HEADER_PARAM"
exec "$@"
