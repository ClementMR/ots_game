local ACTIVATION_DELAY = 86450 -- ~= 1 Day

local S = core.get_translator("pex")

local function time_format(time)
	if time >= 3600 then
		return S("@1 hour(s)", math.floor(time/3600)) -- hours
	elseif time >= 60 then
		return S("@1 minute(s)", math.floor(time/60)) -- minutes
	end
	return S("@1 second(s)", time) -- seconds
end

core.register_node("pex:chest_hyper", {
	description = core.colorize("yellow", S("Hyper Chest")),
	tiles = {
		"pex_hyper_chest_top.png", "pex_hyper_chest_top.png",
		"pex_hyper_chest_side.png", "pex_hyper_chest_side.png",
		"pex_hyper_chest_side.png", "pex_hyper_chest_side.png^pex_hyper_chest_lock.png"
	},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	groups = {cracky = 1},
	sounds = default.node_sound_metal_defaults(),
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		meta:set_string("infotext", S("Hyper Chest"))
		meta:set_int("delay", os.time())
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local meta = core.get_meta(pos)
		local time_elapsed = os.time() - meta:get_int("delay")
		local player_name = clicker:get_player_name()

		if time_elapsed < ACTIVATION_DELAY then
			core.chat_send_player(player_name,
			S("This @1 will be active in @2",
			core.colorize("yellow", S("Hyper Chest")),
			time_format(ACTIVATION_DELAY - time_elapsed)))
			return
		end

		core.show_formspec(player_name, "pex:hyper_chest",
			[[
				size[8,9]
				list[current_player;pex:hyper_chest;0,0.3;8,4;]
				list[current_player;main;0,4.85;8,1;]
				list[current_player;main;0,6.08;8,3;8]
				listring[current_player;pex:hyper_chest]
				listring[current_player;main]
			]] .. default.get_hotbar_bg(0,4.85)
		)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		core.log("action", player:get_player_name() .. " moves stuff to hyper chest at " .. core.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		core.log("action", player:get_player_name() .. " takes stuff from hyper chest at " .. core.pos_to_string(pos))
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		core.log("action", player:get_player_name() .. " moves stuff inside hyper chest at " .. core.pos_to_string(pos))
	end,
	on_blast = function() end,
})

core.register_on_joinplayer(function(player)
	player:get_inventory():set_size("pex:hyper_chest", 8*4)
end)