local armor_exists = core.global_exists("armor")
local skins_exists = core.global_exists("skins")

local SKINS_PAYMENT = "moreores:mithril_block"

local function get_formspec(player)
	local player_name = player:get_player_name()

	local skin_texture  = "character.png"
	local armor_texture = "blank.png"
	local wield_texture = "blank.png"

	-- Get armor textures
	if _G.armor and _G.armor.textures and _G.armor.textures[player_name] then
		local textures = _G.armor.textures[player_name]
		armor_texture = textures.armor    	or armor_texture
		wield_texture = textures.wielditem 	or wield_texture
	end

	local fs = {
		"size[12,8.5]"..
		"list[current_player;craft;6.3,0.75;3,3;]"..
		"list[current_player;craftpreview;10.25,1.75;1,1;]"..
		"list[current_player;main;3.75,4.25;8,1;]"..
		"list[current_player;main;3.75,5.5;8,3;8]"..
		"image[9.25,1.75;1,1;sfinv_crafting_arrow.png]"..
		"listring[current_player;craft]"..
		"listring[current_player;main]"..

		"background[-0.15,-0.22;3.8,9.19;ots_inv_bg.png]"..

		"hypertext[0.2,0;3,0.8;character_title;<b>Character</b>]"..
		"hypertext[4,0;3,0.8;character_title;<b>Crafting</b>]"
	}

	for i=1, 8 do
		table.insert(fs, "image[" .. (i + 2.75) .. ",4.25;1,1;gui_hb_bg.png]")
	end

	if skins_exists then
		skin_texture = skins.get_player_skin(player):get_texture()

		if core.get_player_privs(player_name).skins then
			table.insert(fs, "style[previous_skin_btn;bgcolor=#EC253F]"..
				"style[next_skin_btn;bgcolor=#EC253F]"..
				"image_button[1.7,6.2;0.75,0.75;ots_inv_left_arrow.png;previous_skin_btn;;false;true;]"..
				"image_button[2.3,6.2;0.75,0.75;ots_inv_right_arrow.png;next_skin_btn;;false;true;]"..
				"tooltip[previous_skin_btn;Previous skin]"..
				"tooltip[next_skin_btn;Next skin]")
		else
			table.insert(fs, "image_button[2,6.2;0.75,0.75;ots_inv_skin_extension_btn.png;skin_extension_btn;;false;true;]"..
				"tooltip[skin_extension_btn;Buy skin extension for 1 mithril block!]")
		end
	end

	if armor_exists then
		local name, armor_inv = armor:get_valid_player(player)
		local pieces = {"helmet", "chestplate", "leggings", "boots", "shield"}

		if name and armor_inv then
			for i=1, armor_inv:get_size("armor") do
				local stack = armor_inv:get_stack("armor", i)
				if stack and stack:is_empty() then
					table.insert(fs, "image[0,".. (i+0.9) ..";1,1;ots_inv_" .. pieces[i] .. ".png]")
				end
			end
		end
		table.insert(fs, "model[1,2.2;3,4.5;model;3d_armor_character.b3d;" ..
			skin_texture .. "," .. armor_texture .. "," .. wield_texture .. ";0,150;false;true;3,80;30]" ..
			"list[detached:" .. player_name .. "_armor;armor;0,1.9;1,5;]")
	end

	table.insert(fs, "image_button[10.25,0.5;1,1;craftguide_icon.png;craftguide_btn;;false;false;]"..
		"tooltip[craftguide_btn;Open the crafting guide]")

	return table.concat(fs)
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then return end -- Only react to the inventory form
	local player_name = player:get_player_name()

	if fields.skin_extension_btn then
		local inventory = player:get_inventory()
		if inventory:contains_item("main", SKINS_PAYMENT) then
			core.change_player_privs(player_name, {skins=true})
			core.sound_play("ots_inv_buy_skins", {to_player = player_name, gain=1.0})

			inventory:remove_item("main", SKINS_PAYMENT)
			player:set_inventory_formspec(get_formspec(player))
		else
			core.chat_send_player(player_name, core.colorize("#8c0e0e",
				"You need a mithril block to buy the skin extension!"))
		end
	elseif fields.previous_skin_btn then
		local current_skin_key = skins.get_player_skin(player):get_key()
		for i, skin in ipairs(skins.get_skinlist_for_player(player_name)) do
			if current_skin_key == skin:get_key() then -- Found the current skin in the list
				local skin_index = i - 1 -- Move to the previous skin
				if skin_index < 1 then
					skin_index = #skins.get_skinlist_for_player(player_name) -- Wrap around to the last skin if the index goes below 1
				end
				skins.set_player_skin(player, skins.get_skinlist_for_player(player_name)[skin_index])
				player:set_inventory_formspec(get_formspec(player))
				break
			end
		end
	elseif fields.next_skin_btn then
		local current_skin_key = skins.get_player_skin(player):get_key()
		for i, skin in ipairs(skins.get_skinlist_for_player(player_name)) do
			if current_skin_key == skin:get_key() then -- Found the current skin in the list
				local skin_index = i + 1 -- Move to the next skin
				if skin_index > #skins.get_skinlist_for_player(player_name) then
					skin_index = 1 -- Wrap around to the first skin if the index exceeds the list
				end
				skins.set_player_skin(player, skins.get_skinlist_for_player(player_name)[skin_index])
				player:set_inventory_formspec(get_formspec(player))
				break
			end
		end
	end
end)

if armor_exists then
	armor:register_on_update(function(player)
		player:set_inventory_formspec(get_formspec(player))
	end)
else
	core.register_on_joinplayer(function(player, last_login)
		player:set_inventory_formspec(get_formspec(player))
	end)
end
