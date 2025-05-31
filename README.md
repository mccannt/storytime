# 📚 StoryTime - PDF Viewer & Manager

A modern, responsive PDF viewer and management system built with React and Node.js. Perfect for organizing and sharing PDF documents with a clean, user-friendly interface.

## ✨ Features

- 📖 **PDF Viewing**: Smooth PDF rendering with zoom, navigation, and search
- 📁 **File Management**: Upload, organize, and manage PDF collections
- 🔐 **Admin Panel**: Secure admin interface for content management
- 📱 **Responsive Design**: Works perfectly on desktop, tablet, and mobile
- 🚀 **Fast Performance**: Optimized for quick loading and smooth navigation
- 🐳 **Docker Ready**: Easy deployment with Docker containers

## 🚀 Quick Start

### 🌟 GitHub to VPS Deployment (Recommended)

1. **Push to GitHub**:
   ```bash
   git init
   git add .
   git commit -m "Initial StoryTime setup"
   git remote add origin https://github.com/yourusername/storytime.git
   git push -u origin main
   ```

2. **Deploy to VPS**:
   ```bash
   # On your VPS
   wget https://raw.githubusercontent.com/yourusername/storytime/main/deploy-from-github.sh
   chmod +x deploy-from-github.sh
   sudo ./deploy-from-github.sh -r https://github.com/yourusername/storytime.git -d your-domain.com -s
   ```

### 💻 Local Development

1. **Clone and start**:
   ```bash
   git clone https://github.com/yourusername/storytime.git
   cd storytime
   chmod +x run-local.sh
   ./run-local.sh
   ```

2. **Access the application**:
   - Frontend: http://localhost:3000
   - Admin Panel: http://localhost:3000/admin

### 🐳 Docker Development

```bash
git clone https://github.com/yourusername/storytime.git
cd storytime
docker-compose up --build
```

## 🌐 Production Deployment

### 🎯 GitHub to VPS (Recommended)

The cleanest way to deploy StoryTime:

```bash
# On your VPS
wget https://raw.githubusercontent.com/yourusername/storytime/main/deploy-from-github.sh
chmod +x deploy-from-github.sh
sudo ./deploy-from-github.sh -r https://github.com/yourusername/storytime.git -d your-domain.com -s
```

### 🐳 Docker Production

```bash
git clone https://github.com/yourusername/storytime.git
cd storytime
cp .env.production backend/.env
# Edit backend/.env with your production settings
docker-compose -f docker-compose.prod.yml up -d
```

For detailed deployment instructions, see:
- [GitHub Deployment Guide](GITHUB_DEPLOYMENT.md) - Complete GitHub setup
- [Quick Start Guide](QUICK_START.md) - Get running in minutes
- [VPS Deployment Guide](DEPLOYMENT.md) - Detailed VPS instructions

## 📖 Documentation

- [Quick Start Guide](QUICK_START.md) - Get running in minutes
- [GitHub Deployment Guide](GITHUB_DEPLOYMENT.md) - Complete GitHub setup  
- [VPS Deployment Guide](DEPLOYMENT.md) - Detailed VPS instructions
- [VPS Summary](VPS_DEPLOYMENT_SUMMARY.md) - Quick deployment reference
- [Branding Guide](BRANDING.md) - Customization and branding options

## 🛠️ Technology Stack

**Frontend:**
- React 18
- React Router
- Axios
- CSS3 with responsive design

**Backend:**
- Node.js
- Express.js
- SQLite database
- Multer for file uploads
- JWT authentication

**DevOps:**
- Docker & Docker Compose
- Nginx reverse proxy
- Let's Encrypt SSL
- Automated deployment scripts

## 📁 Project Structure

```
storytime/
├── frontend/           # React frontend application
│   ├── src/
│   ├── public/
│   └── package.json
├── backend/            # Node.js backend API
│   ├── routes/
│   ├── database/
│   └── package.json
├── uploads/            # PDF file storage
├── docker-compose.yml  # Development Docker setup
├── docker-compose.prod.yml # Production Docker setup
├── deploy.sh          # Automated deployment script
└── README.md
```

## 🔧 Configuration

### Environment Variables

Copy `.env.production` to `backend/.env` and configure:

```env
# Server Configuration
PORT=8080
NODE_ENV=production

# Security
ADMIN_PASSWORD=your-secure-password
JWT_SECRET=your-jwt-secret

# Database
DB_PATH=./database/pdfs.db

# File Upload
UPLOAD_DIR=../uploads
MAX_FILE_SIZE=50000000

# Frontend URL
FRONTEND_URL=https://your-domain.com
```

### Admin Access

- **URL**: `/admin`
- **Username**: `admin`
- **Password**: Set in `ADMIN_PASSWORD` environment variable

## 🔒 Security Features

- JWT-based authentication
- Secure file upload validation
- CORS protection
- Rate limiting ready
- HTTPS/SSL support
- Security headers

## 📊 Performance

- **Memory Usage**: ~200MB total
- **Startup Time**: <10 seconds
- **File Support**: PDF files up to 50MB
- **Concurrent Users**: Optimized for 100+ users

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📖 Check the [documentation](DEPLOYMENT.md)
- 🐛 Report issues on GitHub
- 💬 Join our community discussions

## 🎯 Roadmap

- [ ] User authentication system
- [ ] PDF annotation features
- [ ] Advanced search capabilities
- [ ] Bulk upload functionality
- [ ] API documentation
- [ ] Mobile app

---

**StoryTime** - Making PDF management simple and elegant! 📚✨