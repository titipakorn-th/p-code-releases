#!/bin/bash
# Docker-based build script for Windows and Linux binaries
# Run from within Docker container or use docker-build-all.sh

set -e

REPO_PATH="${1:-.}"
if [ ! -f "$REPO_PATH/Cargo.toml" ]; then
    echo "❌ Error: Cargo.toml not found in $REPO_PATH"
    echo "Usage: bash docker-build.sh /path/to/p-coder"
    exit 1
fi

cd "$REPO_PATH"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== P-Coder v1.0.2 Docker Multi-Platform Build ===${NC}"
echo -e "Repository: $REPO_PATH"
echo ""

# Create output directory
OUTPUT_DIR="./release-packages"
mkdir -p "$OUTPUT_DIR"

# Build Windows x86_64
echo -e "${BLUE}=== Building for Windows x86_64 ===${NC}"
cargo build --release --package p-coder-cli --target x86_64-pc-windows-gnu 2>&1 | tail -10

WIN_BINARY="./target/x86_64-pc-windows-gnu/release/p-coder.exe"
if [ -f "$WIN_BINARY" ]; then
    echo -e "${GREEN}✅ Windows binary built${NC}"
    cp "$WIN_BINARY" "$OUTPUT_DIR/p-coder-x86_64-pc-windows-gnu.exe"
    cd "$OUTPUT_DIR"
    zip -q p-coder-x86_64-pc-windows-gnu.zip p-coder-x86_64-pc-windows-gnu.exe
    shasum -a 256 p-coder-x86_64-pc-windows-gnu.zip > p-coder-x86_64-pc-windows-gnu.sha256
    WIN_SIZE=$(du -h p-coder-x86_64-pc-windows-gnu.zip | cut -f1)
    WIN_SHA=$(cat p-coder-x86_64-pc-windows-gnu.sha256 | cut -d' ' -f1)
    echo "  📦 p-coder-x86_64-pc-windows-gnu.zip ($WIN_SIZE)"
    echo "  🔐 SHA256: $WIN_SHA"
    cd ..
else
    echo -e "${RED}❌ Windows binary not found${NC}"
    exit 1
fi

echo ""

# Build Linux x86_64
echo -e "${BLUE}=== Building for Linux x86_64 ===${NC}"
cargo build --release --package p-coder-cli --target x86_64-unknown-linux-gnu 2>&1 | tail -10

LINUX_BINARY="./target/x86_64-unknown-linux-gnu/release/p-coder"
if [ -f "$LINUX_BINARY" ]; then
    echo -e "${GREEN}✅ Linux binary built${NC}"
    cp "$LINUX_BINARY" "$OUTPUT_DIR/p-coder-x86_64-unknown-linux-gnu"
    cd "$OUTPUT_DIR"
    zip -q p-coder-x86_64-unknown-linux-gnu.zip p-coder-x86_64-unknown-linux-gnu
    shasum -a 256 p-coder-x86_64-unknown-linux-gnu.zip > p-coder-x86_64-unknown-linux-gnu.sha256
    LINUX_SIZE=$(du -h p-coder-x86_64-unknown-linux-gnu.zip | cut -f1)
    LINUX_SHA=$(cat p-coder-x86_64-unknown-linux-gnu.sha256 | cut -d' ' -f1)
    echo "  📦 p-coder-x86_64-unknown-linux-gnu.zip ($LINUX_SIZE)"
    echo "  🔐 SHA256: $LINUX_SHA"
    cd ..
else
    echo -e "${RED}❌ Linux binary not found${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=== Build Complete ===${NC}"
echo ""
echo -e "${YELLOW}📋 Release Packages:${NC}"
ls -lh "$OUTPUT_DIR"/*.zip "$OUTPUT_DIR"/*.sha256 2>/dev/null | awk '{print "  " $9, "(" $5 ")"}'
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Copy files from release-packages/ directory"
echo "2. Upload to GitHub Releases (v1.0.2):"
echo "   gh release upload v1.0.2 p-coder-*.zip p-coder-*.sha256 \\"
echo "     --repo titipakorn-th/p-code-releases --clobber"
