#!/bin/bash
# Complete cleanup script to remove all GitLive Firebase traces
# Run this script, then rebuild in Xcode

set -e

echo "=== KMM Firebase Cleanup Script ==="
echo ""

# Kill Xcode
echo "Step 1: Killing Xcode..."
killall Xcode 2>/dev/null || echo "Xcode was not running"

# Navigate to project
cd /Users/sabalkatuwal/Dev/KMM

# Clean project build directories
echo "Step 2: Cleaning project build directories..."
rm -rf shared/build
rm -rf build
rm -rf .gradle
rm -rf composeApp/build
echo "  ✓ Project build directories cleaned"

# Clean Gradle caches for GitLive
echo "Step 3: Cleaning Gradle caches..."
rm -rf ~/.gradle/caches/modules-2/files-2.1/dev.gitlive* 2>/dev/null || true
rm -rf ~/.gradle/caches/transforms-*/**/dev.gitlive* 2>/dev/null || true
echo "  ✓ Gradle caches cleaned"

# Clean Kotlin/Native cache
echo "Step 4: Cleaning Kotlin/Native cache..."
rm -rf ~/.konan
echo "  ✓ Kotlin/Native cache cleaned"

# Clean Xcode caches
echo "Step 5: Cleaning Xcode caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/org.swift.swiftpm
echo "  ✓ Xcode caches cleaned"

# Verify no gitlive references
echo ""
echo "Step 6: Verifying no GitLive references in code..."
if grep -r "gitlive" . --include="*.kts" --include="*.toml" --include="*.kt" 2>/dev/null; then
    echo "  ⚠️  WARNING: GitLive references still found!"
else
    echo "  ✓ No GitLive references found - CLEAN!"
fi

# Rebuild with Gradle
echo ""
echo "Step 7: Rebuilding shared module with fresh dependencies..."
./gradlew :shared:compileKotlinIosArm64 --no-daemon --refresh-dependencies

echo ""
echo "=== Cleanup Complete ==="
echo ""
echo "Now open Xcode and:"
echo "1. File → Packages → Reset Package Caches"
echo "2. Product → Clean Build Folder (⇧⌘K)"
echo "3. Product → Build (⌘B)"
echo ""
echo "Opening Xcode..."
open /Users/sabalkatuwal/Dev/KMM/iosApp/iosApp.xcodeproj

