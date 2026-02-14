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