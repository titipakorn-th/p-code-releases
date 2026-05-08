# Docker-Based Build Guide for P-Coder

Build Windows and Linux binaries for P-Coder v1.0.2 using Docker - works on any platform (macOS, Windows, Linux).

## Prerequisites

- **Docker Desktop** installed and running
  - macOS: https://www.docker.com/products/docker-desktop
  - Windows: https://www.docker.com/products/docker-desktop
  - Linux: `sudo apt install docker.io` (Debian/Ubuntu)

- **GitHub CLI** (optional, for uploading releases)
  - https://github.com/cli/cli

- **Git** (optional, for cloning repository)

## Quick Start (2 minutes)

```bash
# 1. Get the build script
curl -O https://raw.githubusercontent.com/titipakorn-th/p-code-releases/main/docker-build-all.sh
chmod +x docker-build-all.sh

# 2. Run the build (requires p-coder repo)
./docker-build-all.sh /path/to/p-coder

# 3. Upload to GitHub (optional)
cd /path/to/p-coder/release-packages
gh release upload v1.0.2 p-coder-*.zip p-coder-*.sha256 \
  --repo titipakorn-th/p-code-releases --clobber
```

## Detailed Setup

### 1. Install Docker

**macOS:**
```bash
# Install Docker Desktop via Homebrew
brew install --cask docker

# Or download from: https://www.docker.com/products/docker-desktop
# Then start Docker.app from Applications
```

**Windows:**
- Download and install from: https://www.docker.com/products/docker-desktop
- Enable WSL 2 backend in Docker settings

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install -y docker.io

# Add your user to docker group (optional, avoids sudo)
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Clone P-Coder Repository

```bash
git clone https://github.com/titipakorn-th/p-coder.git
cd p-coder
```

### 3. Get Build Scripts

The build scripts should be in the p-code-releases repo:

```bash
# Option A: From p-code-releases repo
git clone https://github.com/titipakorn-th/p-code-releases.git
cp p-code-releases/docker-build-all.sh .
cp p-code-releases/Dockerfile .
cp p-code-releases/docker-build.sh .

# Option B: Download directly
curl -O https://raw.githubusercontent.com/titipakorn-th/p-code-releases/main/docker-build-all.sh
curl -O https://raw.githubusercontent.com/titipakorn-th/p-code-releases/main/Dockerfile
curl -O https://raw.githubusercontent.com/titipakorn-th/p-code-releases/main/docker-build.sh

chmod +x docker-build-all.sh docker-build.sh
```

### 4. Run Build

```bash
# From p-coder repository root
./docker-build-all.sh .

# Or with full path
./docker-build-all.sh /path/to/p-coder
```

**Expected output:**
```
Step 1: Building Docker image...
✅ Docker image built

Step 2: Running build in Docker container...
[Build output...]
✅ Windows binary built
✅ Linux binary built

=== BUILD SUCCESSFUL ===

Next steps:
1. Upload binaries to GitHub Releases:
   cd /path/to/p-coder/release-packages
   gh release upload v1.0.2 p-coder-*.zip p-coder-*.sha256 \
     --repo titipakorn-th/p-code-releases --clobber
```

### 5. Build Artifacts

Output location: `./release-packages/`

**Files created:**
- `p-coder-x86_64-pc-windows-gnu.zip` - Windows binary
- `p-coder-x86_64-pc-windows-gnu.sha256` - Windows checksum
- `p-coder-x86_64-unknown-linux-gnu.zip` - Linux binary
- `p-coder-x86_64-unknown-linux-gnu.sha256` - Linux checksum

**Verify:**
```bash
cd release-packages
ls -lh *.zip
cat *.sha256
```

### 6. Upload to GitHub (Optional)

```bash
cd release-packages

# Install GitHub CLI if needed
# https://github.com/cli/cli

# Upload to v1.0.2 release
gh release upload v1.0.2 p-coder-*.zip p-coder-*.sha256 \
  --repo titipakorn-th/p-code-releases --clobber

# Verify
gh release view v1.0.2 --repo titipakorn-th/p-code-releases
```

## How It Works

