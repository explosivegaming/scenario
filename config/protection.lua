return {
    ignore_admins = true, --- @setting ignore_admins If admins are ignored by the protection filter
    ignore_permission = 'bypass-entity-protection', --- @setting ignore_permission Players with this permission will be ignored by the protection filter, leave nil if expcore.roles is not used
    repeat_count = 5, --- @setting repeat_count Number of protected entities to be removed to count as repeated
    repeat_lifetime = 3600*20, --- @setting repeat_lifetime How old repeats must be before being removed
    refresh_rate = 3600*5, --- @setting refresh_rate How often old repeats will be removed
    always_protected_names = { --- @setting always_protected_names Names of entities which are always protected

    },
    always_protected_types = { --- @setting always_protected_types Types of entities which are always protected
        'boiler', 'generator', 'offshore-pump', 'power-switch', 'reactor', 'rocket-silo'
    },
    skip_repeat_names = { --- @setting skip_repeat_names Names of entities which always trigger protection repeated

    },
    skip_repeat_types = { --- @setting skip_repeat_types Types of entities which trigger protection repeated
        'reactor', 'rocket-silo'
    }
}