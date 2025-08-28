#!/bin/bash

echo "🚀 Starting Flutter Release APK Build..."

# Clean the project
echo "🧹 Cleaning project..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build release APK
echo "🔨 Building release APK..."
flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Release APK built successfully!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo "📏 APK size: $(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)"
else
    echo "❌ Build failed!"
    exit 1
fi
