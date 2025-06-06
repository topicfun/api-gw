# Windows PowerShell script to test the Dockerized services

# Step 1: start nginx proxy via docker-compose
Write-Host "Starting nginx proxy with docker-compose..."
docker compose up -d nginx

$networkName = "api-gw_app_network"

# Wait a few seconds for nginx to be ready
Start-Sleep -Seconds 5

# Step 2: build application images
Write-Host "Building java-backend image..."
docker build -t java-backend ./java-backend
Write-Host "Building java-backend2 image..."
docker build -t java-backend2 ./java-backend2
Write-Host "Building java-client image..."
docker build -t java-client ./java-client

# Step 3: run the containers on the compose network
Write-Host "Starting java-backend container..."
docker run -d --name java-backend --network $networkName -p 8082:8082 -e SERVER_PORT=8082 java-backend
Write-Host "Starting java-backend2 container..."
docker run -d --name java-backend2 --network $networkName -p 8083:8083 -e SERVER_PORT=8083 java-backend2
Write-Host "Starting java-client container..."
docker run -d --name java-client --network $networkName -p 8081:8081 -e SERVER_PORT=8081 java-client

# Wait for applications to start
Start-Sleep -Seconds 10

# Step 4: call the client endpoints and print the responses
$endpoints = @(
    "http://localhost:8081/client/callHello",
    "http://localhost:8081/client/callData",
    "http://localhost:8081/client/callBackend2Hello"
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
