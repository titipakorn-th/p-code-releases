#!/bin/bash
# Build script for Windows and Linux binaries on a Linux machine
# Usage: bash build-linux-windows.sh /path/to/rust-src
# This script builds p-coder v1.0.2 for Windows and Linux

set -e

REPO_PATH="${1:-.}"
if [ ! -f "$REPO_PATH/Cargo.toml" ]; then
    echo "❌ Error: Cargo.toml not found in $REPO_PATH"
    echo "Usage: bash build-linux-windows.sh /path/to/rust-src"
    exit 1
fi

cd "$REPO_PATH"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== P-Coder v1.0.2 Multi-Platform Build ===${NC}"
echo -e "Repository: $REPO_PATH"
echo ""

# Create output directory
OUTPUT_DIR="./release-packages"
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# Build Windows x86_64
echo -e "${BLUE}=== Building for Windows x86_64 ===${NC}"
if ! rustup target list | grep -q "x86_64-pc-windows-gnu (installed)"; then
    echo "Installing Windows GNU target..."
    rustup target add x86_64-pc-windows-gnu
fi

cargo build --release --package p-coder-cli --target x86_64-pc-windows-gnu

WIN_BINARY="../target/x86_64-pc-windows-gnu/release/p-coder.exe"
if [ -f "$WIN_BINARY" ]; then
    echo -e "${GREEN}✅ Windows binary built${NC}"
    cp "$WIN_BINARY" ./p-coder-x86_64-pc-windows-gnu.exe
    zip -q p-coder-x86_64-pc-windows-gnu.zip p-coder-x86_64-pc-windows-gnu.exe
    shasum -a 256 p-coder-x86_64-pc-windows-gnu.zip > p-coder-x86_64-pc-windows-gnu.sha256
    echo "  📦 p-coder-x86_64-pc-windows-gnu.zip ($(du -h p-coder-x86_64-pc-windows-gnu.zip | cut -f1))"
    echo "  🔐 SHA256: $(cat p-coder-x86_64-pc-windows-gnu.sha256)"
else
    echo -e "${RED}❌ Windows binary not found${NC}"
    exit 1
fi

echo ""

# Build Linux x86_64
echo -e "${BLUE}=== Building for Linux x86_64 ===${NC}"
if ! rustup target list | grep -q "x86_64-unknown-linux-gnu (installed)"; then
    echo "Installing Linux target..."
    rustup target add x86_64-unknown-linux-gnu
fi

cargo build --release --package p-coder-cli --target x86_64-unknown-linux-gnu

LINUX_BINARY="../target/x86_64-unknown-linux-gnu/release/p-coder"
if [ -f "$LINUX_BINARY" ]; then
    echo -e "${GREEN}✅ Linux binary built${NC}"
    cp "$LINUX_BINARY" ./p-coder-x86_64-unknown-linux-gnu
    zip -q p-coder-x86_64-unknown-linux-gnu.zip p-coder-x86_64-unknown-linux-gnu
    shasum -a 256 p-coder-x86_64-unknown-linux-gnu.zip > p-coder-x86_64-unknown-linux-gnu.sha256
    echo "  📦 p-coder-x86_64-unknown-linux-gnu.zip ($(du -h p-coder-x86_64-unknown-linux-gnu.zip | cut -f1))"
    echo "  🔐 SHA256: $(cat p-coder-x86_64-unknown-linux-gnu.sha256)"
else
    echo -e "${RED}❌ Linux binary not found${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=== Build Complete ===${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Download these files from $OUTPUT_DIR:"
find . -maxdepth 1 -name "*.zip" -o -name "*.sha256" | sort | sed 's/^\.\//   /'
echo ""
echo "2. Upload to GitHub Releases (v1.0.2):"
echo "   gh release upload v1.0.2 p-coder-*.zip p-coder-*.sha256 --repo titipakorn-th/p-code-releases"
echo ""
echo "3. Verify uploaded files:"
echo "   gh release view v1.0.2 --repo titipakorn-th/p-code-releases"
