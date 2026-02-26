# ConvertSave Libraries

Build system for conversion tool dependencies used by ConvertSave.

## What This Is

ConvertSave bundles conversion tools to work offline. This repository builds those tools from official sources when needed.

## Libraries

### ImageMagick

- **Platforms**: macOS (Intel + Apple Silicon), Linux
- **Features**: Q16, HDRI, HEIC/JPEG/PNG/TIFF/WebP support (built-in coders)
- **macOS**: All dependencies bundled (freetype, jpeg, png, etc.)
- **Windows**: Use official portable builds from ImageMagick.org
- **Workflow**: `.github/workflows/build-imagemagick.yml`

### FFmpeg

- **Platforms**: macOS (Intel + Apple Silicon), Windows, Linux
- **License**: LGPL 2.1+ only (no GPL codecs, no non-free)
- **Linking**: Dynamic (`--enable-shared --disable-static`)
- **Source**: Built from [FFmpeg's official repository](https://github.com/FFmpeg/FFmpeg)
- **Codec support**: VP8/VP9 (libvpx), AV1 (libaom, rav1e on macOS), WebP, Opus, Vorbis, MP3 (LAME), WavPack, zimg
- **Hardware acceleration**: VideoToolbox/AudioToolbox (macOS), Media Foundation (Windows)
- **Workflow**: `.github/workflows/build-ffmpeg.yml`
- **Source tarball**: Uploaded alongside binaries in each release for LGPL compliance
- **Build config**: See `ffmpeg/BUILD_CONFIG.txt` for exact configure flags

## Building

### ImageMagick

1. Go to **Actions** → **Build ImageMagick**
2. Click **Run workflow**
3. Enter ImageMagick version (e.g., `7.1.1-42`)
4. Enter release tag (e.g., `v7.1.1-42`)
5. Download built artifacts from **Releases**

ImageMagick runs monthly to check for updates automatically.

### FFmpeg

1. Go to **Actions** → **Build FFmpeg (LGPL)**
2. Click **Run workflow**
3. Enter FFmpeg version tag (e.g., `n7.1`)
4. Enter release tag (e.g., `ffmpeg-7.1`)
5. Download built artifacts from **Releases**

## Using the Builds

### ImageMagick "latest" Release

```
https://github.com/Hunter-Boone/ConvertSave-Libraries/releases/download/latest/imagemagick-macos-x86_64.tar.gz
https://github.com/Hunter-Boone/ConvertSave-Libraries/releases/download/latest/imagemagick-macos-arm64.tar.gz
https://github.com/Hunter-Boone/ConvertSave-Libraries/releases/download/latest/imagemagick-linux-x64.tar.gz
```

### FFmpeg "ffmpeg-latest" Release

```
https://github.com/Hunter-Boone/ConvertSave-Libraries/releases/download/ffmpeg-latest/ffmpeg-macos-arm64.zip
https://github.com/Hunter-Boone/ConvertSave-Libraries/releases/download/ffmpeg-latest/ffmpeg-macos-x86_64.zip
https://github.com/Hunter-Boone/ConvertSave-Libraries/releases/download/ffmpeg-latest/ffmpeg-windows-x64.zip
https://github.com/Hunter-Boone/ConvertSave-Libraries/releases/download/ffmpeg-latest/ffmpeg-linux-x64.tar.gz
```

### Versioned Releases

Browse [Releases](../../releases) for specific versions of both ImageMagick and FFmpeg.

### Windows ImageMagick

Use [official portable builds](https://imagemagick.org/script/download.php#windows)

## Platform Notes

- **macOS**: Uses `@rpath` for relocatable binaries with all dependencies bundled
- **Linux**: Standard shared library build
- **Windows (ImageMagick)**: Not built here - use official ImageMagick portable binaries
- **Windows (FFmpeg)**: Built with MSYS2/MinGW64, all DLLs bundled

## License

Build scripts are provided as-is. Built binaries follow their respective licenses:

- **ImageMagick**: Apache 2.0
- **FFmpeg**: LGPLv2.1+ (built without GPL codecs)
