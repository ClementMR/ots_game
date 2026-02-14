protector = {
	max_shares = 12,
	radius = tonumber(core.settings:get("protector_radius")) or 5
}

dofile( core.get_modpath(core.get_current_modname()) .. "/doors.lua")
dofile( core.get_modpath(core.get_current_modname()) .. "/hyper_chest.lua")
dofile( core.get_modpath(core.get_current_modname()) .. "/mailbox.lua")
dofile( core.get_modpath(core.get_current_modname()) .. "/protected_chest.lua")
dofile( core.get_modpath(core.get_current_modname()) .. "/protectors.lua")
dofile( core.get_modpath(core.get_current_modname()) .. "/recipes.lua")
