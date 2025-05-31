# 🚀 Quick Start Guide

## Prerequisites

Make sure you have installed:
- **Node.js 16+** (check with `node --version`)
- **npm** (comes with Node.js)
- **Docker & Docker Compose** (for containerized setup)

## Option 1: Docker Setup (Recommended)

This is the easiest way to get started:

```bash
# 1. Navigate to the project directory
cd pdf-viewer-app

# 2. Copy environment variables
cp .env.example .env

# 3. Start the application
chmod +x start.sh
./start.sh
```

The app will be available at:
- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:8080
- **Admin Panel**: http://localhost:3000/admin/login

**Default admin password**: `admin123` (change this in `.env`)

## Option 2: Development Setup

For development with hot reloading:

```bash
# 1. Run the setup script
chmod +x dev-setup.sh
./dev-setup.sh

# 2. Start backend (in one terminal)
cd backend
npm run dev

# 3. Start frontend (in another terminal)
cd frontend
npm start
```

## First Steps

1. **Access the app** at http://localhost:3000
2. **Login as admin** at http://localhost:3000/admin/login
   - Password: `admin123` (or what you set in `.env`)
3. **Upload a PDF** using the admin panel
4. **View PDFs** in the public library
5. **Test the PDF viewer** by clicking on any PDF

## Troubleshooting

### Port Already in Use
```bash
# Stop any running containers
docker-compose down

# Or kill processes on specific ports
lsof -ti:3000 | xargs kill -9
lsof -ti:8080 | xargs kill -9
```

### Database Issues
```bash
# Reinitialize the database
cd backend
npm run init-db
```

### Docker Issues
```bash
# Clean up Docker
docker-compose down -v
docker system prune -f
```

## What's Included

- ✅ **PDF Upload System** - Drag & drop interface
- ✅ **PDF Viewer** - In-browser viewing with controls
- ✅ **Download System** - One-click downloads
- ✅ **Search & Filter** - Find PDFs quickly
- ✅ **Admin Panel** - Secure upload management
- ✅ **Responsive Design** - Works on all devices
- ✅ **Dark/Light Mode** - Theme toggle
- ✅ **Security Features** - Rate limiting, validation

## Next Steps

- Check the full [README.md](README.md) for detailed documentation
- Customize the design in `frontend/src/index.css`
- Add more features by modifying the React components
- Deploy to production using the Docker setup

## Need Help?

- Check the logs: `docker-compose logs -f`
- View the API health: http://localhost:8080/health
- Read the full documentation in README.md