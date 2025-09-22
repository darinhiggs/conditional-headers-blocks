#!/bin/bash

# Conditional Headers (Blocks) - Version Management Script
# Usage: ./scripts/version-bump.sh [major|minor|patch] [optional-message]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PLUGIN_FILE="conditional-headers-blocks.php"
CLASS_FILE="classes/class-conditional-headers-blocks.php"
README_FILE="README.md"

# Function to display usage
show_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo "  ./scripts/version-bump.sh [major|minor|patch] [optional-message]"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  ./scripts/version-bump.sh patch \"Fix login condition bug\""
    echo "  ./scripts/version-bump.sh minor \"Add new post type conditions\""
    echo "  ./scripts/version-bump.sh major \"Breaking changes to API\""
    echo ""
    exit 1
}

# Function to extract current version
get_current_version() {
    grep "Version:" $PLUGIN_FILE | head -1 | sed 's/.*Version: *//' | sed 's/ *\*\/.*//'
}

# Function to increment version
increment_version() {
    local version=$1
    local type=$2
    
    IFS='.' read -r -a version_parts <<< "$version"
    major=${version_parts[0]}
    minor=${version_parts[1]}
    patch=${version_parts[2]}
    
    case $type in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "patch")
            patch=$((patch + 1))
            ;;
        *)
            echo -e "${RED}Error: Invalid version type. Use major, minor, or patch${NC}"
            exit 1
            ;;
    esac
    
    echo "${major}.${minor}.${patch}"
}

# Function to update version in files
update_version_in_files() {
    local old_version=$1
    local new_version=$2
    
    echo -e "${YELLOW}Updating version from ${old_version} to ${new_version}...${NC}"
    
    # Update main plugin file
    sed -i.bak "s/Version: *${old_version}/Version: ${new_version}/" $PLUGIN_FILE
    sed -i.bak "s/\$version = '${old_version}'/\$version = '${new_version}'/" $PLUGIN_FILE
    
    # Update class file if it contains version
    if grep -q "version.*${old_version}" $CLASS_FILE; then
        sed -i.bak "s/${old_version}/${new_version}/g" $CLASS_FILE
    fi
    
    # Update README
    sed -i.bak "s/Version:** ${old_version}/Version:** ${new_version}/" $README_FILE
    
    # Clean up backup files
    rm -f $PLUGIN_FILE.bak $CLASS_FILE.bak $README_FILE.bak
    
    echo -e "${GREEN}✓ Version updated in all files${NC}"
}

# Function to update changelog
update_changelog() {
    local version=$1
    local message=$2
    local date=$(date +"%Y-%m-%d")
    
    # Create changelog entry
    local changelog_entry="### ${version} - ${date}"
    if [ ! -z "$message" ]; then
        changelog_entry="${changelog_entry}\n- ${message}"
    else
        changelog_entry="${changelog_entry}\n- Version bump"
    fi
    
    # Add to changelog in README
    sed -i.bak "/## Changelog/a\\
\\
${changelog_entry}\\
" $README_FILE
    
    rm -f $README_FILE.bak
    
    echo -e "${GREEN}✓ Changelog updated${NC}"
}

# Function to create git tag
create_git_tag() {
    local version=$1
    local message=$2
    
    local tag_message="Release v${version}"
    if [ ! -z "$message" ]; then
        tag_message="${tag_message}: ${message}"
    fi
    
    git add -A
    git commit -m "Version bump to ${version}

${message:-Version bump to ${version}}"
    
    git tag -a "v${version}" -m "$tag_message"
    
    echo -e "${GREEN}✓ Git commit and tag created${NC}"
}

# Main script
main() {
    # Check if we're in the plugin directory
    if [ ! -f "$PLUGIN_FILE" ]; then
        echo -e "${RED}Error: Must be run from the plugin root directory${NC}"
        exit 1
    fi
    
    # Check parameters
    if [ $# -lt 1 ]; then
        show_usage
    fi
    
    local version_type=$1
    local message=$2
    
    # Get current version
    local current_version=$(get_current_version)
    if [ -z "$current_version" ]; then
        echo -e "${RED}Error: Could not determine current version${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Current version: ${current_version}${NC}"
    
    # Calculate new version
    local new_version=$(increment_version $current_version $version_type)
    echo -e "${BLUE}New version: ${new_version}${NC}"
    
    # Confirm with user
    echo -e "${YELLOW}Do you want to proceed? (y/N)${NC}"
    read -r confirmation
    if [[ ! $confirmation =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
    
    # Update version in files
    update_version_in_files $current_version $new_version
    
    # Update changelog
    update_changelog $new_version "$message"
    
    # Create git commit and tag
    create_git_tag $new_version "$message"
    
    echo -e "${GREEN}✓ Version bump completed!${NC}"
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Review the changes: git show"
    echo "  2. Push changes: git push origin main"
    echo "  3. Push tags: git push origin --tags"
    echo "  4. Create release package: ./scripts/package.sh"
    echo "  5. Create GitHub release: gh release create v${new_version} --title \"v${new_version}\" --notes \"Release notes here\""
    echo "  6. Upload package: gh release upload v${new_version} releases/conditional-headers-blocks-v${new_version}.zip"
}

# Run main function
main "$@"