#!/bin/bash

# PDF Viewer App Startup Script

echo "🚀 Starting PDF Viewer & Downloader App..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "✅ Created .env file with default settings"
fi

# Clean up any existing containers
echo "🧹 Cleaning up existing containers..."
docker-compose down 2>/dev/null

# Build and start services
echo "🔨 Building and starting services..."
docker-compose up -d --build

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 15

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services started successfully!"
    echo ""
    echo "🌐 Application URLs:"
    echo "   Frontend: http://localhost:3000"
    echo "   Backend:  http://localhost:8080"
    echo "   Health:   http://localhost:8080/health"
    echo ""
    echo "🔐 Admin Login:"
    echo "   URL: http://localhost:3000/admin/login"
    echo "   Password: admin123"
    echo ""
    echo "📊 View logs: docker-compose logs -f"
    echo "🛑 Stop app:  docker-compose down"
else
    echo "❌ Failed to start services. Check logs with: docker-compose logs"
    echo ""
    echo "🔍 Troubleshooting:"
    echo "   1. Make sure ports 3000 and 8080 are available"
    echo "   2. Check Docker logs: docker-compose logs"
    echo "   3. Try: docker-compose down && docker-compose up --build"
    exit 1
fi