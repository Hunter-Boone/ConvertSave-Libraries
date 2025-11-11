# ConvertSave Libraries Build System

This repository contains GitHub Actions workflows to build conversion libraries from official sources for the ConvertSave application.

## Purpose

ConvertSave bundles conversion tools (FFmpeg, ImageMagick) to work offline. This repository automates building these tools from source with the exact configuration ConvertSave needs.

## Supported Libraries

### ImageMagick
- **Version**: Latest stable (7.1.x series)
- **Platforms**: macOS (x86_64, arm64), Windows (x64), Linux (x64)
- **Features**: HDRI, Q16, HEIC, JPEG, PNG, TIFF, WebP support
- **Workflow**: `.github/workflows/build-imagemagick.yml`

### FFmpeg (Future)
- Currently using pre-built binaries from official sources
- Custom builds may be added if needed for specific features

## How to Build

### Manual Build (Recommended)

1. Go to **Actions** tab in GitHub
2. Select **Build ImageMagick** workflow
3. Click **Run workflow**
4. Enter:
   - **ImageMagick version**: e.g., `7.1.1-39`
   - **Release tag**: e.g., `v7.1.1-39`
5. Click **Run workflow**

The workflow will:
- Build ImageMagick for all platforms
- Create a GitHub Release with downloadable artifacts
- Tag the release with your specified tag

### Automatic Builds

The workflow runs automatically on the 1st of each month to check for new ImageMagick versions.

## Using the Builds in ConvertSave

### Download from Releases

1. Go to [Releases](../../releases)
2. Download the appropriate build:
   - `imagemagick-macos-x86_64.tar.gz` - Intel Macs
   - `imagemagick-macos-arm64.tar.gz` - Apple Silicon
   - `imagemagick-windows-x64.zip` - Windows
   - `imagemagick-linux-x64.tar.gz` - Linux

3. Update ConvertSave's download URLs to point to these releases

### Integration

In `ConvertSave/src-tauri/src/main.rs`, update the `get_imagemagick_download_info()` function to fetch from this repository's releases:

```rust
async fn get_imagemagick_download_info() -> Result<(String, String, bool), String> {
    // Fetch latest release from ConvertSave-Libraries
    let release_url = "https://api.github.com/repos/YOUR_USERNAME/ConvertSave-Libraries/releases/latest";
    
    // Get appropriate asset URL based on platform
    // ...
}
```

## Build Configuration

### ImageMagick Configuration

```bash
--prefix=<install-dir>
--with-quantum-depth=16       # 16-bit color depth
--enable-hdri                  # High Dynamic Range Imaging
--with-modules                 # Modular architecture
--with-jpeg                    # JPEG support
--with-png                     # PNG support
--with-tiff                    # TIFF support
--with-webp                    # WebP support
--with-heic                    # HEIC/HEIF support
--disable-static               # Shared libraries only
--enable-shared                # Build shared libraries
```

### Platform-Specific Notes

#### macOS
- Builds for both Intel (x86_64) and Apple Silicon (arm64)
- Uses `@rpath` for relocatable binaries
- Libraries can be bundled without hardcoded paths
- Automatically fixes `install_name_tool` for all dylibs

#### Windows
- Built with MSYS2/MinGW64
- Includes all required DLLs
- Uses standard Windows dynamic linking

#### Linux
- Standard shared library build
- Expects system libraries (libjpeg, libpng, etc.)
- AppImage build could be added if needed

## Troubleshooting

### Build Fails

Check the Actions logs for specific errors. Common issues:
- Missing dependencies (unlikely, we install them)
- Download failure (check ImageMagick version exists)
- Network timeouts (re-run the workflow)

### Library Loading Issues

#### macOS
If getting "dyld: Library not loaded" errors:
- Verify `@rpath` is set correctly in the binary
- Check that all dylibs use relative paths
- Ensure ConvertSave sets `DYLD_LIBRARY_PATH` and `MAGICK_HOME`

#### Windows
If DLLs are missing:
- Check that all MinGW DLLs are included
- Verify the PATH includes the bin directory

## Development

### Testing Builds Locally

```bash
# macOS
cd imagemagick-build/package
./bin/magick --version

# Verify library paths
otool -L bin/magick

# Linux
cd imagemagick-build
./bin/magick --version

# Verify library dependencies
ldd bin/magick
```

### Adding New Features

To enable additional ImageMagick features:
1. Update the workflow's `configure` flags
2. Add required dependencies to the install step
3. Test the build
4. Update this README

## Version History

- Initial setup: ImageMagick 7.1.x builds for all platforms
- Future: FFmpeg custom builds if needed

## License

The build scripts in this repository are provided as-is. The built binaries are governed by their respective licenses:
- **ImageMagick**: Apache 2.0 License
- **FFmpeg**: LGPL 2.1+ or GPL 2+

## Contributing

To improve the build process:
1. Test the changes locally if possible
2. Update the workflow file
3. Document changes in this README
4. Create a test release to verify

