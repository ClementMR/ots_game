local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath .. "/chat.lua")
dofile(modpath .. "/recipes.lua")
--dofile(modpath .. "/expire.lua")

core.override_item("default:tinblock", {
    sounds = default.node_sound_stone_defaults(),
})

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

function get_players()
    local players = {}
    for _, player in ipairs(core.get_connected_players()) do
        local name = player:get_player_name()
        table.insert(players, name)
    end

    return players
end

core.register_on_joinplayer(function(player)
    local players = get_players()
    core.chat_send_player(player:get_player_name(), core.colorize("grey", "Player(s): "..table.concat(players, ", ")))
end)

core.register_chatcommand("online", {
    description = "Show online players",
    func = function(name)
        local players = get_players()
        return true, core.colorize("grey", "Player(s): "..table.concat(players, ", "))
    end
})

print ("[MOD] 421 loaded")