### Docker Image (`Dockerfile`)
- Based on official Rust image
- Installs MinGW cross-compilation toolchain
- Installs development dependencies
- Pre-configures Rust targets for Windows and Linux

### Build Script (`docker-build-all.sh`)
On your machine (macOS/Windows/Linux):
1. Checks Docker is installed and running
2. Builds Docker image with all tools
3. Mounts your p-coder repository
4. Runs build in isolated container
5. Saves binaries to `release-packages/`

### Container Build Script (`docker-build.sh`)
Inside Docker container:
1. Builds Windows binary for x86_64-pc-windows-gnu
2. Builds Linux binary for x86_64-unknown-linux-gnu
3. Creates .zip archives for each
4. Generates SHA256 checksums
5. Exits with status 0 if successful

## Troubleshooting

### Docker not found
```bash
# Verify Docker is installed
docker --version

# Start Docker Desktop (macOS/Windows)
# Or start Docker daemon (Linux):
sudo systemctl start docker
```

### Docker build fails
```bash
# Check Docker logs
docker logs p-coder-builder

# Verify network connectivity inside container
docker run --rm rust:latest ping google.com

# Try rebuilding image from scratch
docker rmi p-coder-builder:latest
./docker-build-all.sh .
```

### Build exits early
```bash
# Check if p-coder repo has Cargo.toml
ls -la /path/to/p-coder/Cargo.toml

# Verify path is correct
pwd
ls Cargo.toml

# Check file permissions
chmod +x docker-build-all.sh docker-build.sh
```

### Disk space issues
```bash
# Check available space
df -h

# Clean Docker images (removes old builds)
docker system prune -a

# Verify after cleanup
docker images | grep p-coder
```

### Permission denied on Linux
```bash
# Run with sudo
sudo ./docker-build-all.sh .

# Or add user to docker group
sudo usermod -aG docker $USER
newgrp docker
./docker-build-all.sh .
```

## Manual Steps (Alternative)

If Docker doesn't work, you can build manually on Linux:

```bash
# On a Linux machine
cd /path/to/p-coder

# Install targets
rustup target add x86_64-pc-windows-gnu x86_64-unknown-linux-gnu

# Build Windows
cargo build --release --package p-coder-cli --target x86_64-pc-windows-gnu
mkdir -p release-packages
cp target/x86_64-pc-windows-gnu/release/p-coder.exe release-packages/
cd release-packages
zip p-coder-x86_64-pc-windows-gnu.zip p-coder.exe
shasum -a 256 p-coder-x86_64-pc-windows-gnu.zip > p-coder-x86_64-pc-windows-gnu.sha256

# Build Linux
cd /path/to/p-coder
cargo build --release --package p-coder-cli --target x86_64-unknown-linux-gnu
cp target/x86_64-unknown-linux-gnu/release/p-coder release-packages/
cd release-packages
zip p-coder-x86_64-unknown-linux-gnu.zip p-coder
shasum -a 256 p-coder-x86_64-unknown-linux-gnu.zip > p-coder-x86_64-unknown-linux-gnu.sha256
```

## What Platforms Support Docker?

| Platform | Support | Notes |
|----------|---------|-------|
| macOS (Apple Silicon) | ✅ | Docker Desktop with QEMU emulation |
| macOS (Intel) | ✅ | Docker Desktop |
| Windows 10/11 | ✅ | Docker Desktop with WSL 2 |
| Linux | ✅ | Docker daemon |

## Performance Notes

- **First build:** 3-5 minutes (builds Docker image)
- **Subsequent builds:** 2-3 minutes (reuses image)
- **Disk space:** ~2-3 GB for Docker image + build artifacts
- **Memory:** 4 GB recommended minimum

## Security

- ✅ Open source Dockerfile - review before building
- ✅ Official Rust base image
- ✅ No secrets stored in container
- ✅ Build artifacts isolated in mounted volume
- ✅ Container discarded after build

## Support

For issues:
1. Check Docker installation: `docker ps`
2. Verify p-coder repo: `ls Cargo.toml`
3. Check disk space: `df -h`
4. Review error messages carefully
5. Try manual build on Linux as fallback
