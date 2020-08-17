--- This contains a list of all files that will be loaded and the order they are loaded in;
-- to stop a file from loading add "--" in front of it, remove the "--" to have the file be loaded;
-- config files should be loaded after all modules are loaded;
-- core files should be required by modules and not be present in this list;
-- @config File-Loader
return {
    --'example.file_not_loaded',
    'modules.factorio-control', -- base factorio free play scenario
    'expcore.player_data',

    --- Game Commands
    'modules.commands.me',
    'modules.commands.kill',
    'modules.commands.admin-chat',
    'modules.commands.teleport',
    'modules.commands.cheat-mode',
    'modules.commands.ratio',
    'modules.commands.interface',
    'modules.commands.help',
    'modules.commands.roles',
    'modules.commands.rainbow',
    'modules.commands.clear-inventory',
    'modules.commands.jail',
    'modules.commands.repair',
    'modules.commands.reports',
    'modules.commands.spawn',
    'modules.commands.warnings',
    'modules.commands.find',
    'modules.commands.home',
    'modules.commands.connect',

    --- Addons
    'modules.addons.chat-popups',
    'modules.addons.damage-popups',
    'modules.addons.death-logger',
    'modules.addons.advanced-start',
    'modules.addons.spawn-area',
    'modules.addons.compilatron',
    'modules.addons.scorched-earth',
    'modules.addons.pollution-grading',
    'modules.addons.station-auto-name',
    'modules.addons.discord-alerts',
    'modules.addons.chat-reply',
    'modules.addons.tree-decon',

    --- Data
    'modules.data.statistics',
    'modules.data.player-colours',
    'modules.data.greetings',
    'modules.data.quickbar',
    'modules.data.alt-view',
    'modules.data.tag',
    'modules.data.bonus',

    --- GUI
    'modules.gui.readme',
    'modules.gui.rocket-info',
    'modules.gui.science-info',
    'modules.gui.warp-list',
    'modules.gui.task-list',
    'modules.gui.player-list',
    'modules.gui.server-ups',
    'modules.commands.debug',

    --- Config Files
    'config.expcore.command_auth_admin', -- commands tagged with admin_only are blocked for non admins
    'config.expcore.command_auth_roles', -- commands must be allowed via the role config
    'config.expcore.command_runtime_disable', -- allows commands to be enabled and disabled during runtime
    'config.expcore.permission_groups', -- loads some predefined permission groups
    'config.expcore.roles', -- loads some predefined roles
}
