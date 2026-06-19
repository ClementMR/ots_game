core.register_chatcommand("skin_info", {
	description = "Print information about the current skin",
	func = function(name)
		local player = core.get_player_by_name(name)
		if not player then
			return false
		end

		local skin = skins.get_player_skin(player)
		if skin then
			core.chat_send_player(name, core.colorize("cyan", "~ Current skin ~") .. "\n" ..
				"Name:" .. skin:get_skin_name() .. "\n" ..
				"Author: " .. skin:get_skin_author() .. "\n" ..
				"License: " .. skin:get_skin_license())
		end
	end,
})

core.register_chatcommand("get_skins_for", {
	privs = {server = true},
	description = "Get skins for player",
	func = function(name, param)
		if not core.get_player_by_name(param) then return false, "Player '" .. param .. "' not found" end
		local skinslist = skins.get_skinlist_for_player(param)
		local result = {}
		for _, skin in pairs(skinslist) do
			table.insert(result, skin:get_key())
		end
		return true, "Skins for player '" .. param .. "': " .. table.concat(result, ", ")
	end
})