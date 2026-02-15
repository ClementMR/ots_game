protector = {
	-- Settings
	max_shares = 12,
	radius = tonumber(core.settings:get("protector_radius")) or 5,
	protector_flip = core.settings:get_bool("protector_flip") or false,
	protector_hurt = tonumber(core.settings:get("protector_hurt")) or 0
}

-- Radius limiter (core cannot handle node volume of more than 4096000)
if protector.radius > 30 then protector.radius = 30 end

-- Localize math
local math_floor, math_pi = math.floor, math.pi

local F = core.formspec_escape
local S = core.get_translator("pex")
local prefix = core.colorize("#E8A320", S("[Protectors]"))

-- Return list of members as a table
local function get_member_list(meta)
	return meta:get_string("members"):split(" ")
end

-- Write member list table in protector meta as string
local function set_member_list(meta, list)
	meta:set_string("members", table.concat(list, " "))
end

-- Check for owner name
local function is_owner(meta, name)
	return name == meta:get_string("owner")
end

-- Check for member name
local function is_member(meta, name)
	for _, n in pairs(get_member_list(meta)) do
		if n == name then
			return true
		end
	end
	return false
end

-- Add player name to table as member
local function add_member(meta, name)
	-- Validate player name for MT compliance
	if name ~= string.match(name, "[%w_-]+") then
		return
	end
	if name:len() > 25 then
		return
	end
	-- Does name already exist?
	if is_owner(meta, name) or is_member(meta, name) then
		return
	end

	local list = get_member_list(meta)
	if #list >= protector.max_shares then
		return
	end

	table.insert(list, name)
	set_member_list(meta, list)
end

-- Remove player name from table
local function del_member(meta, name)
	local list = get_member_list(meta)
	for i, n in pairs(list) do
		if n == name then
			table.remove(list, i)
			break
		end
	end
	set_member_list(meta, list)
end

-- Protector interface
local function protector_formspec(meta)
	local formspec = {
		"size[8,7]",
		default.gui_bg,
		default.gui_bg_img,
		"label[2.5,0;" .. S("-- Protector interface --") .. "]",
		"label[0,2;" .. S("Members:") .. "]",
		"button_exit[2.5,6.2;3,0.5;close_me;" .. S("Close") .. "]",
		"field_close_on_enter[protector_add_member;false]"
	}
	local members = get_member_list(meta)
	local i = 0
	for n = 1, #members do
		if i < protector.max_shares then
			table.insert(formspec,
			"button[" .. (i % 4 * 2) .. "," .. math_floor(i / 4 + 3) .. ";1.5,.5;protector_member;" .. F(members[n]) .. "]"..
			"button[" .. (i % 4 * 2 + 1.25) .. "," .. math_floor(i / 4 + 3) ..
			";.75,.5;protector_del_member_" .. F(members[n]) .. ";X]")
		end
		i = i + 1
	end
	if i < protector.max_shares then
		table.insert(formspec,
		"field[" .. (i % 4 * 2 + 1 / 3) .. "," .. (math_floor(i / 4 + 3) + 1 / 3) .. ";1.433,.5;protector_add_member;;]" ..
		"button[" .. (i % 4 * 2 + 1.25) .. "," .. math_floor(i / 4 + 3) .. ";.75,.5;protector_submit;+]")
	end
	return table.concat(formspec, "")
end

function protector.can_dig(r, pos, digger, onlyowner, infolevel)
	if not digger or not pos then
		return false
	end

	-- Protector_bypass privileged users can override protection
	if infolevel == 1 and core.check_player_privs(digger, {protection_bypass = true}) then
		return true
	end

	-- Find the protector nodes
	local selected_pos = pos
	pos = core.find_nodes_in_area(
		{x = pos.x - r, y = pos.y - r, z = pos.z - r},
		{x = pos.x + r, y = pos.y + r, z = pos.z + r},
		{"pex:protector", "pex:protector2"})

	local meta, owner, members
	for n = 1, #pos do
		meta = core.get_meta(pos[n])
		owner = meta:get_string("owner") or ""
		members = meta:get_string("members") or ""
		if infolevel == 1 and owner ~= digger then -- Node change and digger isn't owner
			-- And you aren't on the member list
			if onlyowner or not is_member(meta, digger) then
				core.chat_send_player(digger,
				prefix .. " " .. S("@1 is protected using protectors by @2", core.pos_to_string(selected_pos), owner))
				return false
			end
		end
		-- When using protector as tool, show protector information
		if infolevel == 2 then
			core.chat_send_player(digger,
			prefix .. " " .. S("@1 is protected using protectors by @2", core.pos_to_string(selected_pos), owner))
			core.chat_send_player(digger, prefix .. " " .. S("Protection located at @1", core.pos_to_string(pos[n])))
			if members ~= "" then
				core.chat_send_player(digger, prefix .. " " .. S("Members: @1", members))
			end
			return false
		end
	end

	-- Show when you can build on unprotected area
	if infolevel == 2 then
		if #pos < 1 then
			core.chat_send_player(digger, prefix .. " " .. S("This area is not protected"))
		end
		core.chat_send_player(digger, prefix .. " " .. S("You can build here"))
	end

	return true
end

