core.register_privilege("skins", {
	description = "Can set skins",
	give_to_singleplayer = false,
})

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
				return true, "skin set to "..param
			else
				return false, "invalid skin "..param
			end
		end
	end,
})

core.register_chatcommand("list_skins", {
	description = "List of skins",
	privs = {skins=true},
	func = function(name)
		local player = core.get_player_by_name(name)

		local list = skins.get_skinlist_for_player()
		--list = skins.get_skinlist_with_meta("playername", name)

		local info = {}
		for v, skin in ipairs(list) do
			table.insert(info, "["..(v-1).."] "..skin:get_meta_string("name"))
		end

		local info_string = table.concat(info, ", ")

		if #info_string > 0 then
			core.chat_send_player(name, info_string)
		else
			core.chat_send_player(name, "No skins found")
		end
	end,
})