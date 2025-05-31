#!/bin/bash

# StoryTime GitHub Deployment Script
# This script deploys StoryTime directly from GitHub to your VPS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DOMAIN=""
GITHUB_REPO=""
BRANCH="main"
INSTALL_DIR="/var/www/storytime"
USE_DOCKER=true
SETUP_SSL=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 -r GITHUB_REPO [-d DOMAIN] [-b BRANCH] [-i INSTALL_DIR] [OPTIONS]"
    echo ""
    echo "Required:"
    echo "  -r GITHUB_REPO    GitHub repository URL (e.g., https://github.com/user/storytime.git)"
    echo ""
    echo "Optional:"
    echo "  -d DOMAIN         Domain name for the application"
    echo "  -b BRANCH         Git branch to deploy (default: main)"
    echo "  -i INSTALL_DIR    Installation directory (default: /var/www/storytime)"
    echo "  -n                Use Node.js instead of Docker"
    echo "  -s                Setup SSL certificate with Let's Encrypt"
    echo "  -h                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -r https://github.com/user/storytime.git -d example.com -s"
    echo "  $0 -r https://github.com/user/storytime.git -n"
}

# Parse command line arguments
while getopts "r:d:b:i:nsh" opt; do
    case $opt in
        r) GITHUB_REPO="$OPTARG" ;;
        d) DOMAIN="$OPTARG" ;;
        b) BRANCH="$OPTARG" ;;
        i) INSTALL_DIR="$OPTARG" ;;
        n) USE_DOCKER=false ;;
        s) SETUP_SSL=true ;;
        h) show_usage; exit 0 ;;
        \?) echo "Invalid option -$OPTARG" >&2; show_usage; exit 1 ;;
    esac
done

# Check if required parameters are provided
if [ -z "$GITHUB_REPO" ]; then
    print_error "GitHub repository URL is required!"
    show_usage
    exit 1
fi

print_status "Starting StoryTime deployment from GitHub..."
print_status "Repository: $GITHUB_REPO"
print_status "Branch: $BRANCH"
print_status "Install Directory: $INSTALL_DIR"
print_status "Use Docker: $USE_DOCKER"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (use sudo)"
    exit 1
fi

# Update system packages
print_status "Updating system packages..."
apt update && apt upgrade -y

# Install required packages
print_status "Installing required packages..."
apt install -y git curl wget unzip software-properties-common

# Install Node.js
print_status "Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi

# Install Docker if requested
if [ "$USE_DOCKER" = true ]; then
    print_status "Installing Docker..."
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
    fi
    
    # Install Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
fi

# Install Nginx
print_status "Installing Nginx..."
if ! command -v nginx &> /dev/null; then
    apt install -y nginx
fi

# Create installation directory
print_status "Creating installation directory..."
mkdir -p "$(dirname "$INSTALL_DIR")"

# Clone or update repository
if [ -d "$INSTALL_DIR" ]; then
    print_status "Updating existing repository..."
    cd "$INSTALL_DIR"
    git fetch origin
    git reset --hard "origin/$BRANCH"
    git clean -fd
else
    print_status "Cloning repository..."
    git clone -b "$BRANCH" "$GITHUB_REPO" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Make scripts executable
chmod +x deploy.sh 2>/dev/null || true
chmod +x run-local.sh 2>/dev/null || true

# Set up environment
print_status "Setting up environment..."
if [ ! -f "backend/.env" ]; then
    if [ -f ".env.production" ]; then
        cp .env.production backend/.env
    elif [ -f "backend/.env.example" ]; then
        cp backend/.env.example backend/.env
    else
        print_warning "No environment template found. Creating basic .env file..."
        cat > backend/.env << EOF
PORT=8080
NODE_ENV=production
ADMIN_PASSWORD=admin123
JWT_SECRET=$(openssl rand -base64 32)
DB_PATH=./database/pdfs.db
UPLOAD_DIR=../uploads
MAX_FILE_SIZE=50000000
FRONTEND_URL=http://localhost:3000
EOF
    fi
fi

# Update frontend URL if domain is provided
if [ -n "$DOMAIN" ]; then
    print_status "Updating frontend URL for domain: $DOMAIN"
    sed -i "s|FRONTEND_URL=.*|FRONTEND_URL=https://$DOMAIN|g" backend/.env
fi

# Create necessary directories
mkdir -p uploads backend/database backend/logs

# Set proper permissions
chown -R www-data:www-data "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"

# Deploy with Docker or Node.js
if [ "$USE_DOCKER" = true ]; then
    print_status "Deploying with Docker..."
    
    # Stop existing containers
    docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
    
    # Build and start containers
    docker-compose -f docker-compose.prod.yml up -d --build
    
    # Wait for containers to start
    sleep 10
    
    # Check container status
    if docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
        print_success "Docker containers started successfully!"
    else
        print_error "Failed to start Docker containers"
        docker-compose -f docker-compose.prod.yml logs
        exit 1
    fi
