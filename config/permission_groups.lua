local Permission_Groups = require 'expcore.permission_groups'

Permission_Groups.new_group('admin')
:allow_all()
:disallow{
    'add_permission_group', -- admin
    'delete_permission_group',
    'edit_permission_group',
    'import_permissions_string',
    'map_editor_action',
    'toggle_map_editor',
    'change_multiplayer_config',
    'set_heat_interface_mode',
    'set_heat_interface_temperature',
    'set_infinity_container_filter_item',
    'set_infinity_container_remove_unfiltered_items',
    'set_infinity_pipe_filter'
}

Permission_Groups.new_group('trusted')
:allow_all()
:disallow{
    'add_permission_group', -- admin
    'delete_permission_group',
    'edit_permission_group',
    'import_permissions_string',
    'map_editor_action',
    'toggle_map_editor',
    'change_multiplayer_config',
    'set_heat_interface_mode',
    'set_heat_interface_temperature',
    'set_infinity_container_filter_item',
    'set_infinity_container_remove_unfiltered_items',
    'set_infinity_pipe_filter',
    'admin_action' -- trusted
}

Permission_Groups.new_group('standard')
:allow_all()
:disallow{
    'add_permission_group', -- admin
    'delete_permission_group',
    'edit_permission_group',
    'import_permissions_string',
    'map_editor_action',
    'toggle_map_editor',
    'change_multiplayer_config',
    'set_heat_interface_mode',
    'set_heat_interface_temperature',
    'set_infinity_container_filter_item',
    'set_infinity_container_remove_unfiltered_items',
    'set_infinity_pipe_filter',
    'admin_action', -- trusted
    'change_programmable_speaker_alert_parameters', -- standard
    'drop_item',
    'reset_assembling_machine',
    'set_auto_launch_rocket',
    'cancel_research'
}

Permission_Groups.new_group('guest')
:allow_all()
:disallow{
    'add_permission_group', -- admin
    'delete_permission_group',
    'edit_permission_group',
    'import_permissions_string',
    'map_editor_action',
    'toggle_map_editor',
    'change_multiplayer_config',
    'set_heat_interface_mode',
    'set_heat_interface_temperature',
    'set_infinity_container_filter_item',
    'set_infinity_container_remove_unfiltered_items',
    'set_infinity_pipe_filter',
    'admin_action', -- trusted
    'change_programmable_speaker_alert_parameters', -- standard
    'drop_item',
    'reset_assembling_machine',
    'set_auto_launch_rocket',
    'cancel_research',
    'change_programmable_speaker_parameters', -- guest
    'change_train_stop_station',
    'deconstruct',
    'remove_cables',
    'remove_train_station',
    'reset_assembling_machine',
    'rotate_entity',
    'use_artillery_remote',
    'launch_rocket'
}

Permission_Groups.new_group('restricted')
:disallow_all()
:allow('write_to_console')