# ConvertSave Libraries

Build system for conversion tool dependencies used by ConvertSave.

## What This Is

ConvertSave bundles conversion tools to work offline. This repository builds those tools from official sources when needed.

## Libraries

### ImageMagick
- **Platforms**: macOS (Intel + Apple Silicon), Windows, Linux
- **Features**: Q16, HDRI, HEIC/JPEG/PNG/TIFF/WebP support
- **Workflow**: `.github/workflows/build-imagemagick.yml`

### FFmpeg
- Currently using official pre-built binaries
- Custom builds can be added if needed

## Building

### Manual Build

1. Go to **Actions** → **Build ImageMagick**
2. Click **Run workflow**
3. Enter ImageMagick version (e.g., `7.1.1-42`)
4. Enter release tag (e.g., `v7.1.1-42`)
5. Download built artifacts from **Releases**

### Automatic Builds

Runs monthly to check for ImageMagick updates.

## Using the Builds

Download from [Releases](../../releases):
- `imagemagick-macos-x86_64.tar.gz` - Intel Macs
- `imagemagick-macos-arm64.tar.gz` - Apple Silicon
- `imagemagick-windows-x64.zip` - Windows
- `imagemagick-linux-x64.tar.gz` - Linux

Update ConvertSave to fetch from this repository's releases.

## Platform Notes

- **macOS**: Uses `@rpath` for relocatable binaries (no hardcoded paths)
- **Windows**: Includes all required DLLs from MSYS2
- **Linux**: Standard shared library build

## License

Build scripts are provided as-is. Built binaries follow their respective licenses:
- **ImageMagick**: Apache 2.0
- **FFmpeg**: LGPL 2.1+ or GPL 2+

