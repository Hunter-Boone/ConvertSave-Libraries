#!/bin/bash
set -e

# Build ImageMagick on macOS 11 with full HEIC support
# This script builds a fully portable ImageMagick with all dependencies bundled

IMAGEMAGICK_VERSION="7.1.1-47"
ARCH=$(uname -m)  # arm64 or x86_64
BUILD_DIR="$PWD/build-$ARCH"
PREFIX="$BUILD_DIR/imagemagick-install"

echo "=========================================="
echo "Building ImageMagick $IMAGEMAGICK_VERSION"
echo "Architecture: $ARCH"
echo "macOS Version: $(sw_vers -productVersion)"
echo "=========================================="

# Clean previous builds
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Install Homebrew dependencies (matching How to Convert's xcpkg formula)
echo "Installing dependencies via Homebrew..."
brew install pkg-config libtool autoconf automake ghostscript libheif liblqr libraw jpeg libpng libtiff webp freetype openjpeg openexr pango

# Determine Homebrew prefix
if [ "$ARCH" = "arm64" ]; then
    BREW_PREFIX="/opt/homebrew"
else
    BREW_PREFIX="/usr/local"
fi

# Download ImageMagick source
echo "Downloading ImageMagick source..."
curl -L "https://imagemagick.org/archive/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz" -o imagemagick.tar.gz
tar xzf imagemagick.tar.gz
cd "ImageMagick-${IMAGEMAGICK_VERSION}"

# Configure with all format support
echo "Configuring ImageMagick..."
export PKG_CONFIG_PATH="${BREW_PREFIX}/lib/pkgconfig:${BREW_PREFIX}/opt/libtool/lib/pkgconfig"
export CFLAGS="-I${BREW_PREFIX}/include"
export LDFLAGS="-L${BREW_PREFIX}/lib"
export CXXFLAGS="-I${BREW_PREFIX}/include"

./configure \
    --prefix="$PREFIX" \
    --with-quantum-depth=16 \
    --enable-hdri \
    --with-freetype=yes \
    --with-gvc=no \
    --with-modules \
    --with-openjp2 \
    --with-openexr \
    --with-webp=yes \
    --with-heic=yes \
    --with-gslib \
    --with-pango \
    --with-lqr \
    --with-raw=yes \
    --without-x \
    --without-wmf \
    --without-fftw \
    --disable-opencl \
    --enable-openmp \
    --enable-delegate-build \
    --disable-static \
    --enable-shared \
    --disable-dependency-tracking

# Build and install
echo "Building ImageMagick (this may take a few minutes)..."
make -j$(sysctl -n hw.ncpu)
make install

# Create package directory
echo "Packaging ImageMagick with dependencies..."
cd "$PREFIX"
mkdir -p package/bin package/lib package/etc

# Copy binaries
cp bin/magick package/bin/

# Copy ImageMagick libraries and config
cp -r lib/*.dylib package/lib/ 2>/dev/null || true
cp -r lib/ImageMagick-* package/lib/ 2>/dev/null || true

if [ -d etc/ImageMagick-7 ]; then
    cp -r etc/ImageMagick-7 package/etc/
fi

if [ -d share/ImageMagick-7 ]; then
    mkdir -p package/share
    cp -r share/ImageMagick-7 package/share/
fi

# Function to recursively copy all dylib dependencies
copy_deps() {
    local binary="$1"
    local level="${2:-0}"
    local indent=$(printf '%*s' $((level * 2)) '')
    
    [ $level -gt 10 ] && return  # Prevent infinite recursion
    
    echo "${indent}Processing: $(basename $binary)"
    
    # Get all dylib dependencies (excluding system libraries)
    otool -L "$binary" 2>/dev/null | grep -o '/.*\.dylib' | grep -v '/usr/lib' | grep -v '/System' | while read dep; do
        local dep_name=$(basename "$dep")
        local dest="package/lib/$dep_name"
        
        # Skip if already copied
        [ -f "$dest" ] && continue
        
        # Try to find and copy the dependency
        if [ -f "$dep" ]; then
            echo "${indent}  → Copying: $dep_name"
            cp "$dep" "$dest"
            copy_deps "$dest" $((level + 1))
        elif [ -f "$BREW_PREFIX/lib/$dep_name" ]; then
            echo "${indent}  → Copying: $dep_name (from Homebrew)"
            cp "$BREW_PREFIX/lib/$dep_name" "$dest"
            copy_deps "$dest" $((level + 1))
        else
            # Search in Cellar
            local found_path=$(find "$BREW_PREFIX/Cellar" -name "$dep_name" 2>/dev/null | head -1)
            if [ -n "$found_path" ] && [ -f "$found_path" ]; then
                echo "${indent}  → Copying: $dep_name (from Cellar)"
                cp "$found_path" "$dest"
                copy_deps "$dest" $((level + 1))
            fi
        fi
    done
}

# Copy all dependencies (multiple passes to catch indirect deps)
echo "Copying dependencies for magick binary..."
copy_deps "package/bin/magick" 0

echo "Copying dependencies for ImageMagick libraries..."
for pass in 1 2 3; do
    echo "Pass $pass..."
    for dylib in package/lib/*.dylib; do
        [ -f "$dylib" ] && copy_deps "$dylib" 0
    done
done

# List bundled libraries
echo "=========================================="
echo "Bundled libraries:"
ls -lh package/lib/*.dylib | awk '{print $9, $5}'
echo "=========================================="

# Fix library paths to use @rpath
echo "Fixing library paths for portability..."
for dylib in package/lib/*.dylib; do
    [ ! -f "$dylib" ] && continue
    
    # Change library ID to @rpath
    install_name_tool -id "@rpath/$(basename $dylib)" "$dylib" 2>/dev/null || true
    
    # Fix all dependencies to use @rpath
    otool -L "$dylib" | grep -o '/.*\.dylib' | grep -v '/usr/lib' | grep -v '/System' | while read dep; do
        install_name_tool -change "$dep" "@rpath/$(basename $dep)" "$dylib" 2>/dev/null || true
    done
done

# Fix magick binary
echo "Fixing magick binary paths..."
otool -L package/bin/magick | grep -o '/.*\.dylib' | grep -v '/usr/lib' | grep -v '/System' | while read dep; do
    install_name_tool -change "$dep" "@rpath/$(basename $dep)" package/bin/magick 2>/dev/null || true
done

# Add @rpath to magick binary
install_name_tool -add_rpath "@executable_path/../lib" package/bin/magick 2>/dev/null || true

# Verify HEIC support
echo "=========================================="
echo "Verifying HEIC support..."
if package/bin/magick identify -list format 2>/dev/null | grep -i heic; then
    echo "✅ HEIC support confirmed!"
else
    echo "⚠️  WARNING: HEIC support not detected"
fi
echo "=========================================="

# Create tarball
echo "Creating tarball..."
cd package
OUTPUT_FILE="$BUILD_DIR/../imagemagick-macos11-${ARCH}.tar.gz"
tar czf "$OUTPUT_FILE" .

echo "=========================================="
echo "✅ Build complete!"
echo "Output: $OUTPUT_FILE"
echo "Size: $(du -h "$OUTPUT_FILE" | awk '{print $1}')"
echo ""
echo "To upload to GitHub:"
echo "  gh release upload latest $OUTPUT_FILE --clobber"
echo ""
echo "Or manually upload to:"
echo "  https://github.com/Hunter-Boone/ConvertSave-Libraries/releases/tag/latest"
echo "=========================================="

