# 🚀 StoryTime - Quick Start Guide

Get your StoryTime PDF viewer running in minutes!

## 🎯 Choose Your Deployment Method

### 🌟 Method 1: GitHub to VPS (Recommended)

**Perfect for:** Production deployments, easy updates, professional setup

1. **Push to GitHub** (do this locally):
   ```bash
   git init
   git add .
   git commit -m "Initial StoryTime setup"
   git remote add origin https://github.com/yourusername/storytime.git
   git push -u origin main
   ```

2. **Deploy to VPS** (run on your server):
   ```bash
   wget https://raw.githubusercontent.com/yourusername/storytime/main/deploy-from-github.sh
   chmod +x deploy-from-github.sh
   sudo ./deploy-from-github.sh -r https://github.com/yourusername/storytime.git -d your-domain.com -s
   ```

### 🐳 Method 2: Local Docker

**Perfect for:** Development, testing, quick demos

```bash
# Clone and start
git clone https://github.com/yourusername/storytime.git
cd storytime
docker-compose up --build
```

Access at: http://localhost:3000

### 💻 Method 3: Local Development

**Perfect for:** Development, customization

```bash
# Clone and setup
git clone https://github.com/yourusername/storytime.git
cd storytime
chmod +x run-local.sh
./run-local.sh
```

Access at: http://localhost:3000

## 🔑 Default Admin Access

- **URL**: `/admin`
- **Username**: `admin`
- **Password**: `admin123` (change this!)

## 🎯 Next Steps

1. **Upload PDFs** through the admin panel
2. **Change admin password** in `backend/.env`
3. **Customize branding** (see [BRANDING.md](BRANDING.md))
4. **Set up SSL** for production

## 📚 Documentation

- [GitHub Deployment Guide](GITHUB_DEPLOYMENT.md) - Complete GitHub setup
- [VPS Deployment Guide](DEPLOYMENT.md) - Detailed VPS instructions
- [Branding Guide](BRANDING.md) - Customization options

## 🆘 Need Help?

- Check the logs: `docker-compose logs -f`
- Verify ports: `netstat -tlnp | grep :3000`
- Test API: `curl http://localhost:8080/api/health`

---

**StoryTime** - Your PDFs, beautifully organized! 📚✨