#!/bin/bash
# Docker-based cross-platform build for macOS
# Builds Windows and Linux binaries using Docker
# Usage: bash docker-build-all.sh /path/to/p-coder

set -e

REPO_PATH="${1:-.}"

if [ ! -f "$REPO_PATH/Cargo.toml" ]; then
    echo "❌ Error: Cargo.toml not found in $REPO_PATH"
    echo "Usage: bash docker-build-all.sh /path/to/p-coder"
    exit 1
fi

# Resolve absolute path
REPO_PATH="$(cd "$REPO_PATH" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   P-Coder v1.0.2 Docker Multi-Platform Build               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Repository: $REPO_PATH"
echo "Docker: $(docker --version)"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed or not in PATH${NC}"
    echo "Install Docker from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check Docker daemon
if ! docker ps > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker daemon is not running${NC}"
    echo "Start Docker Desktop and try again"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${YELLOW}Step 1: Building Docker image...${NC}"
echo ""

# Build Docker image
docker build -t p-coder-builder:latest "$SCRIPT_DIR" 2>&1 | grep -E "(Step|Sending|Successfully|error)" || true

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Docker build failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Docker image built${NC}"
echo ""

echo -e "${YELLOW}Step 2: Running build in Docker container...${NC}"
echo ""

# Run build in Docker container
docker run --rm \
    -v "$REPO_PATH:/workspace" \
    -e TERM=xterm-256color \
    p-coder-builder:latest \
    "/bin/bash" "-c" "cd /workspace && bash docker-build.sh ."

BUILD_STATUS=$?

echo ""
echo -e "${YELLOW}Step 3: Verifying build artifacts...${NC}"
echo ""

if [ $BUILD_STATUS -eq 0 ]; then
    OUTPUT_DIR="$REPO_PATH/release-packages"
    
    if [ -d "$OUTPUT_DIR" ]; then
        echo -e "${GREEN}✅ Build artifacts found:${NC}"
        ls -lh "$OUTPUT_DIR"/*.zip "$OUTPUT_DIR"/*.sha256 2>/dev/null | awk '{printf "   %s (%s)\n", $9, $5}'
        
        echo ""
        echo -e "${GREEN}=== BUILD SUCCESSFUL ===${NC}"
        echo ""
        echo -e "${BLUE}Next steps:${NC}"
        echo ""
        echo "1. Upload binaries to GitHub Releases:"
        echo ""
        echo "   cd $OUTPUT_DIR"
        echo "   gh release upload v1.0.2 p-coder-*.zip p-coder-*.sha256 \\"
        echo "     --repo titipakorn-th/p-code-releases --clobber"
        echo ""
        echo "2. Verify upload:"
        echo ""
        echo "   gh release view v1.0.2 --repo titipakorn-th/p-code-releases"
        echo ""
        echo "3. Test installation:"
        echo ""
        echo "   # Windows binary"
        echo "   unzip $OUTPUT_DIR/p-coder-x86_64-pc-windows-gnu.zip"
        echo ""
        echo "   # Linux binary"
        echo "   unzip $OUTPUT_DIR/p-coder-x86_64-unknown-linux-gnu.zip"
        echo "   chmod +x p-coder-x86_64-unknown-linux-gnu"
        echo ""
    else
        echo -e "${RED}❌ Release packages directory not found${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Build failed inside Docker container${NC}"
    exit 1
fi
