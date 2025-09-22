# Development Workflow - Conditional Headers (Blocks)

This document outlines the development, testing, and deployment workflow for the Conditional Headers (Blocks) WordPress plugin.

## 🏗️ Development Environment Setup

### Prerequisites
- **WordPress:** 5.0+ (Local development environment)
- **PHP:** 7.4+ 
- **Git:** Latest version
- **macOS/Linux:** For shell scripts
- **Code Editor:** VS Code, PhpStorm, or similar

### Local Setup
1. **Clone the repository:**
   ```bash
   git clone <your-repo-url> conditional-headers-blocks
   cd conditional-headers-blocks
   ```

2. **Install in WordPress:**
   - Copy plugin folder to `wp-content/plugins/`
   - Activate the plugin in WordPress admin

3. **Development tools:**
   - Scripts are located in `/scripts/` directory
   - Make sure scripts are executable: `chmod +x scripts/*.sh`

## 📁 Project Structure

```
conditional-headers-blocks/
├── conditional-headers-blocks.php    # Main plugin file
├── classes/                         # PHP classes
│   └── class-conditional-headers-blocks.php
├── assets/                          # Source assets
│   └── css/
│       └── admin.css
├── build/                          # Built assets (committed)
│   ├── index.js
│   ├── index.css
│   └── style-index.css
├── dist/                           # Distribution files
│   └── index.js
├── scripts/                        # Development scripts
│   ├── version-bump.sh
│   └── package.sh
├── releases/                       # Generated zip files
├── README.md                       # User documentation
├── DEVELOPMENT.md                  # This file
└── .gitignore                      # Git ignore rules
```

## 🧪 Testing Workflow

### Local Testing
1. **Plugin Activation Test:**
   ```bash
   # Activate plugin and check for PHP errors
   tail -f /path/to/wordpress/wp-content/debug.log
   ```

2. **Block Editor Test:**
   - Create new post/page
   - Add any block (heading, paragraph, HTML, etc.)
   - Verify "Display Conditions" panel appears in block inspector
   - Test condition configuration interface

3. **Condition Logic Test:**
   - Test "User Is Logged In" condition (login/logout)
   - Test "Check Post ID" with specific post IDs
   - Test "Check Post Slug" with different page slugs
   - Verify show/hide logic works correctly

4. **Theme Compatibility:**
   - Test with different themes
   - Verify no styling conflicts
   - Check frontend display of conditional blocks

### Automated Testing (Optional)
Create simple test cases:
```bash
# Example: Basic activation test
wp plugin activate conditional-headers-blocks
wp plugin status conditional-headers-blocks
```

## 🔄 Version Management

### Semantic Versioning
- **1.0.0** → **1.0.1** (Patch: Bug fixes)
- **1.0.0** → **1.1.0** (Minor: New features)
- **1.0.0** → **2.0.0** (Major: Breaking changes)

### Version Bump Process

1. **Patch Release (Bug fixes):**
   ```bash
   ./scripts/version-bump.sh patch "Fix condition evaluation bug"
   ```

2. **Minor Release (New features):**
   ```bash
   ./scripts/version-bump.sh minor "Add post type condition support"
   ```

3. **Major Release (Breaking changes):**
   ```bash
   ./scripts/version-bump.sh major "Rewrite conditional system API"
   ```

### What the Script Does:
- Updates version numbers in all plugin files
- Updates README.md changelog
- Creates Git commit with proper message
- Creates Git tag for the release
- Shows next steps for deployment

## 📦 Build & Package Process

### Creating Release Package
```bash
./scripts/package.sh
```

This script:
- Creates clean copy of plugin files
- Removes development files (.git, scripts/, etc.)
- Creates distribution-ready zip file in `releases/` directory
- Verifies package integrity
- Shows package size and contents

