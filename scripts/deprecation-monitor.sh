#!/bin/bash

# WordPress Deprecation Monitoring Script
# Monitors WordPress APIs and functions used by Conditional Headers (Blocks)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# WordPress functions used by our plugin
PLUGIN_FUNCTIONS=(
    "wp_enqueue_script"
    "wp_enqueue_style"
    "register_block_type"
    "wp_localize_script"
    "add_action"
    "add_filter"
    "get_current_user_id"
    "is_user_logged_in"
    "get_post"
    "get_post_field"
    "wp_die"
    "plugin_dir_path"
    "plugin_dir_url"
    "wp_create_nonce"
    "wp_verify_nonce"
    "sanitize_text_field"
    "esc_html"
    "esc_attr"
)

# WordPress hooks used by our plugin
PLUGIN_HOOKS=(
    "wp_head"
    "init"
    "enqueue_block_editor_assets"
    "wp_enqueue_scripts"
    "wp_footer"
    "plugins_loaded"
)

# Function to check WordPress deprecation database
check_wordpress_deprecations() {
    echo -e "${YELLOW}Checking WordPress deprecation database...${NC}"
    
    # Create deprecation report
    DEPRECATION_FILE="deprecation-check-$(date +%Y%m%d).txt"
    
    {
        echo "WordPress Deprecation Check Report"
        echo "Plugin: Conditional Headers (Blocks)"
        echo "Date: $(date)"
        echo "======================================"
        echo ""
        echo "Functions Used by Plugin:"
        for func in "${PLUGIN_FUNCTIONS[@]}"; do
            echo "- $func"
        done
        echo ""
        echo "Hooks Used by Plugin:"
        for hook in "${PLUGIN_HOOKS[@]}"; do
            echo "- $hook"
        done
        echo ""
        echo "Manual Checks Needed:"
        echo "1. Visit https://core.trac.wordpress.org/browser/trunk/src/wp-includes/deprecated.php"
        echo "2. Check WordPress Developer Handbook for API changes"
        echo "3. Review WordPress release notes for breaking changes"
        echo "4. Monitor WordPress Slack #core-editor channel"
        echo ""
        echo "Automated Checks:"
        echo "- PHP syntax: $(php -l conditional-headers-blocks.php > /dev/null 2>&1 && echo "PASSED" || echo "FAILED")"
        echo "- File integrity: $([ -f "conditional-headers-blocks.php" ] && echo "OK" || echo "MISSING")"
    } > "$DEPRECATION_FILE"
    
    echo -e "${GREEN}✓ Deprecation report saved to: $DEPRECATION_FILE${NC}"
    echo ""
}

# Function to scan code for potential issues
scan_code_issues() {
    echo -e "${YELLOW}Scanning code for potential compatibility issues...${NC}"
    
    # Check for direct database calls
    if grep -r "wpdb->" --include="*.php" . > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Direct database calls found - review for compatibility${NC}"
    else
        echo -e "${GREEN}✓ No direct database calls found${NC}"
    fi
    
    # Check for deprecated jQuery usage
    if grep -r "jQuery.*live" --include="*.js" . > /dev/null 2>&1; then
        echo -e "${RED}✗ Found deprecated jQuery .live() usage${NC}"
    else
        echo -e "${GREEN}✓ No deprecated jQuery functions found${NC}"
    fi
    
    # Check for PHP short tags
    if grep -r "<?=" --include="*.php" . > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  PHP short tags found - may cause compatibility issues${NC}"
    else
        echo -e "${GREEN}✓ No PHP short tags found${NC}"
    fi
    
    # Check for old PHP array syntax
    if grep -r "array(" --include="*.php" . > /dev/null 2>&1; then
        echo -e "${BLUE}ℹ️  Old PHP array syntax found - consider upgrading to []${NC}"
    fi
    
    echo ""
}

# Function to check for WordPress coding standards compliance
check_coding_standards() {
    echo -e "${YELLOW}Checking WordPress coding standards compliance...${NC}"
    
    # Check for proper escaping
    if grep -r "echo.*\$" --include="*.php" . > /dev/null 2>&1; then
        UNESCAPED=$(grep -r "echo.*\$" --include="*.php" . | wc -l)
        echo -e "${YELLOW}⚠️  Found $UNESCAPED potentially unescaped echo statements${NC}"
    else
        echo -e "${GREEN}✓ No obvious unescaped output found${NC}"
    fi
    
    # Check for proper sanitization
    if grep -r "\$_GET\|\$_POST\|\$_REQUEST" --include="*.php" . > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Direct superglobal usage found - ensure proper sanitization${NC}"
    else
        echo -e "${GREEN}✓ No direct superglobal usage found${NC}"
    fi
    
    # Check for nonce verification in admin actions
    if grep -r "admin_post\|wp_ajax" --include="*.php" . > /dev/null 2>&1; then
        if grep -r "wp_verify_nonce" --include="*.php" . > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Nonce verification found${NC}"
        else
            echo -e "${YELLOW}⚠️  AJAX/admin actions without nonce verification${NC}"
        fi
    else
        echo -e "${BLUE}ℹ️  No AJAX/admin actions found${NC}"
    fi
    
    echo ""
}

