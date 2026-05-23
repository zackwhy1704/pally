#!/usr/bin/env bash
# Pally project setup script
# Run this once from the project root: chmod +x setup.sh && ./setup.sh

set -e

echo "🚀 Setting up Pally Flutter project..."

# Step 1: Initialize Flutter project (preserves existing lib/ files)
echo "📦 Running flutter create..."
flutter create . --org com.pally --project-name pally

# Step 2: Install dependencies
echo "📦 Running flutter pub get..."
flutter pub get

# Step 3: Run code generation
echo "⚙️  Running build_runner..."
dart run build_runner build --delete-conflicting-outputs

echo "✅ Setup complete! Open the project in Android Studio or VS Code."
echo ""
echo "To run the app:"
echo "  flutter run --dart-define=API_BASE_URL=http://localhost:8080"
