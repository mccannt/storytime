#!/bin/bash

# StoryTime Deployment Script for VPS

set -e

echo "🚀 StoryTime Deployment Script"
echo "================================"

# Configuration
APP_NAME="storytime"
APP_DIR="/var/www/$APP_NAME"
NGINX_SITE="/etc/nginx/sites-available/$APP_NAME"
DOMAIN=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running as root
# check_root() {
#     if [[ $EUID -eq 0 ]]; then
#         print_error "This script should not be run as root"
#         exit 1
#     fi
# }

# Check dependencies
check_dependencies() {
    echo "🔍 Checking dependencies..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        echo "Install Docker: https://docs.docker.com/engine/install/"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        echo "Install Docker Compose: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    # Check Nginx
    if ! command -v nginx &> /dev/null; then
        print_warning "Nginx is not installed"
        echo "Install with: sudo apt update && sudo apt install nginx"
    fi

    # Check lsof
    if ! command -v lsof &> /dev/null; then
        print_error "lsof is not installed. Please install it (e.g., sudo apt install lsof)"
        exit 1
    fi
    
    print_success "Dependencies check completed"
}

# Setup environment
setup_environment() {
    echo "🔧 Setting up environment..."
    
    # Create app directory
    sudo mkdir -p $APP_DIR
    sudo chown $USER:$USER $APP_DIR
    
    # Copy files
    cp -r ./* $APP_DIR/
    cd $APP_DIR
    
    # Setup production environment
    if [ ! -f backend/.env ]; then
        cp .env.production backend/.env
        print_warning "Created backend/.env from template"
        print_warning "Please edit backend/.env with your production settings"
    fi
    
    print_success "Environment setup completed"
}

# Cleanup existing containers and ports
cleanup_existing() {
    echo "🧹 Cleaning up existing containers and ports..."
    
    # Stop all containers with storytime in the name
    docker stop $(docker ps -q --filter "name=storytime") 2>/dev/null || true
    docker rm $(docker ps -aq --filter "name=storytime") 2>/dev/null || true
    
    # Stop containers using our specific names
    docker stop pdf-viewer-backend pdf-viewer-frontend 2>/dev/null || true
    docker rm pdf-viewer-backend pdf-viewer-frontend 2>/dev/null || true
    
    # Check and free ports
    PORT_3000_PID=$(lsof -ti:3000 2>/dev/null || true)
    if [ ! -z "$PORT_3000_PID" ]; then
        print_warning "Port 3000 is in use, freeing it..."
        sudo kill -9 "$PORT_3000_PID" 2>/dev/null || true
    fi

    PORT_8082_PID=$(lsof -ti:8082 2>/dev/null || true)
    if [ ! -z "$PORT_8082_PID" ]; then
        print_warning "Port 8082 is in use, freeing it..."
        sudo kill -9 "$PORT_8082_PID" 2>/dev/null || true
    fi

    # Clean up docker networks
    docker network rm storytime-network 2>/dev/null || true
    docker network rm pdf-viewer-network 2>/dev/null || true
    
    print_success "Cleanup completed"
}

# Build and start application
start_application() {
    echo "🏗️  Building and starting application..."
    
    cd $APP_DIR
    
    # Make scripts executable
    chmod +x run-local.sh cleanup-ports.sh
    
    # Cleanup existing containers and ports
    cleanup_existing
    
    # Stop any existing containers
    docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
    
    # Build and start with production compose file
    docker-compose -f docker-compose.prod.yml up -d --build
    
    # Wait for services to start
    echo "⏳ Waiting for services to start..."
    sleep 15
    
    # Check if services are running
    if docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
        print_success "Application started successfully"
        echo "Frontend: http://localhost:3000"
        echo "Backend: http://localhost:8081"
    else
        print_error "Failed to start application"
        echo "Check logs with: docker-compose -f docker-compose.prod.yml logs"
        exit 1
    fi
}

# Configure Nginx
configure_nginx() {
    if [ -z "$DOMAIN" ]; then
        print_warning "No domain specified, skipping Nginx configuration"
        print_warning "Manually configure Nginx using the template in DEPLOYMENT.md"
        return
    fi
    
    echo "🌐 Configuring Nginx for domain: $DOMAIN"
    
    # Create Nginx configuration
    sudo tee $NGINX_SITE > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    # SSL Configuration (update paths after getting certificates)
    # ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # Backend API
    location /api/ {
        proxy_pass http://localhost:8081;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        client_max_body_size 50M;
    }
    
    # Health check
    location /health {
        proxy_pass http://localhost:8081;
        access_log off;
    }
}
EOF
    
    # Enable site
    sudo ln -sf $NGINX_SITE /etc/nginx/sites-enabled/
    
    # Test configuration
    if sudo nginx -t; then
        sudo systemctl reload nginx
        print_success "Nginx configured successfully"
        print_warning "Don't forget to set up SSL certificates with Let's Encrypt"
    else
        print_error "Nginx configuration test failed"
        exit 1
    fi
}

# Setup SSL
setup_ssl() {
    if [ -z "$DOMAIN" ]; then
        print_warning "No domain specified, skipping SSL setup"
        return
    fi
    
    echo "🔒 Setting up SSL certificate..."
    
    if command -v certbot &> /dev/null; then
        sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN
        print_success "SSL certificate configured"
    else
        print_warning "Certbot not installed"
        echo "Install with: sudo apt install certbot python3-certbot-nginx"
        echo "Then run: sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN"
    fi
}

# Main deployment function
main() {
    echo "Starting StoryTime deployment..."
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain)
                DOMAIN="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  -d, --domain DOMAIN    Set domain name for Nginx configuration"
                echo "  -h, --help            Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    check_root
    check_dependencies
    setup_environment
    start_application
    
    if [ ! -z "$DOMAIN" ]; then
        configure_nginx
        setup_ssl
    fi
    
    echo ""
    echo "🎉 Deployment completed!"
    echo "================================"
    echo "Application: http://localhost:3000"
    echo "API: http://localhost:8080"
    if [ ! -z "$DOMAIN" ]; then
        echo "Domain: https://$DOMAIN"
    fi
    echo ""
    echo "📋 Next steps:"
    echo "1. Edit backend/.env with your production settings"
    echo "2. Change admin password and JWT secret"
    if [ -z "$DOMAIN" ]; then
        echo "3. Configure Nginx manually (see DEPLOYMENT.md)"
        echo "4. Set up SSL certificate"
    fi
    echo "5. Test the application"
    echo ""
    echo "📖 For detailed instructions, see DEPLOYMENT.md"
}

# Run main function
main "$@"