#!/bin/bash

# Development Setup Script for PDF Viewer App

echo "🛠️  Setting up PDF Viewer App for development..."

# Check Node.js version
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 16+ and try again."
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo "❌ Node.js version 16+ is required. Current version: $(node -v)"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
fi

# Setup backend
echo "🔧 Setting up backend..."
cd backend
npm install
echo "📊 Initializing database..."
npm run init-db
cd ..

# Setup frontend
echo "🎨 Setting up frontend..."
cd frontend
npm install
cd ..

# Create uploads directory
mkdir -p uploads

echo "✅ Development setup complete!"
echo ""
echo "🚀 To start development servers:"
echo "   Backend:  cd backend && npm run dev"
echo "   Frontend: cd frontend && npm start"
echo ""
echo "🐳 To start with Docker:"
echo "   ./start.sh"
echo ""
echo "📚 Check README.md for more information."