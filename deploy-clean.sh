#!/bin/bash

# Clean deployment script - runs cleanup first, then deployment

echo "🚀 StoryTime Clean Deployment"
echo "============================="

# Make scripts executable
chmod +x cleanup-ports.sh deploy.sh

# Run cleanup first
echo "Step 1: Cleaning up existing containers and ports..."
./cleanup-ports.sh

echo ""
echo "Step 2: Starting deployment..."
./deploy.sh "$@"