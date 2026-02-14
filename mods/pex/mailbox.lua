local function get_mailbox_form(pos)
	local spos = pos.x .. "," .. pos.y .. "," ..pos.z
	local formspec =
		"size[8,9]"..
		"list[nodemeta:".. spos .. ";main;0,0;8,4;]"..
		"list[current_player;main;0,4.85;8,1;]" ..
		"list[current_player;main;0,6.08;8,3;8]" ..
		"listring[nodemeta:".. spos .. ";main]" ..
		"listring[current_player;main]" ..
		default.get_hotbar_bg(0,4.85)

	return formspec
end

local function get_mailbox_insert_form(pos)
	local spos = pos.x .. "," .. pos.y .. "," ..pos.z
	local formspec =
		"size[8,9]"..
		"list[nodemeta:".. spos .. ";drop;3.5,2;1,1;]"..
		"list[current_player;main;0,4.85;8,1;]" ..
		"list[current_player;main;0,6.08;8,3;8]" ..
		"listring[nodemeta:".. spos .. ";drop]" ..
		"listring[current_player;main]" ..
		default.get_hotbar_bg(0,4.85)

	return formspec
end

core.register_node("pex:mailbox", {
	description = "Mailbox",
	tiles = {
		"xdecor_mailbox_top.png", "xdecor_mailbox_bottom.png",
		"xdecor_mailbox_side.png", "xdecor_mailbox_side.png",
		"xdecor_mailbox.png", "xdecor_mailbox.png"
	},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer, itemstack)
		local meta = core.get_meta(pos)
		local owner = placer:get_player_name()
		meta:set_string("owner", owner)
		meta:set_string("infotext", "Mailbox (owned by "..owner..")")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
		inv:set_size("drop", 1)
	end,
	can_dig = function(pos, player)
		local meta = core.get_meta(pos)
		local owner = meta:get_string("owner")
		local inv = meta:get_inventory()

		return (player:get_player_name() == owner or core.get_player_privs(player:get_player_name()).protection_bypass)
			and inv:is_empty("main")
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = core.get_meta(pos)
		local owner = meta:get_string("owner")
		local inv = meta:get_inventory()
		if listname == "drop" and inv:room_for_item("main", stack) then
			inv:remove_item("drop", stack)
			inv:add_item("main", stack)
			core.log("action", player:get_player_name().. " added an item to "..owner.."'s Mailbox at "..core.pos_to_string(pos))
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "main" then
			return 0
		end
		if listname == "drop" then
			local meta = core.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:room_for_item("main", stack) then
				return -1
			else
				return 0
			end
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = core.get_meta(pos)
		local owner = meta:get_string("owner")
		if player:get_player_name() ~= owner then
			return 0
		end
		return stack:get_count()
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		local meta = core.get_meta(pos)
		local owner  = meta:get_string("owner")
		if owner == clicker:get_player_name() or core.get_player_privs(clicker:get_player_name()).protection_bypass then
			core.show_formspec(clicker:get_player_name(), "pex:mailbox", get_mailbox_form(pos))
		else
			core.show_formspec(clicker:get_player_name(), "pex:mailbox", get_mailbox_insert_form(pos))
		end
	end,
	on_blast = function() end,
})