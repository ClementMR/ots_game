local S = core.get_translator(core.get_current_modname())


local function get_online_players()
    local players = {}
    for _, player in ipairs(core.get_connected_players()) do
        local name = player:get_player_name()
        table.insert(players, name)
    end

    return players
end

core.register_chatcommand("online", {
    description = "Show online players",
    func = function(name)
        local players = get_online_players()
        return true, core.colorize("grey", "Player(s): "..table.concat(players, ", "))
    end
})

core.register_chatcommand("clear_bed", {
    description = "Clear your bed spawn position",
    privs = {interact = true},
    func = function(name)
        if beds.spawn[name] then
            beds.spawn[name] = nil
            beds.save_spawns()
            return true, "Your bed spawn position has been cleared."
        else
            return false, "You don't have a bed spawn position set."
        end
    end,
})

core.register_chatcommand("s_msg", {
	params = "<name> <message>",
	description = "Send a direct message to a player (Admin tunnel)",
	privs = {server=true},
	func = function(name, param)
		local sendto, message = param:match("^(%S+)%s(.+)$")
		if not sendto then
			return false, "Invalid usage, see /help s_msg."
		end

		if not core.get_player_by_name(sendto) then
			return false, "The player "..sendto.." is not online."
		end

		core.chat_send_player(sendto, core.colorize("yellow", "[Server] "..message))

		core.log("action", "[Server] sent to "..sendto..": "..message)

		return true, "Message sent to "..sendto.."."
	end,
})

core.register_chatcommand("s_all", {
	params = "<message>",
	description = "Send a message to all players (Admin tunnel)",
	privs = {server=true},
	func = function(name, param)
		if not param or param == "" then
			return false, "Invalid usage, see /help s_all."
		end

		core.chat_send_all(core.colorize("yellow", "[Server] "..param))

		core.log("action", "[Server] sent : "..param)
	end,
})

core.register_on_mods_loaded(function()
	local function empty_func() end

	core.send_join_message = empty_func
	core.send_leave_message = empty_func

	core.register_on_joinplayer(function(player, last_login)
        if not core.is_singleplayer() then
            core.chat_send_all(core.colorize("#0F820F", S("@1 joined the game.", player:get_player_name())))
        end
	end)

	core.register_on_leaveplayer(function(player, timed_out)
        local name = player:get_player_name()
        local announcement = core.colorize("#820B0B", S("@1 left the game.", name))
        if timed_out then
            announcement = core.colorize("#820B0B", S("@1 left the game (timed out).", name))
        end

        core.chat_send_all(announcement)
	end)
end)