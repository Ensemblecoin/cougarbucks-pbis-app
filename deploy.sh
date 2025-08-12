#!/bin/bash

# CougarBucks Deployment Script
# This script helps deploy the CougarBucks PBIS application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Node.js version
check_node_version() {
    if command_exists node; then
        NODE_VERSION=$(node --version | cut -d'v' -f2)
        MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1)
        if [ "$MAJOR_VERSION" -ge 18 ]; then
            print_success "Node.js version $NODE_VERSION is compatible"
        else
            print_error "Node.js version $NODE_VERSION is not supported. Please install Node.js 18 or higher."
            exit 1
        fi
    else
        print_error "Node.js is not installed. Please install Node.js 18 or higher."
        exit 1
    fi
}

# Function to setup environment
setup_environment() {
    print_status "Setting up environment..."
    
    if [ ! -f ".env.production" ]; then
        if [ -f ".env.production.template" ]; then
            cp .env.production.template .env.production
            print_warning "Created .env.production from template. Please edit it with your actual values."
            print_warning "Required variables: NEXTAUTH_SECRET, NEXTAUTH_URL, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET"
        else
            print_error ".env.production.template not found. Cannot create environment file."
            exit 1
        fi
    else
        print_success "Environment file .env.production already exists"
    fi
}

# Function to install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    npm ci
    print_success "Dependencies installed successfully"
}

# Function to run linting
run_lint() {
    print_status "Running linting..."
    npm run lint
    print_success "Linting completed successfully"
}

# Function to build application
build_application() {
    print_status "Building application for production..."
    npm run build
    print_success "Application built successfully"
}

# Function to test application
test_application() {
    print_status "Testing application..."
    
    # Start the application in background
    npm start &
    APP_PID=$!
    
    # Wait for application to start
    sleep 10
    
    # Test health endpoint
    if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
        print_success "Health check passed"
    else
        print_error "Health check failed"
        kill $APP_PID 2>/dev/null || true
        exit 1
    fi
    
    # Test main page
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        print_success "Main page accessible"
    else
        print_error "Main page not accessible"
        kill $APP_PID 2>/dev/null || true
        exit 1
    fi
    
    # Stop the application
    kill $APP_PID 2>/dev/null || true
    print_success "Application tests completed"
}

# Function to deploy with PM2
deploy_pm2() {
    print_status "Deploying with PM2..."
    
    if ! command_exists pm2; then
        print_status "Installing PM2..."
        npm install -g pm2
    fi
    
    # Stop existing application if running
    pm2 stop cougarbucks 2>/dev/null || true
    pm2 delete cougarbucks 2>/dev/null || true
    
    # Start application with PM2
    pm2 start npm --name "cougarbucks" -- start
    pm2 save
    
    print_success "Application deployed with PM2"
    print_status "Use 'pm2 logs cougarbucks' to view logs"
    print_status "Use 'pm2 status' to check status"
}

# Function to deploy with Docker
deploy_docker() {
    print_status "Deploying with Docker..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Build Docker image
    print_status "Building Docker image..."
    docker build -t cougarbucks:latest .
    
    # Stop existing container if running
    docker stop cougarbucks 2>/dev/null || true
    docker rm cougarbucks 2>/dev/null || true
    
    # Run new container
    print_status "Starting Docker container..."
    docker run -d \
        --name cougarbucks \
        --restart unless-stopped \
        -p 3000:3000 \
        --env-file .env.production \
        cougarbucks:latest
    
    print_success "Application deployed with Docker"
    print_status "Use 'docker logs cougarbucks' to view logs"
    print_status "Use 'docker ps' to check status"
}

# Function to deploy with Docker Compose
deploy_docker_compose() {
    print_status "Deploying with Docker Compose..."
    
    if ! command_exists docker-compose && ! command_exists docker; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Use docker compose or docker-compose based on availability
    COMPOSE_CMD="docker compose"
    if ! command_exists docker || ! docker compose version >/dev/null 2>&1; then
        if command_exists docker-compose; then
            COMPOSE_CMD="docker-compose"
        else
            print_error "Neither 'docker compose' nor 'docker-compose' is available."
            exit 1
        fi
    fi
    
    # Stop existing services
    $COMPOSE_CMD down 2>/dev/null || true
    
    # Start services
    print_status "Starting services with Docker Compose..."
    $COMPOSE_CMD up -d --build
    
    print_success "Application deployed with Docker Compose"
    print_status "Use '$COMPOSE_CMD logs -f' to view logs"
    print_status "Use '$COMPOSE_CMD ps' to check status"
}

# Function to show deployment status
show_status() {
    print_status "Checking deployment status..."
    
    # Check if application is running on port 3000
    if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
        print_success "Application is running and healthy"
        
        # Get health information
        HEALTH_INFO=$(curl -s http://localhost:3000/api/health)
        echo "Health Status: $HEALTH_INFO"
    else
        print_warning "Application is not responding on port 3000"
    fi
    
    # Check PM2 status if available
    if command_exists pm2; then
        print_status "PM2 Status:"
        pm2 status 2>/dev/null || print_warning "No PM2 processes found"
    fi
    
    # Check Docker status if available
    if command_exists docker; then
        print_status "Docker Status:"
        docker ps --filter "name=cougarbucks" 2>/dev/null || print_warning "No Docker containers found"
    fi
}

# Main deployment function
main() {
    echo "========================================="
    echo "   CougarBucks Deployment Script"
    echo "========================================="
    echo ""
    
    # Parse command line arguments
    DEPLOYMENT_TYPE=${1:-"pm2"}
    
    case $DEPLOYMENT_TYPE in
        "pm2")
            print_status "Deploying with PM2..."
            ;;
        "docker")
            print_status "Deploying with Docker..."
            ;;
        "docker-compose")
            print_status "Deploying with Docker Compose..."
            ;;
        "build-only")
            print_status "Building application only..."
            ;;
        "status")
            show_status
            exit 0
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [deployment-type]"
            echo ""
            echo "Deployment types:"
            echo "  pm2             Deploy with PM2 (default)"
            echo "  docker          Deploy with Docker"
            echo "  docker-compose  Deploy with Docker Compose"
            echo "  build-only      Build application without deploying"
            echo "  status          Check deployment status"
            echo "  help            Show this help message"
            echo ""
            exit 0
            ;;
        *)
            print_error "Unknown deployment type: $DEPLOYMENT_TYPE"
            print_status "Use '$0 help' to see available options"
            exit 1
            ;;
    esac
    
    # Pre-deployment checks
    check_node_version
    setup_environment
    
    # Build process
    install_dependencies
    run_lint
    build_application
    
    # Skip deployment for build-only
    if [ "$DEPLOYMENT_TYPE" = "build-only" ]; then
        print_success "Build completed successfully"
        exit 0
    fi
    
    # Test application
    test_application
    
    # Deploy based on type
    case $DEPLOYMENT_TYPE in
        "pm2")
            deploy_pm2
            ;;
        "docker")
            deploy_docker
            ;;
        "docker-compose")
            deploy_docker_compose
            ;;
    esac
    
    # Wait a moment for deployment to stabilize
    sleep 5
    
    # Show final status
    show_status
    
    echo ""
    print_success "Deployment completed successfully!"
    print_status "Your CougarBucks application should now be running on http://localhost:3000"
    print_status "Check the health endpoint: http://localhost:3000/api/health"
    echo ""
}

# Run main function with all arguments
main "$@"
