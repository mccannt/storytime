# 🚀 GitHub-Based VPS Deployment Guide

This guide shows you how to deploy StoryTime to your Hostinger VPS using GitHub - the cleanest and most professional approach.

## 🎯 Why GitHub Deployment?

- ✅ **Version Control**: Track all changes and rollback if needed
- ✅ **Easy Updates**: Simple `git pull` to update your app
- ✅ **Clean Process**: No file transfers or packaging needed
- ✅ **Professional**: Industry standard deployment method
- ✅ **Backup**: Your code is safely stored on GitHub

## 📋 Prerequisites

- GitHub account
- Hostinger VPS with SSH access
- Domain name (optional but recommended)

## 🔧 Step 1: Prepare Your Repository

### 1.1 Create GitHub Repository

1. Go to [GitHub](https://github.com) and create a new repository
2. Name it `storytime` or your preferred name
3. Make it **public** or **private** (your choice)
4. Don't initialize with README (we already have one)

### 1.2 Push Your Code

```bash
# In your local storytime directory
git init
git add .
git commit -m "Initial commit - StoryTime PDF Viewer"
git branch -M main
git remote add origin https://github.com/yourusername/storytime.git
git push -u origin main
```

## 🌐 Step 2: Deploy to VPS

### 2.1 Connect to Your VPS

```bash
ssh root@your-vps-ip
# or
ssh username@your-vps-ip
```

### 2.2 Install Prerequisites

```bash
# Update system
apt update && apt upgrade -y

# Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Install Docker (optional but recommended)
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Nginx
apt install nginx -y

# Install Git (usually pre-installed)
apt install git -y
```

### 2.3 Clone and Deploy

```bash
# Navigate to web directory
cd /var/www

# Clone your repository
git clone https://github.com/yourusername/storytime.git
cd storytime

# Make scripts executable
chmod +x deploy.sh
chmod +x run-local.sh

# Run automated deployment
./deploy.sh -d your-domain.com

# Or if you don't have a domain yet
./deploy.sh -d your-vps-ip
```

## 🔒 Step 3: Configure Environment

### 3.1 Set Production Environment

```bash
# Copy production environment template
cp .env.production backend/.env

# Edit with your settings
nano backend/.env
```

**Important settings to change:**
```env
# Change these for security!
ADMIN_PASSWORD=your-super-secure-password
JWT_SECRET=your-random-jwt-secret-here

# Update with your domain
FRONTEND_URL=https://your-domain.com
```

### 3.2 Generate Secure Secrets

```bash
# Generate a secure JWT secret
openssl rand -base64 32

# Generate a secure admin password
openssl rand -base64 16
```

## 🐳 Step 4: Choose Deployment Method

### Option A: Docker Deployment (Recommended)

```bash
# Start with Docker Compose
docker-compose -f docker-compose.prod.yml up -d

# Check status
docker-compose -f docker-compose.prod.yml ps
```

### Option B: Direct Node.js Deployment

```bash
# Install dependencies
npm install
cd frontend && npm install && npm run build
cd ../backend && npm install
cd ..

# Start with PM2 (process manager)
npm install -g pm2
pm2 start backend/server.js --name "storytime-backend"
pm2 startup
pm2 save
```

## 🌐 Step 5: Configure Nginx

The deployment script should have configured Nginx automatically. If not:

```bash
# Create Nginx configuration
nano /etc/nginx/sites-available/storytime
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    # Frontend (React build)
    location / {
        root /var/www/storytime/frontend/build;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable the site:
```bash
ln -s /etc/nginx/sites-available/storytime /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

## 🔐 Step 6: SSL Certificate (Optional but Recommended)

```bash
# Install Certbot
apt install certbot python3-certbot-nginx -y

# Get SSL certificate
certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal is set up automatically
```

## 🔄 Step 7: Updates and Maintenance

### Updating Your App

```bash
cd /var/www/storytime

# Pull latest changes
git pull origin main

# If using Docker
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build

# If using Node.js directly
cd frontend && npm run build
pm2 restart storytime-backend
```

### Monitoring

```bash
# Check Docker containers
docker-compose -f docker-compose.prod.yml logs -f

# Check PM2 processes
pm2 status
pm2 logs storytime-backend

# Check Nginx
systemctl status nginx
tail -f /var/log/nginx/error.log
```

## 🎯 Step 8: Access Your App

1. **Frontend**: `https://your-domain.com`
2. **Admin Panel**: `https://your-domain.com/admin`
   - Username: `admin`
   - Password: (what you set in `ADMIN_PASSWORD`)

## 🔧 Troubleshooting

### Common Issues

**Port already in use:**
```bash
# Check what's using the port
lsof -i :8080
# Kill the process if needed
kill -9 PID
```

**Permission issues:**
```bash
# Fix ownership
chown -R www-data:www-data /var/www/storytime
chmod -R 755 /var/www/storytime
```

**Database issues:**
```bash
# Check database directory
ls -la backend/database/
# Create if missing
mkdir -p backend/database
```

### Logs

```bash
# Application logs
tail -f backend/logs/app.log

# Nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# System logs
journalctl -u nginx -f
```

## 🎉 Success!

Your StoryTime app should now be running on your VPS! 

### Next Steps

1. Upload some PDF files through the admin panel
2. Test the application thoroughly
3. Set up regular backups
4. Monitor performance and logs
5. Consider setting up a staging environment

### Benefits of This Approach

- **Easy updates**: Just `git pull` and restart
- **Version control**: Full history of changes
- **Rollback capability**: Easy to revert if issues occur
- **Team collaboration**: Multiple developers can contribute
- **Professional setup**: Industry standard deployment

---

**Need help?** Check the main [DEPLOYMENT.md](DEPLOYMENT.md) for more detailed instructions or troubleshooting tips!