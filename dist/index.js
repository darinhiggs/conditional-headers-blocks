(function() {
    'use strict';

    const { __ } = wp.i18n;
    const { Fragment, useState } = wp.element;
    const { 
        PanelBody, 
        Button, 
        RadioControl, 
        TextControl, 
        ToggleControl 
    } = wp.components;
    const { InspectorControls } = wp.blockEditor;
    const { createHigherOrderComponent } = wp.compose;
    const { addFilter } = wp.hooks;
    const { assign } = lodash;

    // Generate a UUID for conditions
    function generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    // Complete condition types (matching Wicked Block Conditions)
    const conditionTypes = [
        // User Conditions
        {
            type: 'user_is_logged_in',
            label: __('User Is Logged In', 'conditional-headers-blocks'),
            group: __('User Conditions', 'conditional-headers-blocks'),
            description: __('Returns true if a user is logged in.', 'conditional-headers-blocks'),
            bypassConfig: true
        },
        {
            type: 'user_is_not_logged_in',
            label: __('User Is Not Logged In', 'conditional-headers-blocks'),
            group: __('User Conditions', 'conditional-headers-blocks'),
            description: __('Returns true if a user is not logged in.', 'conditional-headers-blocks'),
            bypassConfig: true
        },
        {
            type: 'user_has_role',
            label: __('User Has Role', 'conditional-headers-blocks'),
            group: __('User Conditions', 'conditional-headers-blocks'),
            description: __('Returns true if the user is assigned to any of the selected roles.', 'conditional-headers-blocks'),
            bypassConfig: false
        },
        // Post Conditions
        {
            type: 'post_id',
            label: __('Check Post ID', 'conditional-headers-blocks'),
            group: __('Post Conditions', 'conditional-headers-blocks'),
            description: __('Returns true if the post has the specified ID.', 'conditional-headers-blocks'),
            bypassConfig: false
        },
        {
            type: 'post_slug',
            label: __('Check Post Slug', 'conditional-headers-blocks'),
            group: __('Post Conditions', 'conditional-headers-blocks'),
            description: __('Returns true if the post has the specified slug.', 'conditional-headers-blocks'),
            bypassConfig: false
        },
        {
            type: 'post_has_term',
            label: __('Post Has a Term', 'conditional-headers-blocks'),
            group: __('Post Conditions', 'conditional-headers-blocks'),
            description: __('Returns true if the post has the selected term(s) assigned.', 'conditional-headers-blocks'),
            bypassConfig: false
        },
        {
            type: 'post_status',
            label: __('Check Post Status', 'conditional-headers-blocks'),
            group: __('Post Conditions', 'conditional-headers-blocks'),
            description: __('Returns true if post status matches the selected option.', 'conditional-headers-blocks'),
            bypassConfig: false
        },
        // Date Conditions
        {
            type: 'current_date',
            label: __('Check The Date', 'conditional-headers-blocks'),
            group: __('Date Conditions', 'conditional-headers-blocks'),
            description: __('Returns true if the current date matches the specified conditions.', 'conditional-headers-blocks'),
            bypassConfig: false
        },
        // Advanced
        {
            type: 'user_function',
            label: __('Check a User-Defined Function', 'conditional-headers-blocks'),
            group: __('Advanced', 'conditional-headers-blocks'),
            description: __('Returns the result of a user-defined function.', 'conditional-headers-blocks'),
            bypassConfig: false
        },
        {
            type: 'query_string',
            label: __('Check a Query String Value', 'conditional-headers-blocks'),
            group: __('Advanced', 'conditional-headers-blocks'),
            description: __('Returns true if the specified query string parameter is matched.', 'conditional-headers-blocks'),
            bypassConfig: false
        }
    ];

    // Find condition in nested structure
    function findCondition(conditions, guid) {
        for (let condition of conditions) {
            if (condition.guid === guid) {
                return condition;
            }
            if (condition.conditions) {
                const found = findCondition(condition.conditions, guid);
                if (found) return found;
            }
        }
        return null;
    }

    // Action selector component
    function ActionSelector({ option, onChange }) {
        return React.createElement(RadioControl, {
            label: __('When conditions are met:', 'conditional-headers-blocks'),
            selected: option,
            options: [
                { label: __('Show this block', 'conditional-headers-blocks'), value: 'show' },
                { label: __('Hide this block', 'conditional-headers-blocks'), value: 'hide' }
            ],
            onChange: onChange
        });
    }

    // Condition configuration component
    function ConditionConfig({ condition, onChange }) {
        const { type } = condition;
        
        switch (type) {
            case 'post_id':
                return React.createElement(TextControl, {
                    label: __('Post ID', 'conditional-headers-blocks'),
                    help: __('Enter the post ID number', 'conditional-headers-blocks'),
                    type: 'number',
                    value: condition.postId || '',
                    onChange: (value) => onChange({ ...condition, postId: parseInt(value) || '' })
                });
                
            case 'post_slug':
                return React.createElement(TextControl, {
                    label: __('Post Slug', 'conditional-headers-blocks'),
                    help: __('Enter the post slug (URL name)', 'conditional-headers-blocks'),
                    value: condition.slug || '',
                    onChange: (value) => onChange({ ...condition, slug: value })
                });
                
            case 'user_has_role':
                return React.createElement('div', null,
                    React.createElement(TextControl, {
                        label: __('User Roles', 'conditional-headers-blocks'),
                        help: __('Enter role names separated by commas (e.g., administrator, editor)', 'conditional-headers-blocks'),
                        value: Array.isArray(condition.roles) ? condition.roles.join(', ') : (condition.roles || ''),
                        onChange: (value) => {
                            const roles = value.split(',').map(role => role.trim()).filter(role => role);
                            onChange({ ...condition, roles });
                        }
                    })
                );
                
            case 'post_has_term':
                return React.createElement('div', null,
                    React.createElement(TextControl, {
                        label: __('Taxonomy', 'conditional-headers-blocks'),
                        help: __('Enter taxonomy name (e.g., category, post_tag)', 'conditional-headers-blocks'),
                        value: condition.taxonomy || '',
                        onChange: (value) => onChange({ ...condition, taxonomy: value })
                    }),
                    React.createElement(TextControl, {
                        label: __('Terms', 'conditional-headers-blocks'),
                        help: __('Enter term slugs separated by commas', 'conditional-headers-blocks'),
                        value: Array.isArray(condition.terms) ? condition.terms.join(', ') : (condition.terms || ''),
                        onChange: (value) => {
                            const terms = value.split(',').map(term => term.trim()).filter(term => term);
                            onChange({ ...condition, terms });
                        }
                    })
                );
                
            case 'post_status':
                return React.createElement('select', {
                    value: condition.status || 'publish',
                    onChange: (e) => onChange({ ...condition, status: e.target.value })
                },
                    React.createElement('option', { value: 'publish' }, __('Published', 'conditional-headers-blocks')),
                    React.createElement('option', { value: 'draft' }, __('Draft', 'conditional-headers-blocks')),
                    React.createElement('option', { value: 'private' }, __('Private', 'conditional-headers-blocks')),
                    React.createElement('option', { value: 'pending' }, __('Pending', 'conditional-headers-blocks'))
                );
                
            case 'current_date':
                return React.createElement('div', null,
                    React.createElement('select', {
                        value: condition.compare || 'before',
                        onChange: (e) => onChange({ ...condition, compare: e.target.value })
                    },
                        React.createElement('option', { value: 'before' }, __('Before', 'conditional-headers-blocks')),
                        React.createElement('option', { value: 'after' }, __('After', 'conditional-headers-blocks')),
                        React.createElement('option', { value: 'same day' }, __('Same Day', 'conditional-headers-blocks'))
                    ),
                    React.createElement(TextControl, {
                        label: __('Date', 'conditional-headers-blocks'),
                        help: __('Enter date in YYYY-MM-DD format', 'conditional-headers-blocks'),
                        type: 'date',
                        value: condition.date || '',
                        onChange: (value) => onChange({ ...condition, date: value })
                    })
                );
                
            case 'user_function':
                return React.createElement(TextControl, {
                    label: __('Function Name', 'conditional-headers-blocks'),
                    help: __('Enter the PHP function name to call', 'conditional-headers-blocks'),
                    value: condition.function || '',
                    onChange: (value) => onChange({ ...condition, function: value })
                });
                
            case 'query_string':
                return React.createElement('div', null,
                    React.createElement(TextControl, {
                        label: __('Parameter Name', 'conditional-headers-blocks'),
                        help: __('Enter the query parameter name', 'conditional-headers-blocks'),
                        value: condition.parameter || '',
                        onChange: (value) => onChange({ ...condition, parameter: value })
                    }),
                    React.createElement(TextControl, {
                        label: __('Parameter Value', 'conditional-headers-blocks'),
                        help: __('Enter the value to check for', 'conditional-headers-blocks'),
                        value: condition.value || '',
                        onChange: (value) => onChange({ ...condition, value: value })
                    })
                );
                
            default:
                return null;
        }
    }

    // Condition item component with edit functionality
    function ConditionItem({ condition, onChange, onDelete }) {
        const [isEditing, setIsEditing] = useState(condition._needsConfig || false);
        const conditionType = conditionTypes.find(type => type.type === condition.type);
        
        if (isEditing) {
            return React.createElement('li', {
                className: 'chb-condition chb-condition-editing',
                key: condition.guid
            }, 
                React.createElement('div', {
                    className: 'chb-edit-form'
                },
                    React.createElement('h4', null, conditionType ? conditionType.label : condition.type),
                    React.createElement(TextControl, {
                        label: __('Label', 'conditional-headers-blocks'),
                        help: __('Custom label for this condition', 'conditional-headers-blocks'),
                        value: condition.label || '',
                        onChange: (value) => onChange({ ...condition, label: value })
                    }),
                    React.createElement(ToggleControl, {
                        label: __('Negate condition', 'conditional-headers-blocks'),
                        help: __('Reverse the result of this condition', 'conditional-headers-blocks'),
                        checked: condition.negate || false,
                        onChange: (value) => onChange({ ...condition, negate: value })
                    }),
                    React.createElement(ConditionConfig, {
                        condition: condition,
                        onChange: onChange
                    }),
                    React.createElement('div', {
                        className: 'chb-edit-buttons'
                    },
                        React.createElement(Button, {
                            isPrimary: true,
                            onClick: () => {
                                // Clean up internal flags
                                const cleanCondition = { ...condition };
                                delete cleanCondition._needsConfig;
                                onChange(cleanCondition);
                                setIsEditing(false);
                            }
                        }, __('Save', 'conditional-headers-blocks')),
                        React.createElement(Button, {
                            isDestructive: true,
                            variant: 'secondary',
                            onClick: () => {
                                if (confirm(__('Delete this condition?', 'conditional-headers-blocks'))) {
                                    onDelete(condition);
                                }
                            }
                        }, __('Delete', 'conditional-headers-blocks'))
                    )
                )
            );
        }
        
        return React.createElement('li', {
            className: 'chb-condition',
            key: condition.guid
        }, 
            React.createElement('div', {
                className: 'chb-content'
            }, condition.label || (conditionType ? conditionType.label : condition.type)),
            React.createElement('div', {
                className: 'chb-edit'
            }, 
                React.createElement(Button, {
                    isSmall: true,
                    onClick: () => setIsEditing(true)
                }, __('Edit', 'conditional-headers-blocks'))
            )
        );
    }

    // Conditions list component
    function ConditionsList({ conditions, onChange }) {
        const handleConditionChange = (updatedCondition) => {
            const newConditions = conditions.map(condition =>
                condition.guid === updatedCondition.guid ? updatedCondition : condition
            );
            onChange(newConditions);
        };

        const handleConditionDelete = (conditionToDelete) => {
            const newConditions = conditions.filter(condition => 
                condition.guid !== conditionToDelete.guid
            );
            onChange(newConditions);
        };

        if (!conditions.length) {
            return React.createElement('div', {
                className: 'chb-empty'
            }, 
                React.createElement('p', null, 
                    __('Show or hide this block based on conditions. Add a condition to get started.', 'conditional-headers-blocks')
                )
            );
        }

        const conditionItems = conditions.map(condition =>
            React.createElement(ConditionItem, {
                key: condition.guid,
                condition: condition,
                onChange: handleConditionChange,
                onDelete: handleConditionDelete
            })
        );

        return React.createElement('ul', {
            className: 'chb-conditions-list'
        }, conditionItems);
    }

    // Add condition selector component
    function AddConditionSelector({ onAdd }) {
        const [isOpen, setIsOpen] = useState(false);

        if (!isOpen) {
            return React.createElement(Button, {
                isLink: true,
                onClick: () => setIsOpen(true)
            }, __('Add Condition', 'conditional-headers-blocks'));
        }

        const conditionsByGroup = conditionTypes.reduce((groups, condition) => {
            const group = condition.group || 'Other';
            if (!groups[group]) groups[group] = [];
            groups[group].push(condition);
            return groups;
        }, {});

        const groupElements = Object.keys(conditionsByGroup).map(groupName => {
            const groupConditions = conditionsByGroup[groupName];
            const conditionButtons = groupConditions.map(conditionType =>
                React.createElement('li', { key: conditionType.type },
                    React.createElement(Button, {
                        isLink: true,
                        onClick: () => {
                            const newCondition = {
                                guid: generateUUID(),
                                type: conditionType.type,
                                label: conditionType.label,
                                operator: 'and',
                                negate: false,
                                // Set flag to auto-open edit if condition needs configuration
                                _needsConfig: !conditionType.bypassConfig
                            };
                            onAdd(newCondition);
                            setIsOpen(false);
                        }
                    }, conditionType.label)
                )
            );

            return React.createElement(Fragment, { key: groupName },
                React.createElement('h4', null, groupName),
                React.createElement('ul', null, conditionButtons)
            );
        });

        return React.createElement('div', {
            className: 'chb-select-condition'
        }, 
            React.createElement('h3', null, __('Select a condition to add:', 'conditional-headers-blocks')),
            groupElements,
            React.createElement(Button, {
                variant: 'secondary',
                onClick: () => setIsOpen(false)
            }, __('Cancel', 'conditional-headers-blocks'))
        );
    }

    // Main conditions panel component
    function ConditionsPanel({ attributes, setAttributes }) {
        const conditions = attributes.conditionalHeadersBlocksConditions || {
            action: 'show',
            conditions: []
        };

        const updateConditions = (newData) => {
            setAttributes({
                conditionalHeadersBlocksConditions: assign({}, conditions, newData)
            });
        };

        const handleActionChange = (action) => {
            updateConditions({ action });
        };

        const handleConditionsChange = (newConditions) => {
            updateConditions({ conditions: newConditions });
        };

        const handleAddCondition = (newCondition) => {
            const newConditions = [...conditions.conditions, newCondition];
            updateConditions({ conditions: newConditions });
        };

        return React.createElement(PanelBody, {
            title: __('Display Conditions', 'conditional-headers-blocks'),
            initialOpen: false
        },
            React.createElement(ActionSelector, {
                option: conditions.action,
                onChange: handleActionChange
            }),
            React.createElement(ConditionsList, {
                conditions: conditions.conditions,
                onChange: handleConditionsChange
            }),
            React.createElement(AddConditionSelector, {
                onAdd: handleAddCondition
            })
        );
    }

    // Higher-order component that adds the conditions panel to all blocks
    const withConditionalDisplay = createHigherOrderComponent(function(BlockEdit) {
        return function(props) {
            return React.createElement(Fragment, null,
                React.createElement(BlockEdit, props),
                React.createElement(InspectorControls, null,
                    React.createElement(ConditionsPanel, {
                        attributes: props.attributes,
                        setAttributes: props.setAttributes
                    })
                )
            );
        };
    }, 'withConditionalDisplay');

    // Add attribute to all block types
    addFilter(
        'blocks.registerBlockType',
        'conditional-headers-blocks/add-attribute',
        function(settings) {
            settings.attributes = assign(settings.attributes, {
                conditionalHeadersBlocksConditions: {
                    type: 'object',
                    default: {
                        action: 'show',
                        conditions: []
                    }
                }
            });
            return settings;
        }
    );

    // Add save props for frontend
    addFilter(
        'blocks.getSaveContent.extraProps',
        'conditional-headers-blocks/add-props',
        function(props, blockType, attributes) {
            props.conditionalHeadersBlocksConditions = attributes.conditionalHeadersBlocksConditions;
            return props;
        }
    );

    // Apply the HOC to all blocks
    addFilter(
        'editor.BlockEdit',
        'conditional-headers-blocks/with-conditions',
        withConditionalDisplay
    );

})();