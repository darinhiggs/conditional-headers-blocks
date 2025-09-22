<?php

// Disable direct load
if ( ! defined( 'ABSPATH' ) ) {
	die( 'Access denied.' );
}

/**
 * Simplified main plugin class without complex condition system.
 */
final class Conditional_Headers_Blocks {

    /**
	 * Holds an instance of the class.
	 *
     * @var Conditional_Headers_Blocks
     */
    private static $instance;

    private function __construct() {
        add_action( 'init', 				array( $this, 'init' ) );
		add_action( 'enqueue_block_editor_assets', 	array( $this, 'enqueue_block_editor_assets' ), -10 );

		add_filter( 'pre_render_block', 		array( $this, 'pre_render_block' ), 10, 2 );
		add_filter( 'render_block', 			array( $this, 'render_block' ), 10, 2 );
		add_filter( 'register_block_type_args', 	array( $this, 'register_block_type_args' ), 10, 2 );
    }

    /**
	 * Plugin activation hook.
	 */
	public static function activate() {
		// Simple activation
    }

    /**
	 * Returns the singleton instance of the plugin.
     *
     * @return Conditional_Headers_Blocks
	 */
    public static function get_instance() {
		if ( empty( self::$instance ) ) {
			self::$instance = new Conditional_Headers_Blocks();
		}

		return self::$instance;
	}

    public function init() {
        // Simple initialization
    }

	/**
	 * enqueue_block_editor_assets hook.
	 */
	public function enqueue_block_editor_assets() {
		$script = plugin_dir_url( dirname( __FILE__ ) ) . 'dist/index.js';
		$deps = array( 'wp-blocks', 'wp-element', 'wp-data', 'wp-components', 'wp-i18n', 'lodash', 'wp-block-editor' );

		wp_enqueue_script( 'conditional-headers-blocks', $script, $deps, $this->plugin_version() );
		wp_enqueue_style( 'conditional-headers-blocks', plugin_dir_url( dirname( __FILE__ ) ) . 'assets/css/admin.css', array(), $this->plugin_version() );
	}

	/**
	 * Returns the plugin's version.
	 */
	public function plugin_version() {
		return '1.0.0';
	}

	/**
	 * Simple render_block filter.
	 */
	public function render_block( $block_content, $block ) {
		// Don't execute this in the admin
		if ( is_admin() ) {
			return $block_content;
		}

		// Simple condition check
		if ( $this->should_hide_block( $block ) ) {
			return '';
		}

		return $block_content;
	}

	/**
	 * Simple pre_render_block filter.
	 */
	public function pre_render_block( $pre_render, $block ) {
		// Don't execute this in the admin
		if ( is_admin() ) {
			return $pre_render;
		}

		// Simple condition check
		if ( $this->should_hide_block( $block ) ) {
			return false;
		}

		return $pre_render;
	}

	/**
	 * Simple condition evaluation.
	 */
	private function should_hide_block( $block ) {
		// Check if block has conditions
		if ( empty( $block['attrs']['conditionalHeadersBlocksConditions'] ) ) {
			return false;
		}

		$conditions = $block['attrs']['conditionalHeadersBlocksConditions'];
		$action = isset( $conditions['action'] ) ? $conditions['action'] : 'show';
		$condition_list = isset( $conditions['conditions'] ) ? $conditions['conditions'] : array();

		if ( empty( $condition_list ) ) {
			return false;
		}

		// Simple evaluation
		$result = true;
		foreach ( $condition_list as $condition ) {
			if ( ! isset( $condition['type'] ) ) {
				continue;
			}

			$condition_result = $this->evaluate_simple_condition( $condition );
			
			// Simple AND logic for now
			$result = $result && $condition_result;
		}

		// Apply action
		if ( 'hide' === $action && $result ) {
			return true;
		}

		if ( 'show' === $action && ! $result ) {
			return true;
		}

		return false;
	}

	/**
	 * Evaluate a single condition simply.
	 */
	private function evaluate_simple_condition( $condition ) {
		$type = $condition['type'];

		switch ( $type ) {
			case 'user_is_logged_in':
				return is_user_logged_in();

			case 'user_is_not_logged_in':
				return ! is_user_logged_in();

			case 'post_id':
				if ( isset( $condition['postId'] ) ) {
					global $post;
					return $post && $post->ID == $condition['postId'];
				}
				return false;

			case 'post_slug':
				if ( isset( $condition['slug'] ) ) {
					global $post;
					return $post && $post->post_name === $condition['slug'];
				}
				return false;

			default:
				return true;
		}
	}

	/**
	 * WordPress register_block_type_args filter.
	 */
	public function register_block_type_args( $args, $name ) {
		$args['attributes']['conditionalHeadersBlocksConditions'] = array(
			'type' => 'object'
		);

		return $args;
	}
}