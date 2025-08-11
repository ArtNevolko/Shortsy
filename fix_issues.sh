#!/bin/bash

# Script to fix all withOpacity and print issues in Flutter project

echo "Fixing withOpacity to withValues..."

# Fix working_main_screen.dart
sed -i '' 's/\.withOpacity(\([0-9.]*\))/\.withValues(alpha: \1)/g' "/Users/hardman/Documents/shortsy_app/lib/screens/working_main_screen.dart"

# Fix video_feed_screen.dart
sed -i '' 's/\.withOpacity(\([0-9.]*\))/\.withValues(alpha: \1)/g' "/Users/hardman/Documents/shortsy_app/lib/widgets/video_feed_screen.dart"

# Fix stylish_camera_screen.dart
sed -i '' 's/\.withOpacity(\([0-9.]*\))/\.withValues(alpha: \1)/g' "/Users/hardman/Documents/shortsy_app/lib/widgets/stylish_camera_screen.dart"

echo "Fixing print statements..."

# Fix simple_camera_service.dart
sed -i '' '1i\
import '\''dart:developer'\'' as developer;
' "/Users/hardman/Documents/shortsy_app/lib/services/simple_camera_service.dart"

sed -i '' 's/print(\(.*\));/developer.log(\1, name: '\''CameraService'\'');/g' "/Users/hardman/Documents/shortsy_app/lib/services/simple_camera_service.dart"

# Fix permission_service.dart
sed -i '' '1i\
import '\''dart:developer'\'' as developer;
' "/Users/hardman/Documents/shortsy_app/lib/services/permission_service.dart"

sed -i '' 's/print(\(.*\));/developer.log(\1, name: '\''PermissionService'\'');/g' "/Users/hardman/Documents/shortsy_app/lib/services/permission_service.dart"

# Fix stylish_camera_screen.dart print
sed -i '' 's/print(\(.*\));/developer.log(\1, name: '\''StylishCameraScreen'\'');/g' "/Users/hardman/Documents/shortsy_app/lib/widgets/stylish_camera_screen.dart"

echo "All fixes applied!"