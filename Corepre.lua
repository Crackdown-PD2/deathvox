DeathvoxMapFramework = DeathvoxMapFramework or class(MapFramework)
DeathvoxMapFramework._directory = ModPath .. "map_replacements"
DeathvoxMapFramework.type_name = "deathvox"
log(DeathvoxMapFramework._directory)
DeathvoxMapFramework:new()