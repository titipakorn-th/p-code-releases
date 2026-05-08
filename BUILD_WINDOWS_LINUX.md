# Building P-Coder for Windows & Linux

This guide explains how to build Windows and Linux binaries for P-Coder v1.0.2 on a Linux machine.

## Prerequisites

- Linux system (any recent distribution)
- Rust toolchain installed: https://rustup.rs/
- Git
- Zip utility: `sudo apt install zip` (Debian/Ubuntu)
- MinGW toolchain for Windows cross-compilation: `sudo apt install mingw-w64` (Debian/Ubuntu)

## Quick Start

### 1. Install Dependencies

**On Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install -y rust-src rustup mingw-w64 zip
```

**On Fedora/CentOS:**
```bash
sudo dnf install -y rustup mingw64-toolchain zip
```

**On Arch:**
```bash
sudo pacman -S rustup mingw-w64-toolchain zip
```

### 2. Prepare Repository

```bash
# Clone the main repository
git clone https://github.com/titipakorn-th/p-coder.git
cd p-coder

# Verify you're on the correct version
git log --oneline | head -5
# Should show version 1.0.2 in Cargo.toml
```

### 3. Run Build Script

```bash
# Copy the build script
curl -O https://raw.githubusercontent.com/titipakorn-th/p-code-releases/main/build-linux-windows.sh
chmod +x build-linux-windows.sh

# Run the build (takes 10-15 minutes)
./build-linux-windows.sh /path/to/p-coder

# Or if you're in the p-coder directory:
./build-linux-windows.sh .
```

### 4. Verify Build Output

The script creates `release-packages/` directory with:
- `p-coder-x86_64-pc-windows-gnu.zip` (Windows binary)
- `p-coder-x86_64-pc-windows-gnu.sha256`
- `p-coder-x86_64-unknown-linux-gnu.zip` (Linux binary)
- `p-coder-x86_64-unknown-linux-gnu.sha256`

Check sizes and hashes:
```bash
cd release-packages
ls -lh *.zip
cat *.sha256
```

### 5. Upload to GitHub Releases

```bash
# Install GitHub CLI if not already installed
# https://github.com/cli/cli

cd release-packages

# Upload all binaries to v1.0.2 release
gh release upload v1.0.2 p-coder-*.zip p-coder-*.sha256 \
  --repo titipakorn-th/p-code-releases --clobber

# Verify
gh release view v1.0.2 --repo titipakorn-th/p-code-releases
```

## Manual Build (Alternative)

If the script doesn't work, build manually:

```bash
cd /path/to/p-coder

# Add targets if not already installed
rustup target add x86_64-pc-windows-gnu
rustup target add x86_64-unknown-linux-gnu

# Build Windows
cargo build --release --package p-coder-cli --target x86_64-pc-windows-gnu
cp target/x86_64-pc-windows-gnu/release/p-coder.exe p-coder-x86_64-pc-windows-gnu
zip p-coder-x86_64-pc-windows-gnu.zip p-coder-x86_64-pc-windows-gnu
shasum -a 256 p-coder-x86_64-pc-windows-gnu.zip > p-coder-x86_64-pc-windows-gnu.sha256

# Build Linux
cargo build --release --package p-coder-cli --target x86_64-unknown-linux-gnu
cp target/x86_64-unknown-linux-gnu/release/p-coder p-coder-x86_64-unknown-linux-gnu
zip p-coder-x86_64-unknown-linux-gnu.zip p-coder-x86_64-unknown-linux-gnu
shasum -a 256 p-coder-x86_64-unknown-linux-gnu.zip > p-coder-x86_64-unknown-linux-gnu.sha256
```

## Troubleshooting

### MinGW not found
```bash
# Update toolchain
rustup update

# Reinstall Windows target
rustup target remove x86_64-pc-windows-gnu
rustup target add x86_64-pc-windows-gnu

# On some systems, you may need:
sudo update-alternatives --install /usr/bin/x86_64-w64-mingw32-gcc \
  x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-10 60
```

### Build fails with linker errors
```bash
# Ensure all build dependencies are installed
sudo apt install build-essential libssl-dev pkg-config
```

### Disk space issues
The full build with all targets needs ~2-3 GB of disk space. Ensure you have enough:
```bash
df -h
```

## Platform Details

### Windows Binary (x86_64-pc-windows-gnu)
- Uses MinGW GNU toolchain
- Produces `.exe` executable
- Can run on Windows 7 or later
- Compatible with install.sh script

### Linux Binary (x86_64-unknown-linux-gnu)
- Statically linked where possible
- Works on glibc-based systems (Ubuntu, Debian, Fedora, CentOS)
- May not work on musl-only systems (Alpine)
- Compatible with install.sh script

## Release Checklist

- [ ] Build completed without errors
- [ ] File sizes reasonable (15-30 MB zipped)
- [ ] SHA256 checksums generated
- [ ] Tested extraction of zip files
- [ ] Uploaded to GitHub Releases v1.0.2
- [ ] Verified files appear in release
- [ ] Download and tested locally

## Next Steps

After releasing Windows and Linux binaries:

1. Update release notes on GitHub with all available platforms
2. Test install.sh with all three platforms:
   - macOS (aarch64 & x86_64)
   - Windows (x86_64)
   - Linux (x86_64)
3. Create platform-specific installation docs
4. Consider creating pre-built wheels/packages for package managers

## Support

If you encounter issues:
1. Check toolchain version: `rustc --version`
2. Verify targets installed: `rustup target list`
3. Check system dependencies: `dpkg -l | grep mingw`
4. Review build output for specific errors
5. Open an issue on GitHub with error messages
