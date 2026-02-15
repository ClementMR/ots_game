local S = core.get_translator("pex")

core.register_node("pex:chest", {
	description = S("Protected Chest"),
	tiles = {
		"default_chest_top.png", "default_chest_top.png",
		"default_chest_side.png", "default_chest_side.png",
		"default_chest_side.png",  "default_chest_front.png^protector_logo.png",
	},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		meta:set_string("infotext", S("Protected Chest"))
		inv:set_size("main", 8*4)
	end,
	can_dig = function(pos, player)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		if inv:is_empty("main") then
			if not core.is_protected(pos, player:get_player_name()) then
				return true
			end
		end
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		core.log("action", player:get_player_name().." moves stuff to protected chest at "..core.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		core.log("action", player:get_player_name().." takes stuff from protected chest at "..core.pos_to_string(pos))
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		core.log("action", player:get_player_name().." moves stuff inside protected chest at "..core.pos_to_string(pos))
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if core.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if core.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if core.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return count
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		if core.is_protected(pos, clicker:get_player_name()) then
			return
		end
		local spos = pos.x .. "," .. pos.y .. "," ..pos.z
		local formspec =
			"size[8,9]" ..
			"list[nodemeta:" .. spos .. ";main;0,0.3;8,4;]" ..
			"list[current_player;main;0,4.85;8,1;]" ..
			"list[current_player;main;0,6.08;8,3;8]" ..
			"listring[nodemeta:" .. spos .. ";main]" ..
			"listring[current_player;main]" ..
			default.get_hotbar_bg(0,4.85)

		core.show_formspec(clicker:get_player_name(), "pex:protected_chest", formspec)
	end,
	on_blast = function() end,
})