#!/bin/bash

# WordPress Compatibility Testing Script for Conditional Headers (Blocks)
# Usage: ./scripts/compatibility-check.sh [wordpress-version]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PLUGIN_NAME="Conditional Headers (Blocks)"
PLUGIN_SLUG="conditional-headers-blocks"
CURRENT_WP_VERSION="6.8"

# Function to display header
show_header() {
    echo -e "${BLUE}================================="
    echo -e "WordPress Compatibility Check"
    echo -e "Plugin: $PLUGIN_NAME"
    echo -e "=================================${NC}"
    echo ""
}

# Function to check WordPress version
check_wordpress_version() {
    echo -e "${YELLOW}Checking WordPress version...${NC}"
    
    # Get current WordPress version from API
    LATEST_WP=$(curl -s "https://api.wordpress.org/core/version-check/1.7/" | grep -o '"current":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ ! -z "$LATEST_WP" ]; then
        echo -e "${GREEN}✓ Latest WordPress version: $LATEST_WP${NC}"
        
        # Compare with plugin compatibility
        if [ "$LATEST_WP" \> "$CURRENT_WP_VERSION" ]; then
            echo -e "${YELLOW}⚠️  Plugin may need testing with WordPress $LATEST_WP${NC}"
        else
            echo -e "${GREEN}✓ Plugin is compatible with latest WordPress${NC}"
        fi
    else
        echo -e "${RED}✗ Unable to fetch WordPress version${NC}"
    fi
    echo ""
}

# Function to check PHP compatibility
check_php_compatibility() {
    echo -e "${YELLOW}Checking PHP compatibility...${NC}"
    
    PHP_VERSION=$(php -v | head -1 | cut -d' ' -f2)
    echo -e "${GREEN}✓ Current PHP version: $PHP_VERSION${NC}"
    
    # Check if PHP version meets requirements
    if php -r "exit(version_compare(PHP_VERSION, '7.4.0', '<') ? 1 : 0);"; then
        echo -e "${RED}✗ PHP version too old. Requires PHP 7.4+${NC}"
    else
        echo -e "${GREEN}✓ PHP version meets requirements${NC}"
    fi
    echo ""
}

# Function to check plugin files
check_plugin_files() {
    echo -e "${YELLOW}Checking plugin files...${NC}"
    
    # Check main plugin file
    if [ -f "conditional-headers-blocks.php" ]; then
        echo -e "${GREEN}✓ Main plugin file exists${NC}"
    else
        echo -e "${RED}✗ Main plugin file missing${NC}"
        return 1
    fi
    
    # Check class file
    if [ -f "classes/class-conditional-headers-blocks.php" ]; then
        echo -e "${GREEN}✓ Main class file exists${NC}"
    else
        echo -e "${RED}✗ Main class file missing${NC}"
        return 1
    fi
    
    # Check JavaScript files
    if [ -d "build" ] && [ -f "build/index.js" ]; then
        echo -e "${GREEN}✓ JavaScript files exist${NC}"
    else
        echo -e "${YELLOW}⚠️  JavaScript build files missing${NC}"
    fi
    
    # Check CSS files
    if [ -d "assets" ] && [ -f "assets/css/admin.css" ]; then
        echo -e "${GREEN}✓ CSS files exist${NC}"
    else
        echo -e "${YELLOW}⚠️  CSS files missing${NC}"
    fi
    
    echo ""
}

# Function to run PHP syntax checks
check_php_syntax() {
    echo -e "${YELLOW}Checking PHP syntax...${NC}"
    
    # Check main plugin file
    if php -l conditional-headers-blocks.php > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Main plugin file syntax OK${NC}"
    else
        echo -e "${RED}✗ Main plugin file has syntax errors${NC}"
        php -l conditional-headers-blocks.php
        return 1
    fi
    
    # Check class files
    for file in classes/*.php; do
        if [ -f "$file" ]; then
            if php -l "$file" > /dev/null 2>&1; then
                echo -e "${GREEN}✓ $(basename "$file") syntax OK${NC}"
            else
                echo -e "${RED}✗ $(basename "$file") has syntax errors${NC}"
                php -l "$file"
                return 1
            fi
        fi
    done
    
    echo ""
}

# Function to check WordPress function usage
check_wordpress_functions() {
    echo -e "${YELLOW}Checking WordPress function usage...${NC}"
    
    # List of functions that might be deprecated
    DEPRECATED_FUNCTIONS=(
        "mysql_query"
        "wp_print_scripts"
        "wp_print_styles"
        "get_theme_data"
        "wp_get_http"
    )
    
    FOUND_DEPRECATED=false
    
    for func in "${DEPRECATED_FUNCTIONS[@]}"; do
        if grep -r "$func" --include="*.php" . > /dev/null 2>&1; then
            echo -e "${RED}✗ Found deprecated function: $func${NC}"
            FOUND_DEPRECATED=true
        fi
    done
    
    if [ "$FOUND_DEPRECATED" = false ]; then
        echo -e "${GREEN}✓ No known deprecated functions found${NC}"
    fi
    
    echo ""
}

# Function to check security best practices
check_security() {
    echo -e "${YELLOW}Checking security best practices...${NC}"
    
    # Check for direct access prevention
    if grep -r "ABSPATH" --include="*.php" . > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Direct access prevention found${NC}"
    else
        echo -e "${YELLOW}⚠️  Consider adding direct access prevention${NC}"
    fi
    
    # Check for nonce usage (if forms exist)
    if grep -r "wp_nonce" --include="*.php" . > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Nonce usage found${NC}"
    else
        echo -e "${BLUE}ℹ️  No nonce usage found (may not be needed)${NC}"
    fi
    
    # Check for sanitization
    if grep -r "sanitize_" --include="*.php" . > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Sanitization functions found${NC}"
    else
        echo -e "${YELLOW}⚠️  Consider using sanitization functions${NC}"
    fi
    
    echo ""
}

# Function to generate compatibility report
generate_report() {
    echo -e "${BLUE}Generating compatibility report...${NC}"
    
    REPORT_FILE="compatibility-report-$(date +%Y%m%d).txt"
    
    {
        echo "WordPress Compatibility Report"
        echo "Plugin: $PLUGIN_NAME"
        echo "Date: $(date)"
        echo "================================="
        echo ""
        echo "WordPress Version Check:"
        echo "Latest WP: $LATEST_WP"
        echo "Plugin supports: 5.0 - $CURRENT_WP_VERSION+"
        echo ""
        echo "PHP Version:"
        echo "Current: $PHP_VERSION"
        echo "Required: 7.4+"
        echo ""
        echo "File Integrity: $([ -f "conditional-headers-blocks.php" ] && echo "OK" || echo "FAILED")"
        echo "Syntax Check: $(php -l conditional-headers-blocks.php > /dev/null 2>&1 && echo "OK" || echo "FAILED")"
        echo ""
        echo "Recommendations:"
        echo "- Test with WordPress $LATEST_WP if not already done"
        echo "- Review COMPATIBILITY.md for testing procedures"
        echo "- Check for deprecation warnings in debug.log"
        echo "- Update 'Tested up to' header if tests pass"
    } > "$REPORT_FILE"
    
    echo -e "${GREEN}✓ Report saved to: $REPORT_FILE${NC}"
    echo ""
}

# Function to show testing recommendations
show_recommendations() {
    echo -e "${BLUE}Testing Recommendations:${NC}"
    echo ""
    echo "1. 🧪 Set up test environment with latest WordPress"
    echo "2. 📝 Run through the testing checklist in COMPATIBILITY.md"
    echo "3. 🔍 Enable WP_DEBUG and check for warnings"
    echo "4. 🎯 Test with popular themes (Twenty Twenty-Four, Astra)"
    echo "5. 🔗 Test with popular plugins (Yoast SEO, WooCommerce)"
    echo "6. 📊 Check performance impact"
    echo "7. 🔄 Test all condition types (login, post ID, slug)"
    echo "8. 📱 Test with different block types"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "- If tests pass: Update 'Tested up to' header"
    echo "- If issues found: Create GitHub issue and fix"
    echo "- Update compatibility matrix in COMPATIBILITY.md"
    echo ""
}

# Function to check for WordPress updates
check_for_updates() {
    echo -e "${YELLOW}Checking for WordPress beta/RC versions...${NC}"
    
    # Check for beta versions
    BETA_INFO=$(curl -s "https://wordpress.org/download/beta/" 2>/dev/null | grep -o "WordPress [0-9.]*-[A-Z]*[0-9]*" | head -1)
    
    if [ ! -z "$BETA_INFO" ]; then
        echo -e "${BLUE}ℹ️  Beta/RC available: $BETA_INFO${NC}"
        echo -e "${YELLOW}Consider testing with beta version before release${NC}"
    else
        echo -e "${GREEN}✓ No beta versions found${NC}"
    fi
    
    echo ""
}

# Main execution
main() {
    show_header
    check_wordpress_version
    check_php_compatibility  
    check_plugin_files
    check_php_syntax
    check_wordpress_functions
    check_security
    check_for_updates
    generate_report
    show_recommendations
    
    echo -e "${GREEN}Compatibility check completed!${NC}"
}

# Check if running from correct directory
if [ ! -f "conditional-headers-blocks.php" ]; then
    echo -e "${RED}Error: Must be run from plugin root directory${NC}"
    exit 1
fi

# Run main function
main "$@"