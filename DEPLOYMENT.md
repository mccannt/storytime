# StoryTime Deployment Guide for Hostinger VPS

## 🚀 Production Deployment Setup

This guide will help you deploy StoryTime on your Hostinger VPS alongside your existing nginx setup.

## 📦 Pre-Deployment Checklist

### 1. Update Environment Variables
Edit `backend/.env` for production:

```env
# Server Configuration
PORT=8080
NODE_ENV=production

# Admin Authentication
ADMIN_PASSWORD=your_secure_admin_password_here
JWT_SECRET=your_super_secure_jwt_secret_change_this_in_production

# Database
DB_PATH=./database/pdfs.db

# File Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=50MB

# CORS
FRONTEND_URL=https://your-domain.com
```

### 2. Security Updates
- Change `ADMIN_PASSWORD` to a strong password
- Generate a new `JWT_SECRET` (use: `openssl rand -base64 32`)
- Update `FRONTEND_URL` to your actual domain

## 🐳 Docker Production Setup

### Option 1: Docker Compose (Recommended)

1. **Upload files to VPS:**
```bash
# Create directory on VPS
mkdir -p /var/www/storytime
cd /var/www/storytime

# Upload your project files (use scp, rsync, or git)
# Example with scp:
scp -r ./pdf-viewer-app/* user@your-vps:/var/www/storytime/
```

2. **Run on VPS:**
```bash
cd /var/www/storytime
chmod +x start.sh
./start.sh
```

### Option 2: Manual Docker Build

```bash
# Build images
docker build -f Dockerfile.backend -t storytime-backend .
docker build -f Dockerfile.frontend -t storytime-frontend .

# Run containers
docker run -d --name storytime-backend -p 8080:8080 storytime-backend
docker run -d --name storytime-frontend -p 3000:80 storytime-frontend
```

## 🌐 Nginx Configuration

### Main Nginx Config (`/etc/nginx/sites-available/storytime`)

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    
    # SSL Configuration (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Frontend (React app)
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
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
        
        # File upload size limit
        client_max_body_size 50M;
    }
    
    # Health check
    location /health {
        proxy_pass http://localhost:8080;
        access_log off;
    }
}
```

### Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/storytime /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 🔒 SSL Certificate (Let's Encrypt)

```bash
# Install certbot
sudo apt update
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal (add to crontab)
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 🔧 Alternative: Direct Node.js Deployment

If you prefer not to use Docker:

### 1. Install Dependencies
```bash
# Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 for process management
sudo npm install -g pm2
```

### 2. Build and Deploy
```bash
cd /var/www/storytime

# Install backend dependencies
cd backend
npm install --production
npm run init-db

# Install and build frontend
cd ../frontend
npm install
npm run build

# Start with PM2
cd ../backend
pm2 start server.js --name "storytime-backend"
pm2 save
pm2 startup
```

### 3. Nginx Config for Direct Deployment
```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    root /var/www/storytime/frontend/build;
    index index.html;
    
    # Serve React app
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # API proxy
    location /api/ {
        proxy_pass http://localhost:8080;
        # ... same proxy settings as above
    }
    
    # Static files caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

## 📋 Deployment Checklist

- [ ] Update `.env` with production values
- [ ] Change admin password and JWT secret
- [ ] Upload files to VPS
- [ ] Configure nginx
- [ ] Set up SSL certificate
- [ ] Test application
- [ ] Set up monitoring/logging
- [ ] Configure backups for database and uploads

## 🔍 Monitoring & Maintenance

### Check Application Status
```bash
# Docker
docker-compose ps
docker-compose logs -f

# PM2
pm2 status
pm2 logs storytime-backend
```

### Backup Database
```bash
# Create backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
cp /var/www/storytime/backend/database/pdfs.db /var/www/storytime/backups/pdfs_$DATE.db
```

### Update Application
```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose up -d --build

# Or with PM2
pm2 restart storytime-backend
```

## 🚨 Troubleshooting

### Common Issues:
1. **Port conflicts:** Make sure ports 3000 and 8080 are available
2. **File permissions:** Ensure uploads directory is writable
3. **Database issues:** Check database file permissions
4. **Nginx errors:** Check nginx error logs: `sudo tail -f /var/log/nginx/error.log`

### Useful Commands:
```bash
# Check ports
sudo netstat -tlnp | grep :3000
sudo netstat -tlnp | grep :8080

# Check logs
docker-compose logs backend
docker-compose logs frontend
sudo tail -f /var/log/nginx/access.log
```