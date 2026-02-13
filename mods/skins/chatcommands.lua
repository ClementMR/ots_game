core.register_privilege("skins", {
	description = "Change the skin of your character",
	give_to_singleplayer = false,
})

--[[
core.register_chatcommand("skins", {
	params = "<value>",
	description = "Set a skin",
	func = function(name, param)
		local player = core.get_player_by_name(name)

		if not player then
			return false, "Player not found"
		end

		local inv = player:get_inventory()
		if not core.check_player_privs(name, {skins=true}) then
			if player:get_wielded_item():get_name() == "moreores:mithril_block" then
				local privs = core.get_player_privs(name)
				privs["skins"] = true

				core.set_player_privs(name, privs)

				inv:remove_item("main", "moreores:mithril_block")

				return true, "You have been granted the skins privilege"
			else
				return false, "You must hold a mithril block in your hand to set a skin"
			end
		else
			local skin_name = param
			if param == "0" then
				skin_name = skins.default
			elseif not skins.get(skin_name) and skins.get("character." .. skin_name) then
				skin_name = "character." .. skin_name
			end

			local success = skins.set_player_skin(player, skin_name)
			if success then
				return true, "Skin set to "..param
			else
				return false, "Invalid skin "..param..". Please type /list_skins"
			end
		end
	end,
})
]]

core.register_chatcommand("skin_info", {
	description = "Print information about the current skin",
	func = function(name)
		local player = core.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end

		local skin = skins.get_player_skin(player)
		if skin then
			local skin_name = skin.name or "Unknown"
			local author = skin.author or "Unknown"
			local license = skin.license or "None"
			core.chat_send_player(name, core.colorize("cyan", "~ Current skin ~") ..
				"\nName:" .. skin_name .. "\n" ..
				"Author: " .. author .. "\n" ..
				"License: " .. license)
		end
	end,
})