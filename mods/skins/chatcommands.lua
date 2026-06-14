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