#!/bin/bash

# Local Development Runner (No Docker)

echo "🚀 Starting PDF Viewer App Locally..."

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 16+ and try again."
    exit 1
fi

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
fi

# Setup backend
echo "🔧 Setting up backend..."
cd backend || exit 1
if [ ! -d "node_modules" ]; then
    echo "📦 Installing backend dependencies..."
    npm install
fi

echo "📊 Initializing database..."
npm run init-db

echo "🚀 Starting backend server..."
npm start &
BACKEND_PID=$!

cd ..

# Setup frontend
echo "🎨 Setting up frontend..."
cd ../frontend || exit 1
if [ ! -d "node_modules" ]; then
    echo "📦 Installing frontend dependencies..."
    npm install
fi

echo "🚀 Starting frontend server..."
npm start &
FRONTEND_PID=$!

cd ..

echo ""
echo "✅ Both servers are starting..."
echo ""
echo "🌐 Application URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:8080"
echo "   Admin:    http://localhost:3000/admin/login"
echo ""
echo "🔐 Admin password: admin123"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for interrupt
trap 'echo "🛑 Stopping servers..."; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit' INT

# Keep script running
wait