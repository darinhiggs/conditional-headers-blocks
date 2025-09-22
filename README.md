# Conditional Headers (Blocks)

**Show or hide any Gutenberg block based on conditions - just like Wicked Block Conditions!**

---

**Plugin Name:** Conditional Headers (Blocks)  
**Version:** 1.0.0  
**Author:** [Darin Higgs](https://higggs.com)  
**Agency:** [Higggs Agency](https://higggs.com)  
**License:** GPL v2 or later  

---

## Description

Conditional Headers (Blocks) extends **ALL** Gutenberg blocks with conditional display features. It works exactly like the popular Wicked Block Conditions plugin, adding a "Display Conditions" panel to every block in the WordPress editor.

Perfect for creating conditional headers, member-only content, page-specific styling, and much more!

## Key Features

✅ **Extends ALL blocks** - Works with any Gutenberg block (core, theme, or third-party)  
✅ **Familiar interface** - Identical experience to Wicked Block Conditions  
✅ **Visual condition editor** - Easy-to-use interface in the block inspector  
✅ **Multiple condition types** - User login status, post targeting, and more  
✅ **Show/Hide logic** - Flexible display control  
✅ **No coding required** - Visual configuration only  

## How It Works

1. **Edit any post/page** in the Gutenberg editor
2. **Select any block** (heading, HTML, paragraph, etc.)
3. **Open the "Display Conditions" panel** in the right sidebar
4. **Configure your conditions** with the visual interface
5. **Choose show or hide** when conditions are met
6. **Publish** - blocks appear/disappear based on your rules!

## Supported Conditions

### 👤 User Conditions
- **User Is Logged In** - Show content only to logged-in users
- **User Is Not Logged In** - Show content only to visitors

### 📄 Post Conditions
- **Check Post ID** - Target specific posts by ID number
- **Check Post Slug** - Target posts/pages by their URL slug

## Use Cases

### 🎯 **Conditional Headers**
Hide/show headers on specific pages:
```
Block: HTML (with header code)
Condition: "Hide this block" → "Check Post Slug" → "contact"
Result: Header hidden only on the contact page
```

### 🔐 **Member-Only Content**
Show content only to logged-in users:
```
Block: Any content block
Condition: "Show this block" → "User Is Logged In"
Result: Content visible only when user is logged in
```

### 📱 **Page-Specific Styling**
Add CSS only to specific posts:
```
Block: HTML (with CSS code)
Condition: "Show this block" → "Check Post ID" → "123"
Result: CSS loads only on post ID 123
```

## Installation

1. Upload the plugin zip file through **Plugins → Add New → Upload Plugin**
2. **Activate** the plugin
3. Edit any post/page and look for **"Display Conditions"** in the block inspector

## Usage

### Basic Setup

1. **Create/edit** a post or page
2. **Add any block** (HTML, Heading, Paragraph, etc.)
3. **Select the block** to see its settings
4. **Find "Display Conditions"** panel in the right sidebar
5. **Choose action**: "Show this block" or "Hide this block"
6. **Click "Add Condition"** to set rules
7. **Configure condition** using the form fields
8. **Save/Update** your post

### Example: Hide Block on Contact Page

1. Select your block
2. Display Conditions → "Hide this block"
3. Add Condition → "Check Post Slug"
4. Enter: "contact"
5. Save

The block will now be hidden when viewing the page with slug "contact".

## Technical Details

- **WordPress:** 5.0+ required
- **PHP:** 7.4+ required
- **Architecture:** Simple, bulletproof PHP - no complex dependencies
- **Performance:** Minimal overhead, only evaluates conditions on frontend
- **Compatibility:** Works with all themes and third-party blocks

## Support

For questions and support, please contact [Higggs Agency](mailto:technical@higggs.com).

## Development

### Requirements
- **WordPress:** 5.0+
- **PHP:** 7.4+
- **Node.js:** 16+ (for development only)
- **Git:** For version control

### Local Development Setup
1. Clone this repository: `git clone <repository-url>`
2. Install in your WordPress `wp-content/plugins/` directory
3. Activate the plugin in WordPress admin
4. Make changes and test locally before pushing

### File Structure
```
conditional-headers-blocks/
├── conditional-headers-blocks.php    # Main plugin file
├── classes/                         # PHP classes
│   └── class-conditional-headers-blocks.php
├── build/                          # Compiled JS/CSS assets
├── dist/                           # Distribution files
├── assets/                         # Source assets
├── README.md                       # Documentation
└── .gitignore                      # Git ignore rules
```

### Version Control
This plugin uses [Semantic Versioning](https://semver.org/):
- **MAJOR.MINOR.PATCH** (e.g., 1.2.3)
- **MAJOR:** Breaking changes
- **MINOR:** New features (backward compatible)
- **PATCH:** Bug fixes (backward compatible)

## Changelog

### 1.0.0 - Initial Release (2024-XX-XX)
- ✅ Complete block extension system
- ✅ Display Conditions panel for all blocks
- ✅ User login/logout conditions
- ✅ Post ID and slug targeting
- ✅ Professional, stable codebase
- ✅ Version control setup with Git
- ✅ Automated build and packaging system

---

**Developed by [Darin Higgs](https://higggs.com) at [Higggs Agency](https://higggs.com)**  
*Professional WordPress development and custom solutions*