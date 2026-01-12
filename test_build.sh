#!/bin/bash
# Run this script to test if the shared module can be built
# Usage: ./test_build.sh

set -e

echo "=== KMM Build Test Script ==="
echo ""

# Check Java
echo "Checking Java..."
if command -v java &> /dev/null; then
    echo "✓ Java found:"
    java -version 2>&1 | head -3
else
    echo "✗ Java NOT found!"
    echo "  Install with: brew install openjdk@17"
    echo "  Then add to PATH: echo 'export PATH=\"/opt/homebrew/opt/openjdk@17/bin:\$PATH\"' >> ~/.zshrc"
    exit 1
fi

echo ""
echo "JAVA_HOME: ${JAVA_HOME:-NOT SET}"
echo ""

# Navigate to project
cd "$(dirname "$0")"
echo "Working directory: $(pwd)"
echo ""

# Try to compile
echo "=== Attempting to compile shared module for iOS Simulator ==="
./gradlew :shared:compileKotlinIosSimulatorArm64 --no-daemon 2>&1

echo ""
echo "=== Build successful! ==="
echo "You can now build the iOS app in Xcode."