else
    print_status "Deploying with Node.js..."
    
    # Install PM2 globally
    npm install -g pm2
    
    # Install dependencies
    npm install
    cd frontend && npm install && npm run build
    cd ../backend && npm install
    cd ..
    
    # Stop existing PM2 processes
    pm2 delete storytime-backend 2>/dev/null || true
    
    # Start backend with PM2
    pm2 start backend/server.js --name "storytime-backend"
    pm2 startup
    pm2 save
    
    print_success "Application started with PM2!"
fi

# Configure Nginx
print_status "Configuring Nginx..."

# Remove default site if it exists
rm -f /etc/nginx/sites-enabled/default

# Create Nginx configuration
NGINX_CONFIG="/etc/nginx/sites-available/storytime"
cat > "$NGINX_CONFIG" << EOF
server {
    listen 80;
    server_name ${DOMAIN:-_};

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Frontend (React build)
    location / {
        root $INSTALL_DIR/frontend/build;
        try_files \$uri \$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Increase upload size limit
        client_max_body_size 50M;
    }

    # PDF uploads
    location /uploads/ {
        alias $INSTALL_DIR/uploads/;
        
        # Security: only allow PDF files
        location ~* \\.pdf\$ {
            add_header Content-Type application/pdf;
            add_header Content-Disposition inline;
        }
        
        # Deny access to other file types
        location ~ \\.(php|pl|py|jsp|asp|sh|cgi)\$ {
            deny all;
        }
    }
}
EOF

# Enable the site
ln -sf "$NGINX_CONFIG" /etc/nginx/sites-enabled/storytime

# Test Nginx configuration
if nginx -t; then
    print_success "Nginx configuration is valid"
    systemctl reload nginx
else
    print_error "Nginx configuration is invalid"
    exit 1
fi

# Setup SSL if requested and domain is provided
if [ "$SETUP_SSL" = true ] && [ -n "$DOMAIN" ]; then
    print_status "Setting up SSL certificate..."
    
    # Install Certbot
    if ! command -v certbot &> /dev/null; then
        apt install -y certbot python3-certbot-nginx
    fi
    
    # Get SSL certificate
    if certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email admin@"$DOMAIN"; then
        print_success "SSL certificate installed successfully!"
    else
        print_warning "Failed to install SSL certificate. You can try manually later with:"
        print_warning "certbot --nginx -d $DOMAIN"
    fi
fi

# Final status check
print_status "Checking application status..."

if [ "$USE_DOCKER" = true ]; then
    if docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
        print_success "✅ Docker containers are running"
    else
        print_error "❌ Docker containers are not running"
    fi
else
    if pm2 list | grep -q "storytime-backend.*online"; then
        print_success "✅ PM2 process is running"
    else
        print_error "❌ PM2 process is not running"
    fi
fi

if systemctl is-active --quiet nginx; then
    print_success "✅ Nginx is running"
else
    print_error "❌ Nginx is not running"
fi

# Show access information
echo ""
echo "🎉 StoryTime deployment completed!"
echo ""
echo "📋 Access Information:"
if [ -n "$DOMAIN" ]; then
    if [ "$SETUP_SSL" = true ]; then
        echo "   🌐 Frontend: https://$DOMAIN"
        echo "   🔐 Admin Panel: https://$DOMAIN/admin"
    else
        echo "   🌐 Frontend: http://$DOMAIN"
        echo "   🔐 Admin Panel: http://$DOMAIN/admin"
    fi
else
    echo "   🌐 Frontend: http://$(curl -s ifconfig.me)"
    echo "   🔐 Admin Panel: http://$(curl -s ifconfig.me)/admin"
fi
echo ""
echo "🔑 Admin Credentials:"
echo "   Username: admin"
echo "   Password: (check backend/.env file)"
echo ""
echo "📁 Installation Directory: $INSTALL_DIR"
echo ""
echo "🔧 Management Commands:"
if [ "$USE_DOCKER" = true ]; then
    echo "   View logs: docker-compose -f docker-compose.prod.yml logs -f"
    echo "   Restart: docker-compose -f docker-compose.prod.yml restart"
    echo "   Update: cd $INSTALL_DIR && git pull && docker-compose -f docker-compose.prod.yml up -d --build"
else
    echo "   View logs: pm2 logs storytime-backend"
    echo "   Restart: pm2 restart storytime-backend"
    echo "   Update: cd $INSTALL_DIR && git pull && cd frontend && npm run build && pm2 restart storytime-backend"
fi
echo ""
print_success "Deployment completed successfully! 🚀"