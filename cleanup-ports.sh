#!/bin/bash

# Cleanup script for StoryTime deployment
# This script stops existing containers and frees up ports

set -e

echo "🧹 Cleaning up existing containers and ports..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Stop all containers with storytime in the name
echo "Stopping StoryTime containers..."
docker ps -a --filter "name=storytime" --format "table {{.Names}}\t{{.Status}}" | grep -v NAMES || true
docker stop $(docker ps -q --filter "name=storytime") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=storytime") 2>/dev/null || true

# Stop containers using our specific names
echo "Stopping PDF viewer containers..."
docker stop pdf-viewer-backend pdf-viewer-frontend 2>/dev/null || true
docker rm pdf-viewer-backend pdf-viewer-frontend 2>/dev/null || true

# Stop any containers using ports 3000 and 8082
echo "Checking for processes using ports 3000 and 8082..."

# Check port 3000
PORT_3000_PID=$(lsof -ti:3000 2>/dev/null || true)
if [ ! -z "$PORT_3000_PID" ]; then
    print_warning "Port 3000 is in use by process $PORT_3000_PID"
    echo "Killing process on port 3000..."
    sudo kill -9 "$PORT_3000_PID" 2>/dev/null || true # Assuming sudo was intended from previous suggestions
    print_success "Freed port 3000"
fi

# Check port 8082
PORT_8082_PID=$(lsof -ti:8082 2>/dev/null || true)
if [ ! -z "$PORT_8082_PID" ]; then
    print_warning "Port 8082 is in use by process $PORT_8082_PID"
    echo "Killing process on port 8082..."
    sudo kill -9 "$PORT_8082_PID" 2>/dev/null || true # Assuming sudo was intended
    print_success "Freed port 8082"
fi

# Clean up docker networks
echo "Cleaning up Docker networks..."
docker network rm storytime-network 2>/dev/null || true
docker network rm pdf-viewer-network 2>/dev/null || true

# Clean up any dangling containers
echo "Removing dangling containers..."
docker container prune -f 2>/dev/null || true

# Show current port usage
echo ""
echo "Current port usage:"
echo "Port 3000: $(lsof -ti:3000 2>/dev/null || echo 'Free')"
echo "Port 8082: $(lsof -ti:8082 2>/dev/null || echo 'Free')"

print_success "Cleanup completed!"
echo ""
echo "You can now run the deployment script:"
echo "./deploy.sh"#!/bin/bash

# Cleanup script for StoryTime deployment
# This script stops existing containers and frees up ports

set -e

echo "🧹 Cleaning up existing containers and ports..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Stop all containers with storytime in the name
echo "Stopping StoryTime containers..."
docker ps -a --filter "name=storytime" --format "table {{.Names}}\t{{.Status}}" | grep -v NAMES || true
docker stop $(docker ps -q --filter "name=storytime") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=storytime") 2>/dev/null || true

# Stop containers using our specific names
echo "Stopping PDF viewer containers..."
docker stop pdf-viewer-backend pdf-viewer-frontend 2>/dev/null || true
docker rm pdf-viewer-backend pdf-viewer-frontend 2>/dev/null || true

# Stop any containers using ports 3000 and 8081
echo "Checking for processes using ports 3000 and 8081..."

# Check port 3000
PORT_3000_PID=$(lsof -ti:3000 2>/dev/null || true)
if [ ! -z "$PORT_3000_PID" ]; then
    print_warning "Port 3000 is in use by process $PORT_3000_PID"
    echo "Killing process on port 3000..."
    kill -9 "$PORT_3000_PID" 2>/dev/null || true
    print_success "Freed port 3000"
fi

# Check port 8081
PORT_8081_PID=$(lsof -ti:8081 2>/dev/null || true)
if [ ! -z "$PORT_8081_PID" ]; then
    print_warning "Port 8081 is in use by process $PORT_8081_PID"
    echo "Killing process on port 8081..."
    kill -9 "$PORT_8081_PID" 2>/dev/null || true
    print_success "Freed port 8081"
fi

# Clean up docker networks
echo "Cleaning up Docker networks..."
docker network rm storytime-network 2>/dev/null || true
docker network rm pdf-viewer-network 2>/dev/null || true

# Clean up any dangling containers
echo "Removing dangling containers..."
docker container prune -f 2>/dev/null || true

# Show current port usage
echo ""
echo "Current port usage:"
echo "Port 3000: $(lsof -ti:3000 2>/dev/null || echo 'Free')"
echo "Port 8081: $(lsof -ti:8081 2>/dev/null || echo 'Free')"

print_success "Cleanup completed!"
echo ""
echo "You can now run the deployment script:"
echo "./deploy.sh"