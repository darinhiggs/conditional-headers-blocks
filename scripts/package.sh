#!/bin/bash

# Conditional Headers (Blocks) - Packaging Script
# Creates a clean distribution-ready zip file

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PLUGIN_DIR="conditional-headers-blocks"
TEMP_DIR="/tmp/wp-plugin-build"
RELEASES_DIR="releases"

# Function to extract current version
get_current_version() {
    grep "Version:" conditional-headers-blocks.php | head -1 | sed 's/.*Version: *//' | sed 's/ *\*\/.*//'
}

# Function to clean up previous builds
cleanup() {
    echo -e "${YELLOW}Cleaning up previous builds...${NC}"
    rm -rf "$TEMP_DIR/$PLUGIN_DIR"
    mkdir -p "$TEMP_DIR"
    mkdir -p "$RELEASES_DIR"
}

# Function to copy plugin files
copy_files() {
    echo -e "${YELLOW}Copying plugin files...${NC}"
    
    # Create plugin directory in temp
    mkdir -p "$TEMP_DIR/$PLUGIN_DIR"
    
    # Copy essential files
    cp conditional-headers-blocks.php "$TEMP_DIR/$PLUGIN_DIR/"
    cp README.md "$TEMP_DIR/$PLUGIN_DIR/"
    
    # Copy directories
    cp -r classes/ "$TEMP_DIR/$PLUGIN_DIR/" 2>/dev/null || true
    cp -r assets/ "$TEMP_DIR/$PLUGIN_DIR/" 2>/dev/null || true
    cp -r build/ "$TEMP_DIR/$PLUGIN_DIR/" 2>/dev/null || true
    cp -r dist/ "$TEMP_DIR/$PLUGIN_DIR/" 2>/dev/null || true
    
    echo -e "${GREEN}✓ Files copied${NC}"
}

# Function to clean unnecessary files from build
clean_build_files() {
    echo -e "${YELLOW}Cleaning build files...${NC}"
    
    cd "$TEMP_DIR/$PLUGIN_DIR"
    
    # Remove development files
    rm -f .gitignore
    rm -f .git*
    rm -rf .git/
    rm -rf node_modules/
    rm -rf scripts/
    rm -f package.json
    rm -f package-lock.json
    rm -f yarn.lock
    rm -f .editorconfig
    rm -f .eslintrc*
    rm -f .prettierrc*
    rm -f webpack.config.js
    rm -f gulpfile.js
    
    # Remove backup files
    find . -name "*.bak" -delete
    find . -name "*.tmp" -delete
    find . -name "*.log" -delete
    find . -name "*.orig" -delete
    
    # Remove OS files
    find . -name ".DS_Store" -delete
    find . -name "Thumbs.db" -delete
    find . -name "._*" -delete
    
    # Remove empty directories
    find . -type d -empty -delete
    
    cd - > /dev/null
    
    echo -e "${GREEN}✓ Build cleaned${NC}"
}

# Function to create zip file
create_zip() {
    local version=$1
    local zip_name="conditional-headers-blocks-v${version}.zip"
    
    echo -e "${YELLOW}Creating zip file: ${zip_name}...${NC}"
    
    cd "$TEMP_DIR"
    zip -r "$zip_name" "$PLUGIN_DIR" -q
    
    # Move to releases directory
    mv "$zip_name" "$OLDPWD/$RELEASES_DIR/"
    
    cd - > /dev/null
    
    echo -e "${GREEN}✓ Zip file created: $RELEASES_DIR/$zip_name${NC}"
}

# Function to verify package
verify_package() {
    local version=$1
    local zip_name="conditional-headers-blocks-v${version}.zip"
    local zip_path="$RELEASES_DIR/$zip_name"
    
    echo -e "${YELLOW}Verifying package...${NC}"
    
    if [ ! -f "$zip_path" ]; then
        echo -e "${RED}✗ Package not found: $zip_path${NC}"
        return 1
    fi
    
    local zip_size=$(du -h "$zip_path" | cut -f1)
    echo -e "${BLUE}Package size: $zip_size${NC}"
    
    # Test zip integrity
    if unzip -t "$zip_path" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Package integrity verified${NC}"
    else
        echo -e "${RED}✗ Package integrity check failed${NC}"
        return 1
    fi
    
    # List contents
    echo -e "${BLUE}Package contents:${NC}"
    unzip -l "$zip_path" | grep -E "\.php$|\.js$|\.css$|README"
    
    echo -e "${GREEN}✓ Package verification completed${NC}"
}

# Main function
main() {
    # Check if we're in the plugin directory
    if [ ! -f "conditional-headers-blocks.php" ]; then
        echo -e "${RED}Error: Must be run from the plugin root directory${NC}"
        exit 1
    fi
    
    # Get current version
    local version=$(get_current_version)
    if [ -z "$version" ]; then
        echo -e "${RED}Error: Could not determine current version${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Creating package for version: ${version}${NC}"
    
    # Check if release already exists
    local zip_name="conditional-headers-blocks-v${version}.zip"
    if [ -f "$RELEASES_DIR/$zip_name" ]; then
        echo -e "${YELLOW}Release package already exists: $RELEASES_DIR/$zip_name${NC}"
        echo -e "${YELLOW}Do you want to overwrite it? (y/N)${NC}"
        read -r confirmation
        if [[ ! $confirmation =~ ^[Yy]$ ]]; then
            echo "Cancelled"
            exit 0
        fi
    fi
    
    # Build process
    cleanup
    copy_files
    clean_build_files
    create_zip "$version"
    verify_package "$version"
    
    # Cleanup temp files
    rm -rf "$TEMP_DIR/$PLUGIN_DIR"
    
    echo -e "${GREEN}✓ Package build completed!${NC}"
    echo -e "${BLUE}Package location: $RELEASES_DIR/$zip_name${NC}"
    
    # Show next steps
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Test the package on a staging site"
    echo "  2. Upload to production sites"
    echo "  3. Create GitHub release (if using GitHub)"
    echo "  4. Update any deployment documentation"
}

# Run main function
main "$@"