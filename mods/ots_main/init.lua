local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath .. "/chatcommands.lua")
dofile(modpath .. "/recipes.lua")
dofile(modpath .. "/nodes.lua")
--dofile(modpath .. "/expire.lua")

core.hud_replace_builtin("breath", {
	hud_elem_type = "statbar",
	position = {x = 0.5, y = 1},
	text = "bubble.png",
	text2 = "bubble_gone.png",
	number = core.PLAYER_MAX_BREATH_DEFAULT * 2,
	item = core.PLAYER_MAX_BREATH_DEFAULT * 2,
	direction = 0,
	size = {x = 24, y = 24},
	offset = {x = 25, y= -120},
})

print ("[MOD] OTS loaded")