-- Add protector hurt and flip to protection violation function
core.register_on_protection_violation(function(pos, name)
	local player = core.get_player_by_name(name)
	if player and player:is_player() then
		-- Hurt player if protection violated
		if protector.protector_hurt > 0 and player:get_hp() > 0 then
			-- This delay fixes item duplication bug (thanks luk3yx)
			core.after(0.1, function()
				player:set_hp(player:get_hp() - protector.protector_hurt)
			end, player)
		end
		-- Flip player when protection violated
		if protector.protector_flip then
			local yaw = player:get_look_horizontal() + math_pi -- yaw + 180°
			if yaw > 2 * math_pi then
				yaw = yaw - 2 * math_pi
			end

			player:set_look_horizontal(yaw)
			player:set_look_vertical(-player:get_look_vertical()) -- invert pitch

			local player_pos = player:get_pos() -- If digging below player, move up to avoid falling through hole
			if pos.y < player_pos.y then
				player:set_pos({x = player_pos.x, y = player_pos.y + 0.8, z = player_pos.z})
			end
		end
	end
end)

-- Backup old is_protected function
local old_is_protected = core.is_protected

-- Check for protected area, return true if protected and digger isn't on list
function core.is_protected(pos, digger)
	digger = digger or ""
	if not protector.can_dig(protector.radius, pos, digger, false, 1) then
		return true
	end
	return old_is_protected(pos, digger)
end

-- Make sure protection block doesn't overlap another protector's area
local function check_overlap(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end
	local pos = pointed_thing.above
	local name = placer:get_player_name()
	if not protector.can_dig(protector.radius * 2, pos, name, true, 1) then
		core.chat_send_player(name, prefix .. " " .. S("Overlaps into above players protected area"))
		return itemstack
	end
	return core.item_place(itemstack, placer, pointed_thing)
end

-- Temporary position store
local player_pos = {}

-- Stone texture
local stone_tex = "default_stone.png"
if core.get_modpath("nc_terrain") then
	stone_tex = "nc_terrain_stone.png"
end

-- Protector default
local def = {
	description = S("Protection Block"),
	tiles = {
		stone_tex .. "^protector_overlay.png",
		stone_tex .. "^protector_overlay.png",
		stone_tex .. "^protector_overlay.png^protector_logo.png"
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.499 ,-0.499, -0.499, 0.499, 0.499, 0.499}
		}
	},
	sounds = default.node_sound_stone_defaults(),
	groups = {dig_immediate = 2, unbreakable = 1},
	is_ground_content = false,
	paramtype = "light",
	light_source = 4,
	walkable = true,
	on_place = check_overlap,
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		meta:set_string("infotext", "Protection")
	end,
	after_place_node = function(pos, placer)
		local meta = core.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
		meta:set_string("members", "")
		meta:set_string("infotext", S("Protection (owned by @1)", meta:get_string("owner")))
	end,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		protector.can_dig(protector.radius, pointed_thing.under, user:get_player_name(), false, 2)
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		local meta = core.get_meta(pos)
		local name = clicker:get_player_name()
		if meta and protector.can_dig(1, pos, name, true, 1) then
			player_pos[name] = pos
			core.show_formspec(name, "protector:node", protector_formspec(meta))
		end
	end,
	can_dig = function(pos, player)
		return player and protector.can_dig(1, pos, player:get_player_name(), true, 1)
	end,
	on_blast = function() end,
}

-- Protection node
core.register_node("pex:protector", table.copy(def))

-- Protection logo
def.description = S("Protection Logo")
def.tiles = {"protector_logo.png"}
def.wield_image = "protector_logo.png"
def.inventory_image = "protector_logo.png"
def.use_texture_alpha = "clip"
def.paramtype2 = "wallmounted"
def.legacy_wallmounted = true
def.sunlight_propagates = true
def.walkable = false
def.node_box = {
	type = "wallmounted",
	wall_top = {-0.375, 0.4375, -0.5, 0.375, 0.5, 0.5},
	wall_bottom = {-0.375, -0.5, -0.5, 0.375, -0.4375, 0.5},
	wall_side = {-0.5, -0.5, -0.375, -0.4375, 0.5, 0.375}
}
def.selection_box = {type = "wallmounted"}

core.register_node("pex:protector2", table.copy(def))

-- Check formspec buttons or when name entered
core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "protector:node" then return end

	local name = player:get_player_name()
	local pos = player_pos[name]
	if not name or not pos then
		return
	end

	local add_member_input = fields.protector_add_member

	-- Reset formspec until close button pressed
	if (fields.close_me or fields.quit) and (not add_member_input or add_member_input == "") then
		player_pos[name] = nil
		return
	end

	-- Only owner can add names
	if not protector.can_dig(1, pos, player:get_player_name(), true, 1) then
		return
	end

	-- Are we adding member to a protection node ? (csm protection)
	local nod = core.get_node(pos).name
	if nod ~= "pex:protector" and nod ~= "pex:protector2" then
		player_pos[name] = nil
		return
	end

	local meta = core.get_meta(pos) ; if not meta then return end

	-- Add member [+]
	if add_member_input then
		for _, i in pairs(add_member_input:split(" ")) do
			add_member(meta, i)
		end
	end

	-- Remove member [x]
	for field, value in pairs(fields) do
		if string.sub(field, 0, string.len("protector_del_member_")) == "protector_del_member_" then
			del_member(meta, string.sub(field, string.len("protector_del_member_") + 1))
		end
	end

	core.show_formspec(name, formname, protector_formspec(meta))
end)