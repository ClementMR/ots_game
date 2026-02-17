local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath .. "/chatcommands.lua")
dofile(modpath .. "/recipes.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/vanish.lua")

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

core.register_on_newplayer(function(player)
	local name = player:get_player_name()
	core.chat_send_all((core.colorize("#31C950", "The player \"%s\" joined the server for the first time!")):format(name))
	core.sound_play("ots_main_newplayer", {gain = 1.0}, true)
end)

print ("[MOD] OTS loaded")