### Manual Package Creation
If you need to create a package manually:
```bash
# Create releases directory
mkdir -p releases

# Create temporary build directory
mkdir -p /tmp/wp-plugin-build/conditional-headers-blocks

# Copy essential files
cp conditional-headers-blocks.php /tmp/wp-plugin-build/conditional-headers-blocks/
cp README.md /tmp/wp-plugin-build/conditional-headers-blocks/
cp -r classes/ /tmp/wp-plugin-build/conditional-headers-blocks/
cp -r assets/ /tmp/wp-plugin-build/conditional-headers-blocks/
cp -r build/ /tmp/wp-plugin-build/conditional-headers-blocks/
cp -r dist/ /tmp/wp-plugin-build/conditional-headers-blocks/

# Create zip
cd /tmp/wp-plugin-build
zip -r conditional-headers-blocks-v1.0.0.zip conditional-headers-blocks/

# Move to releases
mv conditional-headers-blocks-v1.0.0.zip /path/to/your/plugin/releases/
```

## 🚀 Deployment Workflow

### Pre-Deployment Checklist
- [ ] All changes tested locally
- [ ] Version bumped appropriately
- [ ] Changelog updated
- [ ] Git commits are clean and descriptive
- [ ] Release package created and tested

### Deployment Steps

1. **Push to Repository:**
   ```bash
   git push origin main
   git push origin --tags
   ```

2. **Create Release Package:**
   ```bash
   ./scripts/package.sh
   ```

3. **Test Package:**
   - Download the zip from `releases/` directory
   - Test installation on staging site
   - Verify all functionality works

4. **Deploy to Production:**
   - Upload zip via WordPress Admin → Plugins → Add New → Upload
   - Or extract directly to `wp-content/plugins/`
   - Activate and test

### Staging Environment
Always test on staging before production:
1. Upload new version to staging site
2. Test all conditional logic scenarios  
3. Check for conflicts with existing plugins/theme
4. Verify performance impact
5. Only deploy to production after staging approval

## 🔧 Common Development Tasks

### Adding New Condition Type
1. **Update PHP class:**
   - Add condition to `get_available_conditions()` method
   - Add evaluation logic to `evaluate_conditions()` method

2. **Update JavaScript:**
   - Add condition option to block editor interface
   - Update condition form fields as needed

3. **Test thoroughly:**
   - Test condition evaluation logic
   - Test editor interface
   - Update documentation if needed

### Debugging
1. **Enable WordPress debugging:**
   ```php
   define('WP_DEBUG', true);
   define('WP_DEBUG_LOG', true);
   ```

2. **Check logs:**
   ```bash
   tail -f wp-content/debug.log
   ```

3. **Browser console:**
   - Check for JavaScript errors in block editor
   - Verify AJAX requests work correctly

## 📋 Maintenance Tasks

### Regular Maintenance
- **Weekly:** Check for WordPress/PHP compatibility
- **Monthly:** Review and update dependencies
- **Quarterly:** Performance optimization review
- **Annually:** Code security audit

### Code Quality
- Follow [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/)
- Use consistent indentation and naming conventions
- Add inline comments for complex logic
- Keep functions small and focused

### Security Best Practices
- Always sanitize user inputs
- Use WordPress nonces for forms
- Escape all outputs
- Follow principle of least privilege
- Regular security updates

## 🆘 Troubleshooting

### Common Issues

1. **Plugin won't activate:**
   - Check PHP syntax errors: `php -l conditional-headers-blocks.php`
   - Verify WordPress version compatibility
   - Check for conflicting plugins

2. **Display Conditions panel not showing:**
   - Check JavaScript console for errors
   - Verify block editor assets are loading
   - Test with default WordPress theme

3. **Conditions not working:**
   - Check condition evaluation logic
   - Verify user permissions
   - Test with different user roles

4. **Version bump script issues:**
   - Ensure you're in plugin root directory
   - Check file permissions: `ls -la scripts/`
   - Verify Git is properly configured

### Getting Help
- Review WordPress debug logs
- Check browser console for JavaScript errors
- Test with minimal plugin configuration
- Contact: technical@higggs.com

## 📊 Performance Monitoring

### Key Metrics
- Plugin activation time
- Block editor performance impact
- Frontend condition evaluation speed
- Memory usage

### Optimization Tips
- Cache condition evaluations when possible
- Minimize JavaScript bundle size
- Use efficient database queries
- Profile with Query Monitor plugin

---

**Last Updated:** 2024-XX-XX  
**Version:** 1.0.0