# Function to generate monitoring checklist
generate_monitoring_checklist() {
    echo -e "${BLUE}Generating monitoring checklist...${NC}"
    
    CHECKLIST_FILE="monitoring-checklist.md"
    
    cat > "$CHECKLIST_FILE" << 'EOF'
# WordPress Deprecation Monitoring Checklist

## Monthly Tasks (First Monday of Month)

### WordPress Version Check
- [ ] Check latest WordPress version
- [ ] Compare with plugin compatibility
- [ ] Download and test beta/RC if available
- [ ] Update "Tested up to" header if compatible

### Code Review
- [ ] Run `./scripts/deprecation-monitor.sh`
- [ ] Review deprecation report
- [ ] Check WordPress Trac for deprecated functions
- [ ] Review WordPress release notes

### Automated Checks
- [ ] Run `./scripts/compatibility-check.sh`
- [ ] Check PHP syntax with `php -l`
- [ ] Enable WP_DEBUG and check debug.log
- [ ] Run WordPress coding standards checker (if available)

### Community Monitoring
- [ ] Check WordPress Core blog for updates
- [ ] Review #core-editor Slack channel
- [ ] Check WordPress Developer Handbook changes
- [ ] Monitor Gutenberg plugin updates

## Quarterly Tasks

### Deep Compatibility Testing
- [ ] Test with multiple WordPress versions
- [ ] Test with different PHP versions
- [ ] Test with popular themes
- [ ] Test with popular plugins
- [ ] Performance benchmarking

### Code Modernization
- [ ] Update deprecated functions if found
- [ ] Improve coding standards compliance
- [ ] Update JavaScript dependencies
- [ ] Review security best practices

### Documentation Updates
- [ ] Update COMPATIBILITY.md
- [ ] Update plugin headers
- [ ] Review and update README.md
- [ ] Update version compatibility matrix

## Resources

- WordPress Core Blog: https://make.wordpress.org/core/
- WordPress Trac: https://core.trac.wordpress.org/
- WordPress Developer Handbook: https://developer.wordpress.org/
- Gutenberg GitHub: https://github.com/WordPress/gutenberg
- WordPress Slack: https://make.wordpress.org/chat/

## Emergency Response

If a WordPress update breaks the plugin:

1. **Immediate Response**
   - [ ] Assess impact and affected features
   - [ ] Implement quick workaround if possible
   - [ ] Communicate issue to users

2. **Fix Development**
   - [ ] Analyze root cause
   - [ ] Develop proper fix
   - [ ] Test thoroughly
   - [ ] Update tests to prevent regression

3. **Release & Communication**
   - [ ] Deploy fix as patch release
   - [ ] Update documentation
   - [ ] Notify users of resolution
   - [ ] Post-mortem analysis

EOF

    echo -e "${GREEN}✓ Monitoring checklist saved to: $CHECKLIST_FILE${NC}"
    echo ""
}

# Function to check WordPress release schedule
check_release_schedule() {
    echo -e "${YELLOW}Checking WordPress release information...${NC}"
    
    # Get WordPress version info
    WP_INFO=$(curl -s "https://api.wordpress.org/core/version-check/1.7/" 2>/dev/null)
    
    if [ ! -z "$WP_INFO" ]; then
        CURRENT_VERSION=$(echo "$WP_INFO" | grep -o '"current":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo -e "${GREEN}✓ Current WordPress version: $CURRENT_VERSION${NC}"
        
        # Calculate approximate next release (every ~4 months for major releases)
        MAJOR_VERSION=$(echo "$CURRENT_VERSION" | cut -d'.' -f1-2)
        echo -e "${BLUE}ℹ️  Current major version: $MAJOR_VERSION${NC}"
        echo -e "${BLUE}ℹ️  Next major release expected: ~4 months from last major${NC}"
    else
        echo -e "${RED}✗ Unable to fetch WordPress version information${NC}"
    fi
    
    echo ""
}

# Function to create deprecation watch list
create_watch_list() {
    echo -e "${YELLOW}Creating deprecation watch list...${NC}"
    
    WATCH_FILE="deprecation-watchlist.json"
    
    cat > "$WATCH_FILE" << EOF
{
  "plugin": "conditional-headers-blocks",
  "last_checked": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "wordpress_functions": [
$(printf '    "%s"' "${PLUGIN_FUNCTIONS[0]}")
$(printf ',\n    "%s"' "${PLUGIN_FUNCTIONS[@]:1}")
  ],
  "wordpress_hooks": [
$(printf '    "%s"' "${PLUGIN_HOOKS[0]}")
$(printf ',\n    "%s"' "${PLUGIN_HOOKS[@]:1}")
  ],
  "monitoring_urls": [
    "https://core.trac.wordpress.org/browser/trunk/src/wp-includes/deprecated.php",
    "https://make.wordpress.org/core/",
    "https://developer.wordpress.org/reference/",
    "https://github.com/WordPress/gutenberg/releases"
  ],
  "alerts": {
    "check_frequency": "monthly",
    "next_check": "$(date -d "+1 month" -u +"%Y-%m-%dT%H:%M:%SZ")"
  }
}
EOF

    echo -e "${GREEN}✓ Watch list saved to: $WATCH_FILE${NC}"
    echo ""
}

# Main function
main() {
    echo -e "${BLUE}================================="
    echo -e "WordPress Deprecation Monitor"
    echo -e "Plugin: Conditional Headers (Blocks)"
    echo -e "=================================${NC}"
    echo ""
    
    check_wordpress_deprecations
    scan_code_issues
    check_coding_standards
    check_release_schedule
    generate_monitoring_checklist
    create_watch_list
    
    echo -e "${GREEN}Deprecation monitoring completed!${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Review generated reports and checklists"
    echo "2. Set up monthly monitoring schedule"
    echo "3. Subscribe to WordPress development updates"
    echo "4. Test plugin with latest WordPress version"
    echo ""
}

# Check if running from correct directory
if [ ! -f "conditional-headers-blocks.php" ]; then
    echo -e "${RED}Error: Must be run from plugin root directory${NC}"
    exit 1
fi

# Make scripts executable
chmod +x scripts/*.sh

# Run main function
main "$@"