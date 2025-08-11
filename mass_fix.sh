// Script to systematically replace all withOpacity with withValues
find /Users/hardman/Documents/shortsy_app/lib -name "*.dart" -type f -exec sed -i '' 's/\.withOpacity(\([0-9.]*\))/\.withValues(alpha: \1)/g' {} \;

// Replace print statements with developer.log
find /Users/hardman/Documents/shortsy_app/lib -name "*.dart" -type f -exec sed -i '' 's/print(\(.*\));/developer.log(\1);/g' {} \;

echo "All replacements completed"