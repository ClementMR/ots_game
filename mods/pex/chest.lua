-- Protected Chest

core.register_node("pex:chest", {
	description = "Protected Chest",
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

		meta:set_string("infotext", "Protected Chest")
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

		core.show_formspec(clicker:get_player_name(), "pex:chest", formspec)
	end,
	on_blast = function() end,
})

-- Hyper chest

core.register_node("pex:chest_hyper", {
	description = "Hyper Chest",
	tiles = {
		"default_chest_top.png", "default_chest_top.png",
		"default_chest_side.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_front.png^pex_hyper_chest_lock.png"
	},
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		meta:set_string("infotext", "Hyper Chest")
		meta:set_int("delay", os.time())
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local meta = core.get_meta(pos)
		local time_elapsed = os.time() - meta:get_int("delay")
		local delay = 86400
		local left = delay - time_elapsed

		if left > 3600 then
			left = math.floor(left/3600).."h"
		elseif left > 60 then
			left = math.floor(left/60).."m"
		else
			left = left.."s"
		end

		if time_elapsed < delay then
			core.chat_send_player(clicker:get_player_name(), "Hyper Chest is not active, wait "..left)
			return
		end

		local form = "size[8,9]"..
			"list[current_player;pex:hyper_chest;0,0.3;8,4;]"..
			"list[current_player;main;0,4.85;8,1;]" ..
			"list[current_player;main;0,6.08;8,3;8]" ..
			"listring[current_player;pex:hyper_chest]" ..
			"listring[current_player;main]"..
			default.get_hotbar_bg(0,4.85)

		core.show_formspec(clicker:get_player_name(), "pex:hyper_chest", form)

		local inv = clicker:get_inventory()
		inv:set_size("pex:hyper_chest", 8*4)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		core.log("action", player:get_player_name().." moves stuff to hyper chest at "..core.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		core.log("action", player:get_player_name().." takes stuff from hyper chest at "..core.pos_to_string(pos))
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		core.log("action", player:get_player_name().." moves stuff inside hyper chest at "..core.pos_to_string(pos))
	end,
	on_blast = function() end,
})

-- Mailbox

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
		"default_chest_top.png", "default_chest_top.png",
		"default_chest_side.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_lock.png",
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
			core.show_formspec(clicker:get_player_name(),"default:chest_locked", get_mailbox_insert_form(pos))
		end
	end,
	on_blast = function() end,
})