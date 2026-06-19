local S = core.get_translator("ots_main")

local function get_online_players()
    local players = {}
    for _, player in ipairs(core.get_connected_players()) do
        local name = player:get_player_name()
        table.insert(players, name)
    end

    return players
end

core.register_chatcommand("online", {
    description = S("Show online players"),
    func = function(name)
        local players = get_online_players()
        return true, core.colorize("grey", S("Player(s): @1", table.concat(players, ", ")))
    end
})

core.register_chatcommand("clear_bed", {
    description = S("Clear your bed spawn position"),
    privs = {interact = true},
    func = function(name)
        if beds.spawn[name] then
            beds.spawn[name] = nil
            beds.save_spawns()
            return true, S("Your bed spawn position has been cleared.")
        else
            return false, S("You don't have a bed spawn position set.")
        end
    end,
})

core.register_chatcommand("s_msg", {
	params = "<name> <message>",
	description = S("Send a direct message to a player (Admin tunnel)"),
	privs = {server=true},
	func = function(name, param)
		local sendto, message = param:match("^(%S+)%s(.+)$")
		if not sendto then
			return false, S("Invalid usage, see /help s_msg.")
		end

		if not core.get_player_by_name(sendto) then
			return false, S("The player @1 is not online.", sendto)
		end

		core.chat_send_player(sendto, core.colorize("yellow", "[Server] "..message))

		core.log("action", "[Server] sent to "..sendto..": "..message)

		return true, S("Message sent to @1.", sendto)
	end,
})

core.register_chatcommand("s_all", {
	params = "<message>",
	description = S("Send a message to all players (Admin tunnel)"),
	privs = {server=true},
	func = function(name, param)
		if not param or param == "" then
			return false, S("Invalid usage, see /help s_all.")
		end

		core.chat_send_all(core.colorize("yellow", "[Server] "..param))

		core.log("action", "[Server] sent : "..param)
	end,
})
