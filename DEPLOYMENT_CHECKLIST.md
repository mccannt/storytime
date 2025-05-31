# 🚀 StoryTime Deployment Checklist

Use this checklist to ensure a smooth deployment to your VPS.

## ✅ Pre-Deployment Checklist

### 📋 Local Setup
- [ ] All files are in your project directory
- [ ] You have a GitHub account
- [ ] Git is installed locally
- [ ] You've tested the app locally with `./run-local.sh`

### 🌐 VPS Requirements
- [ ] VPS is running Ubuntu 18.04+ or similar
- [ ] You have SSH access to your VPS
- [ ] You have sudo/root privileges
- [ ] Domain name is pointed to your VPS IP (optional but recommended)

## 🎯 Deployment Steps

### Step 1: Push to GitHub
```bash
# Initialize git repository
git init

# Add all files
git add .

# Commit changes
git commit -m "Initial StoryTime setup"

# Add GitHub remote (replace with your repo URL)
git remote add origin https://github.com/yourusername/storytime.git

# Push to GitHub
git push -u origin main
```

**✅ Verify:** Your code is visible on GitHub

### Step 2: Deploy to VPS
```bash
# SSH into your VPS
ssh root@your-vps-ip

# Download deployment script
wget https://raw.githubusercontent.com/yourusername/storytime/main/deploy-from-github.sh

# Make executable
chmod +x deploy-from-github.sh

# Run deployment (replace with your details)
sudo ./deploy-from-github.sh -r https://github.com/yourusername/storytime.git -d your-domain.com -s
```

**✅ Verify:** Script completes without errors

### Step 3: Configure Environment
```bash
# Navigate to installation directory
cd /var/www/storytime

# Edit environment file
nano backend/.env

# Update these critical settings:
# - ADMIN_PASSWORD (change from default)
# - JWT_SECRET (generate new one)
# - FRONTEND_URL (your actual domain)
```

**✅ Verify:** Environment variables are set correctly

### Step 4: Test Deployment
- [ ] Frontend loads: `https://your-domain.com`
- [ ] Admin panel accessible: `https://your-domain.com/admin`
- [ ] Can login with admin credentials
- [ ] Can upload a test PDF
- [ ] PDF displays correctly
- [ ] Mobile responsive design works

## 🔧 Post-Deployment Tasks

### Security
- [ ] Changed default admin password
- [ ] Generated new JWT secret
- [ ] SSL certificate is installed and working
- [ ] Firewall is configured (ports 80, 443, 22)

### Performance
- [ ] Application loads quickly
- [ ] PDF rendering is smooth
- [ ] File uploads work properly
- [ ] No console errors in browser

### Monitoring
- [ ] Set up log monitoring
- [ ] Configure backup strategy
- [ ] Test restart procedures
- [ ] Document admin procedures

## 🆘 Troubleshooting

### Common Issues

**Port already in use:**
```bash
sudo lsof -i :8080
sudo kill -9 <PID>
```

**Permission errors:**
```bash
sudo chown -R www-data:www-data /var/www/storytime
sudo chmod -R 755 /var/www/storytime
```

**Docker issues:**
```bash
cd /var/www/storytime
docker-compose -f docker-compose.prod.yml logs -f
```

**Nginx issues:**
```bash
sudo nginx -t
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log
```

### Log Locations
- **Application logs:** `/var/www/storytime/backend/logs/`
- **Nginx logs:** `/var/log/nginx/`
- **Docker logs:** `docker-compose logs`
- **PM2 logs:** `pm2 logs`

## 📊 Success Metrics

Your deployment is successful when:
- ✅ Frontend loads without errors
- ✅ Admin panel is accessible
- ✅ PDF upload and viewing works
- ✅ SSL certificate is active
- ✅ Application restarts automatically
- ✅ Performance is acceptable

## 🔄 Update Procedure

When you make changes:

1. **Local changes:**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push
   ```

2. **VPS update:**
   ```bash
   cd /var/www/storytime
   git pull
   docker-compose -f docker-compose.prod.yml up -d --build
   ```

## 📞 Support Resources

- **Documentation:** Check all `.md` files in the project
- **Logs:** Always check logs first for error details
- **GitHub Issues:** Report bugs and get help
- **Community:** Join discussions for tips and tricks

---

**🎉 Congratulations!** You've successfully deployed StoryTime! 📚✨