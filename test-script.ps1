# Windows PowerShell script to test the Dockerized services

# Step 1: stop any running containers so we can rebuild them
Write-Host "Stopping running containers if they exist..."
docker compose down

$containers = @("java-backend", "dxl-client-config-svc", "java-client")
foreach ($c in $containers) {
    if (docker ps -a --format '{{.Names}}' | Where-Object { $_ -eq $c }) {
        Write-Host "Removing container $c..."
        docker rm -f $c | Out-Null
    }
}

# Start the nginx proxy with the latest configuration.
# Docker Compose mounts the files into
# /usr/local/openresty/nginx/conf so our routes
# and Lua logging are active.
# Write-Host "Starting nginx proxy with docker-compose..."
# docker-compose will read `.env.dev` via `env_file` in the compose file
# docker compose up -d nginx

$networkName = "api-gw_app_network"

# Wait a few seconds for nginx to be ready
Start-Sleep -Seconds 5

# Step 2: build application images
Write-Host "Building java-backend image..."
docker build -t java-backend ./java-backend
Write-Host "Building dxl-client-config-svc image..."
docker build -t dxl-client-config-svc ./java-backend2
Write-Host "Building java-client image..."
docker build -t java-client ./java-client

# Step 3: run the containers on the compose network
Write-Host "Starting java-backend container..."
docker run -d --name java-backend --network $networkName -p 8082:8082 -e SERVER_PORT=8082 java-backend
Write-Host "Starting dxl-client-config-svc container..."
docker run -d --name dxl-client-config-svc --network $networkName -p 8080:8080 -e SERVER_PORT=8080 dxl-client-config-svc
Write-Host "Starting java-client container..."
docker run -d --name java-client --network $networkName -p 8081:8081 -e SERVER_PORT=8081 java-client

# Wait for applications to start
Start-Sleep -Seconds 15

# Step 4: call the client endpoints and print the responses
$endpoints = @(
    "http://localhost:8081/client/callHello",
    "http://localhost:8081/client/callData",
    "http://localhost:8081/client/callConfigAPI"
)

foreach ($url in $endpoints) {
    Write-Host "\nCalling $url"
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        Write-Host $response.Content
    } catch {
        Write-Warning "Request to $url failed: $_"
    }
}

Write-Host "\nTesting complete."
