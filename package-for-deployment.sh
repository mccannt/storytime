#!/bin/bash

# StoryTime Packaging Script for VPS Deployment

echo "📦 Packaging StoryTime for deployment..."

# Create deployment package
PACKAGE_NAME="storytime-deployment-$(date +%Y%m%d-%H%M%S)"
PACKAGE_DIR="./$PACKAGE_NAME"

# Create package directory
mkdir -p "$PACKAGE_DIR"

# Copy essential files
echo "📋 Copying application files..."

# Root files
cp -r backend/ "$PACKAGE_DIR/"
cp -r frontend/ "$PACKAGE_DIR/"
cp -r uploads/ "$PACKAGE_DIR/" 2>/dev/null || mkdir -p "$PACKAGE_DIR/uploads"

# Docker files
cp Dockerfile.backend "$PACKAGE_DIR/"
cp Dockerfile.frontend "$PACKAGE_DIR/"
cp docker-compose.yml "$PACKAGE_DIR/"
cp docker-compose.prod.yml "$PACKAGE_DIR/"

# Nginx configs
cp nginx.conf "$PACKAGE_DIR/"
cp nginx-prod.conf "$PACKAGE_DIR/"

# Scripts
cp start.sh "$PACKAGE_DIR/"
cp run-local.sh "$PACKAGE_DIR/"
cp deploy.sh "$PACKAGE_DIR/"

# Environment and config files
cp .env.production "$PACKAGE_DIR/"
cp package.json "$PACKAGE_DIR/"

# Documentation
cp README.md "$PACKAGE_DIR/"
cp DEPLOYMENT.md "$PACKAGE_DIR/"
cp BRANDING.md "$PACKAGE_DIR/"
cp QUICKSTART.md "$PACKAGE_DIR/"
cp VPS_DEPLOYMENT_SUMMARY.md "$PACKAGE_DIR/"

# Make scripts executable
chmod +x "$PACKAGE_DIR"/*.sh

# Create deployment instructions
cat > "$PACKAGE_DIR/DEPLOY_INSTRUCTIONS.txt" << 'EOF'
StoryTime VPS Deployment Instructions
====================================

Quick Start:
1. Upload this entire folder to your VPS
2. SSH into your VPS
3. Run: chmod +x deploy.sh && ./deploy.sh

Detailed Steps:
1. Upload files to VPS (e.g., /var/www/storytime)
2. Edit backend/.env with your production settings
3. Run deployment script: ./deploy.sh -d your-domain.com
4. Configure SSL certificate
5. Test the application

For detailed instructions, see DEPLOYMENT.md

Important Security Notes:
- Change ADMIN_PASSWORD in backend/.env
- Generate new JWT_SECRET
- Update FRONTEND_URL with your domain
- Set up SSL certificate

Support:
- Check DEPLOYMENT.md for detailed instructions
- Check QUICKSTART.md for local development
- Check logs with: docker-compose logs
EOF

# Create archive
echo "🗜️  Creating deployment archive..."
tar -czf "${PACKAGE_NAME}.tar.gz" "$PACKAGE_DIR"

# Cleanup
rm -rf "$PACKAGE_DIR"

echo "✅ Deployment package created: ${PACKAGE_NAME}.tar.gz"
echo ""
echo "📤 Upload to your VPS:"
echo "   scp ${PACKAGE_NAME}.tar.gz user@your-vps:/var/www/"
echo ""
echo "📥 On your VPS:"
echo "   cd /var/www"
echo "   tar -xzf ${PACKAGE_NAME}.tar.gz"
echo "   cd ${PACKAGE_NAME}"
echo "   chmod +x deploy.sh"
echo "   ./deploy.sh -d your-domain.com"
echo ""
echo "📖 See DEPLOYMENT.md for detailed instructions"