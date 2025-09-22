<?php
/**
 * Plugin Name: Conditional Headers (Blocks)
 * Plugin URI: https://higggs.com
 * Description: Show or hide any Gutenberg block based on conditions. Works exactly like Wicked Block Conditions - extends all blocks with conditional display features.
 * Version: 1.0.0
 * Author: Darin Higgs
 * Author URI: https://higggs.com
 * Text Domain: conditional-headers-blocks
 * Domain Path: /languages
 * License: GPL v2 or later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Requires at least: 5.0
 * Tested up to: 6.8
 * Requires PHP: 7.4
 * Network: false
 * 
 * @package ConditionalHeadersBlocks
 * @author Darin Higgs <darin@higggs.com>
 * @copyright 2024 Higggs Agency
 * @license GPL-2.0-or-later
 */

// Disable direct load
if ( ! defined( 'ABSPATH' ) ) {
	die( 'Access denied.' );
}

// Prevent multiple loads
if ( class_exists( 'Conditional_Headers_Blocks' ) ) {
	return;
}

// Load simple main class
require_once plugin_dir_path( __FILE__ ) . 'classes/class-conditional-headers-blocks.php';

// Register activation hook
register_activation_hook( __FILE__, array( 'Conditional_Headers_Blocks', 'activate' ) );

// Initialize the plugin
Conditional_Headers_Blocks::get_instance();
