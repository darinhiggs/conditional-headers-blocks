(function() {
    'use strict';
    
    // WordPress dependencies
    var registerBlockType = wp.blocks.registerBlockType;
    var __ = wp.i18n.__;
    var PanelBody = wp.components.PanelBody;
    var TextareaControl = wp.components.TextareaControl;
    var SelectControl = wp.components.SelectControl;
    var TextControl = wp.components.TextControl;
    var ToggleControl = wp.components.ToggleControl;
    var Button = wp.components.Button;
    var RadioControl = wp.components.RadioControl;
    var RangeControl = wp.components.RangeControl;
    var Card = wp.components.Card;
    var CardBody = wp.components.CardBody;
    var InspectorControls = wp.blockEditor.InspectorControls;
    var useBlockProps = wp.blockEditor.useBlockProps;
    var useEffect = wp.element.useEffect;
    var Fragment = wp.element.Fragment;
    var createElement = wp.element.createElement;

    // Register the block
    registerBlockType('conditional-headers-blocks/conditional-header', {
        title: __('Conditional Header', 'conditional-headers-blocks'),
        description: __('Add headers that display conditionally based on page criteria - just like Wicked Block Conditions!', 'conditional-headers-blocks'),
        category: 'conditional-headers',
        icon: 'admin-generic',
        keywords: [
            __('header', 'conditional-headers-blocks'),
            __('conditional', 'conditional-headers-blocks'),
            __('meta', 'conditional-headers-blocks'),
        ],
        attributes: {
            blockId: {
                type: 'string',
                default: '',
            },
            headerContent: {
                type: 'string',
                default: '',
            },
            conditions: {
                type: 'object',
                default: {
                    logic: 'and',
                    rules: [{ condition: '', operator: '', value: '' }]
                },
            },
            priority: {
                type: 'number',
                default: 10,
            },
            isActive: {
                type: 'boolean',
                default: true,
            },
        },

        edit: function(props) {
            var attributes = props.attributes;
            var setAttributes = props.setAttributes;
            var clientId = props.clientId;
            
            var blockId = attributes.blockId;
            var headerContent = attributes.headerContent;
            var conditions = attributes.conditions;
            var priority = attributes.priority;
            var isActive = attributes.isActive;

            var blockProps = useBlockProps();

            // Set block ID if not set
            useEffect(function() {
                if (!blockId) {
                    setAttributes({ blockId: clientId });
                }
            }, [clientId, blockId]);

            // Get condition types and operators from localized data
            var conditionTypes = (window.chbData && window.chbData.conditionTypes) ? window.chbData.conditionTypes : [];
            var operatorTypes = (window.chbData && window.chbData.operatorTypes) ? window.chbData.operatorTypes : {};

            // Helper functions
            function addConditionRule() {
                var newRules = conditions.rules.slice();
                newRules.push({ condition: '', operator: '', value: '' });
                setAttributes({ 
                    conditions: { 
                        logic: conditions.logic || 'and',
                        rules: newRules 
                    } 
                });
            }

            function removeConditionRule(index) {
                var newRules = conditions.rules.filter(function(rule, i) { return i !== index; });
                if (newRules.length === 0) {
                    newRules.push({ condition: '', operator: '', value: '' });
                }
                setAttributes({ 
                    conditions: { 
                        logic: conditions.logic || 'and',
                        rules: newRules 
                    } 
                });
            }

            function updateConditionRule(index, field, value) {
                var newRules = conditions.rules.map(function(rule, i) {
                    if (i === index) {
                        var updatedRule = Object.assign({}, rule);
                        updatedRule[field] = value;
                        if (field === 'condition') {
                            updatedRule.operator = '';
                            updatedRule.value = '';
                        }
                        return updatedRule;
                    }
                    return rule;
                });
                
                setAttributes({ 
                    conditions: { 
                        logic: conditions.logic || 'and',
                        rules: newRules 
                    } 
                });
            }

            function getOperatorOptions(conditionType) {
                if (!conditionType || !operatorTypes[conditionType]) {
                    return [{ label: __('Select operator...', 'conditional-headers-blocks'), value: '' }];
                }
                var options = [{ label: __('Select operator...', 'conditional-headers-blocks'), value: '' }];
                operatorTypes[conditionType].forEach(function(op) {
                    options.push({ label: op.label, value: op.value });
                });
                return options;
            }

            function needsValue(conditionType) {
                var type = conditionTypes.find(function(t) { return t.value === conditionType; });
                return type ? type.needsValue : false;
            }

            function getPlaceholder(conditionType) {
                var type = conditionTypes.find(function(t) { return t.value === conditionType; });
                return type ? type.placeholder : '';
            }

            function formatConditionsSummary() {
                if (!conditions.rules || conditions.rules.length === 0) {
                    return __('No conditions set', 'conditional-headers-blocks');
                }

                var parts = conditions.rules.map(function(rule) {
                    if (!rule.condition || !rule.operator) {
                        return '';
                    }
                    var type = conditionTypes.find(function(t) { return t.value === rule.condition; });
                    var typeName = type ? type.label : rule.condition;
                    
                    if (rule.value) {
                        return typeName + ' ' + rule.operator + ' "' + rule.value + '"';
                    } else {
                        return typeName + ' ' + rule.operator;
                    }
                }).filter(function(part) { return part.trim() !== ''; });

                if (parts.length === 0) {
                    return __('No valid conditions', 'conditional-headers-blocks');
                }

                var logic = conditions.logic === 'or' ? __('OR', 'conditional-headers-blocks') : __('AND', 'conditional-headers-blocks');
                return parts.join(' ' + logic + ' ');
            }

            // Build condition type options
            var conditionTypeOptions = [{ label: __('Select condition...', 'conditional-headers-blocks'), value: '' }];
            conditionTypes.forEach(function(type) {
                conditionTypeOptions.push({ label: type.label, value: type.value });
            });

            // Build condition rule elements
            var conditionElements = conditions.rules.map(function(rule, index) {
                var conditionControls = [
                    createElement(SelectControl, {
                        key: 'condition-' + index,
                        label: __('Condition', 'conditional-headers-blocks'),
                        value: rule.condition || '',
                        options: conditionTypeOptions,
                        onChange: function(value) { updateConditionRule(index, 'condition', value); }
                    })
                ];

                if (rule.condition) {
                    conditionControls.push(
                        createElement(SelectControl, {
                            key: 'operator-' + index,
                            label: __('Operator', 'conditional-headers-blocks'),
                            value: rule.operator || '',
                            options: getOperatorOptions(rule.condition),
                            onChange: function(value) { updateConditionRule(index, 'operator', value); }
                        })
                    );
                }

                if (rule.condition && needsValue(rule.condition)) {
                    conditionControls.push(
                        createElement(TextControl, {
                            key: 'value-' + index,
                            label: __('Value', 'conditional-headers-blocks'),
                            value: rule.value || '',
                            onChange: function(value) { updateConditionRule(index, 'value', value); },
                            placeholder: getPlaceholder(rule.condition)
                        })
                    );
                }

                conditionControls.push(
                    createElement(Button, {
                        key: 'remove-' + index,
                        isDestructive: true,
                        isSmall: true,
                        onClick: function() { removeConditionRule(index); },
                        disabled: conditions.rules.length === 1
                    }, __('Remove Condition', 'conditional-headers-blocks'))
                );

                return createElement(Card, { 
                    key: index, 
                    className: 'chb-condition-rule',
                    style: { marginBottom: '15px' }
                },
                    createElement(CardBody, {},
                        createElement('div', { className: 'chb-condition-controls' }, conditionControls)
                    )
                );
            });

            return createElement(Fragment, {},
                createElement(InspectorControls, {},
                    createElement(PanelBody, {
                        title: __('Header Settings', 'conditional-headers-blocks'),
                        initialOpen: true
                    },
                        createElement(ToggleControl, {
                            label: __('Active', 'conditional-headers-blocks'),
                            checked: isActive,
                            onChange: function(value) { setAttributes({ isActive: value }); },
                            help: __('Whether this header should be active', 'conditional-headers-blocks')
                        }),
                        
                        createElement(RangeControl, {
                            label: __('Priority', 'conditional-headers-blocks'),
                            value: priority,
                            onChange: function(value) { setAttributes({ priority: value }); },
                            min: 1,
                            max: 100,
                            help: __('Lower numbers have higher priority (1 = highest)', 'conditional-headers-blocks')
                        }),
                        
                        createElement(TextareaControl, {
                            label: __('Header Content', 'conditional-headers-blocks'),
                            value: headerContent,
                            onChange: function(value) { setAttributes({ headerContent: value }); },
                            placeholder: __('Enter HTML, CSS, JavaScript, or meta tags...', 'conditional-headers-blocks'),
                            help: __('Content to be inserted in the <head> section', 'conditional-headers-blocks'),
                            rows: 10
                        })
                    ),

                    createElement(PanelBody, {
                        title: __('Display Conditions', 'conditional-headers-blocks'),
                        initialOpen: true
                    },
                        createElement('p', {}, __('Configure when this header should be displayed:', 'conditional-headers-blocks')),
                        
                        createElement(RadioControl, {
                            label: __('Logic', 'conditional-headers-blocks'),
                            selected: conditions.logic || 'and',
                            options: [
                                { label: __('Match ALL conditions (AND)', 'conditional-headers-blocks'), value: 'and' },
                                { label: __('Match ANY condition (OR)', 'conditional-headers-blocks'), value: 'or' },
                            ],
                            onChange: function(value) { 
                                setAttributes({ 
                                    conditions: { 
                                        logic: value,
                                        rules: conditions.rules || []
                                    } 
                                }); 
                            }
                        }),

                        createElement('div', { className: 'chb-conditions-list' }, conditionElements),

                        createElement(Button, {
                            isPrimary: true,
                            onClick: addConditionRule
                        }, __('Add Condition', 'conditional-headers-blocks'))
                    )
                ),

                createElement('div', blockProps,
                    createElement('div', { className: 'chb-editor-preview' },
                        createElement('div', { className: 'chb-preview-header' },
                            createElement('h4', {}, __('Conditional Header Block', 'conditional-headers-blocks')),
                            createElement('span', { 
                                className: 'chb-status ' + (isActive ? 'active' : 'inactive')
                            }, isActive ? __('Active', 'conditional-headers-blocks') : __('Inactive', 'conditional-headers-blocks'))
                        ),

                        createElement('div', { className: 'chb-preview-info' },
                            createElement('div', { className: 'chb-info-item' },
                                createElement('strong', {}, __('Priority:', 'conditional-headers-blocks') + ' '),
                                priority.toString()
                            ),
                            
                            createElement('div', { className: 'chb-info-item' },
                                createElement('strong', {}, __('Conditions:', 'conditional-headers-blocks')),
                                createElement('br', {}),
                                createElement('em', {}, formatConditionsSummary())
                            ),
                            
                            createElement('div', { className: 'chb-info-item' },
                                createElement('strong', {}, __('Content:', 'conditional-headers-blocks')),
                                createElement('br', {}),
                                headerContent ? (
                                    createElement('code', {}, 
                                        headerContent.substring(0, 100) + (headerContent.length > 100 ? '...' : '')
                                    )
                                ) : (
                                    createElement('em', {}, __('No content set', 'conditional-headers-blocks'))
                                )
                            )
                        ),

                        createElement('div', { className: 'chb-preview-note' },
                            createElement('p', {},
                                createElement('strong', {}, __('Note:', 'conditional-headers-blocks') + ' '),
                                __('This block will add content to your page\'s <head> section when conditions are met. Use the sidebar to configure settings.', 'conditional-headers-blocks')
                            )
                        )
                    )
                )
            );
        },

        save: function() {
            // Return null - rendering is handled by PHP
            return null;
        },
    });
})();