# Quick Reference - Conditional Headers (Blocks)

## 🚀 Common Commands

### Version Management
```bash
# Patch release (bug fixes)
./scripts/version-bump.sh patch "Fix specific bug description"

# Minor release (new features)  
./scripts/version-bump.sh minor "Add new condition types"

# Major release (breaking changes)
./scripts/version-bump.sh major "Rewrite core functionality"
```

### Package Creation
```bash
# Create distribution package
./scripts/package.sh

# Check package location
ls -la releases/
```

### Compatibility Monitoring
```bash
# Check WordPress compatibility
./scripts/compatibility-check.sh

# Monitor for deprecations
./scripts/deprecation-monitor.sh

# Check latest WordPress version
curl -s "https://api.wordpress.org/core/version-check/1.7/" | grep -o '"current":"[^"]*"' | head -1
```

### Git Operations
```bash
# Check status
git status

# Commit changes
git add .
git commit -m "Your commit message"

# Push to repository
git push origin main
git push origin --tags

# View recent commits
git --no-pager log --oneline -10
```

## 📋 Pre-Release Checklist

- [ ] Test locally on development site
- [ ] Test with different WordPress themes
- [ ] Test all condition types (login, post ID, post slug)
- [ ] Check for PHP/JavaScript errors
- [ ] Version bump completed
- [ ] Changelog updated
- [ ] Package created and tested
- [ ] Git commits pushed
- [ ] Tags pushed

## 🔧 Troubleshooting

### Scripts Won't Run
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Check if in correct directory
pwd
# Should be: /path/to/conditional-headers-blocks-source
```

### Plugin Issues
```bash
# Check PHP syntax
php -l conditional-headers-blocks.php

# Enable WordPress debug
# Add to wp-config.php:
# define('WP_DEBUG', true);
# define('WP_DEBUG_LOG', true);

# Check debug log
tail -f /path/to/wordpress/wp-content/debug.log
```

## 📁 Important Locations

- **Main plugin file:** `conditional-headers-blocks.php`
- **Core logic:** `classes/class-conditional-headers-blocks.php`  
- **Built assets:** `build/` directory
- **Release packages:** `releases/` directory
- **Development scripts:** `scripts/` directory

## 🔄 Update Workflow

1. **Make changes** to plugin files
2. **Test locally** in WordPress environment
3. **Version bump:** `./scripts/version-bump.sh [patch|minor|major] "Description"`
4. **Create package:** `./scripts/package.sh`
5. **Test package** on staging site
6. **Deploy** to production sites

## 📞 Support

- **Documentation:** See `DEVELOPMENT.md` for detailed workflow
- **Issues:** Check WordPress debug log and browser console
- **Contact:** technical@higggs.com

---
**Plugin Version:** 1.0.0  
**Last Updated:** September 2024