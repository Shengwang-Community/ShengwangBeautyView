#!/bin/bash

# Script to check and create KeyCenter.swift from template
# This should be added to Xcode Build Phases
# This script will FAIL the build if KeyCenter is not properly configured

set -e

# Get SRCROOT if not set (for manual testing)
if [ -z "$SRCROOT" ]; then
    # Try to find project root by looking for BeautyView.xcodeproj
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    SRCROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
fi

# KeyCenter file should be in BeautyView directory (source code directory)
KEYCENTER_FILE="${SRCROOT}/BeautyView/KeyCenter.swift"
# Template file should also be in BeautyView directory
TEMPLATE_FILE="${SRCROOT}/BeautyView/KeyCenter.swift.example"

echo "🔍 Checking KeyCenter.swift configuration..."

# Check if KeyCenter.swift exists
if [ ! -f "$KEYCENTER_FILE" ]; then
    echo ""
    echo "❌ ERROR: KeyCenter.swift not found!"
    echo ""
    
    # Check if template exists
    if [ -f "$TEMPLATE_FILE" ]; then
        echo "📝 Creating KeyCenter.swift from template..."
        cp "$TEMPLATE_FILE" "$KEYCENTER_FILE"
        # Remove .example extension from the copied file's header comment
        sed -i '' 's/KeyCenter.swift.example/KeyCenter.swift/g' "$KEYCENTER_FILE"
        echo ""
        echo "╔════════════════════════════════════════════════════════╗"
        echo "║  ⚠️  BUILD FAILED: KeyCenter needs configuration     ║"
        echo "╚════════════════════════════════════════════════════════╝"
        echo ""
        echo "KeyCenter.swift has been created from template at:"
        echo "  $KEYCENTER_FILE"
        echo ""
        echo "Please update it with your actual Agora credentials:"
        echo "  • AppId: Replace 'YOUR_APP_ID_HERE' with your actual Agora App ID"
        echo "  • Certificate: Set your certificate if needed (or leave as nil)"
        echo ""
        echo "Get your credentials from: https://console.shengwang.cn/"
        echo ""
        echo "Then rebuild the project."
        echo ""
        exit 1
    else
        echo "❌ FATAL ERROR: Template file not found!"
        echo ""
        echo "Expected template at: $TEMPLATE_FILE"
        echo ""
        echo "Please ensure KeyCenter.swift.example exists in BeautyView folder"
        echo ""
        exit 1
    fi
fi

# Validate that KeyCenter.swift has been properly configured
if grep -q "YOUR_APP_ID_HERE" "$KEYCENTER_FILE"; then
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║  ❌ BUILD FAILED: KeyCenter not configured           ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo "KeyCenter.swift still contains placeholder values!"
    echo ""
    echo "File location:"
    echo "  $KEYCENTER_FILE"
    echo ""
    echo "Required actions:"
    echo "  1. Open KeyCenter.swift"
    echo "  2. Replace 'YOUR_APP_ID_HERE' with your actual Agora App ID"
    echo "  3. Configure Certificate if needed (or leave as nil)"
    echo ""
    echo "Get credentials from: https://console.shengwang.cn/"
    echo ""
    exit 1
fi

# Additional validation: check if essential fields are not empty
if grep -q 'AppId: String = ""' "$KEYCENTER_FILE"; then
    echo ""
    echo "❌ BUILD FAILED: AppId is empty in KeyCenter.swift"
    echo ""
    echo "Please configure your Agora App ID and rebuild."
    echo ""
    exit 1
fi

echo "✅ KeyCenter.swift validation passed"
echo ""
