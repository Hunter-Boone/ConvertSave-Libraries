# ConvertSave Libraries

Build system for conversion tool dependencies used by ConvertSave.

## What This Is

ConvertSave bundles conversion tools to work offline. This repository builds those tools from official sources when needed.

## Libraries

### ImageMagick

- **Platforms**: macOS (Intel + Apple Silicon), Linux
- **Features**: Q16, HDRI, HEIC/JPEG/PNG/TIFF/WebP support
- **macOS**: All dependencies bundled (freetype, jpeg, png, etc.)
- **Windows**: Use official portable builds from ImageMagick.org
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

### "latest" Release

The `latest` release tag is automatically updated with each new build. Use this URL pattern in ConvertSave:

```
https://github.com/Hunter-Boone/ConvertSave-Libraries/releases/download/latest/imagemagick-macos-x86_64.tar.gz
https://github.com/Hunter-Boone/ConvertSave-Libraries/releases/download/latest/imagemagick-macos-arm64.tar.gz
https://github.com/Hunter-Boone/ConvertSave-Libraries/releases/download/latest/imagemagick-linux-x64.tar.gz
```

### Versioned Releases

Specific versions are also available:

- Browse [Releases](../../releases) for specific versions
- Download `imagemagick-macos-x86_64.tar.gz`, `imagemagick-macos-arm64.tar.gz`, or `imagemagick-linux-x64.tar.gz`

### Windows

Use [official portable builds](https://imagemagick.org/script/download.php#windows)

## Platform Notes

- **macOS**: Uses `@rpath` for relocatable binaries with all dependencies bundled
- **Linux**: Standard shared library build
- **Windows**: Not built here - use official ImageMagick portable binaries

## License

Build scripts are provided as-is. Built binaries follow their respective licenses:

- **ImageMagick**: Apache 2.0
- **FFmpeg**: LGPL 2.1+ or GPL 2+
