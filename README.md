# P-Coder Releases

Binaries are distributed via [GitHub Releases](https://github.com/titipakorn-th/p-code-releases/releases).

## Installation

Download and run the install script:

```bash
curl -fsSL https://raw.githubusercontent.com/titipakorn-th/p-code-releases/main/install.sh | bash
```

The script will:
- Detect your OS and architecture
- Download the appropriate binary from GitHub Releases
- Install it to `~/.p-coder/bin/`
- Add it to your `$PATH` (optional)

### Options

```bash
# Install a specific version
curl -fsSL https://raw.githubusercontent.com/titipakorn-th/p-code-releases/main/install.sh | bash -s -- --version 1.0.0

# Install from a local binary
bash install.sh --binary /path/to/p-coder

# Don't modify shell config
bash install.sh --no-modify-path

# View all options
bash install.sh --help
```

## Supported Platforms

- **macOS**: Apple Silicon (aarch64), Intel (x86_64)
- **Windows**: x86_64
- **Linux**: x86_64, aarch64

## Latest Release

Latest version: [v1.0.2](https://github.com/titipakorn-th/p-code-releases/releases/tag/v1.0.2)

### What's New in v1.0.2

- Terminal color capability detection for older macOS
- Automatic 256-color fallback when TrueColor not supported
- RGB to 256-color conversion for better readability

## Manual Download

If you prefer to download manually:

1. Visit [GitHub Releases](https://github.com/titipakorn-th/p-code-releases/releases)
2. Download the binary for your platform
3. Extract: `unzip p-coder-*.zip` or `tar xzf p-coder-*.tar.gz`
4. Install: `chmod +x p-coder && sudo mv p-coder /usr/local/bin/`

## Verification

Check the checksum (available on release page):

```bash
shasum -a 256 p-coder-*.zip
```

## Support

For issues or questions:
- [GitHub Issues](https://github.com/titipakorn-th/p-code-releases/issues)
- [GitHub Discussions](https://github.com/titipakorn-th/p-code-releases/discussions)
