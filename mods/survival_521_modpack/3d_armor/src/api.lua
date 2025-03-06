local transparent_armor = false

local S = core.get_translator(core.get_current_modname())
local F = core.formspec_escape

local armor_def = setmetatable({}, {
	__index = function()
		return setmetatable({
			groups = setmetatable({}, {
				__index = function()
					return 0
				end})
			}, {
			__index = function()
				return 0
			end
		})
	end,
})

local armor_textures = setmetatable({}, {
	__index = function()
		return setmetatable({}, {
			__index = function()
				return "blank.png"
			end
		})
	end
})

armor = {
	timer = 0,
	elements = {"head", "torso", "legs", "feet", "shield"},
	physics = {"jump", "speed", "gravity"},
	attributes = {"fire", "water", "feather"},
	def = armor_def,
	textures = armor_textures,
	default_skin = "character",
	materials = {
		wood = "group:wood",
		cactus = "default:cactus",
		steel = "default:steel_ingot",
		bronze = "default:bronze_ingot",
		diamond = "default:diamond",
		gold = "default:gold_ingot",
		mithril = "moreores:mithril_ingot",
	},
	registered_groups = {["fleshy"]=100},
	registered_callbacks = {
		on_update = {},
		on_equip = {},
		on_unequip = {},
		on_damage = {},
		on_destroy = {},
	},
	migrate_old_inventory = true
}

armor.config = {
	init_delay = 1,
	update_time = 1,
	level_multiplier = 1,
	set_elements = "head torso legs feet shield",
	set_multiplier = 1.1
}

armor.register_armor = function(self, name, def)
	def.on_secondary_use = function(itemstack, player)
		return armor:equip(player, itemstack)
	end
	def.on_place = function(itemstack, player, pointed_thing)
		if pointed_thing.type == "node" and player and not player:get_player_control().sneak then
			local node = core.get_node(pointed_thing.under)
			local ndef = core.registered_nodes[node.name]
			if ndef and ndef.on_rightclick then
				return ndef.on_rightclick(pointed_thing.under, node, player, itemstack, pointed_thing)
			end
		end
		return armor:equip(player, itemstack)
	end

	-- The below is a very basic check to try and see if a material name exists as part
	-- of the item name. However this check is very simple and just checks theres "_something"
	-- at the end of the item name and logging an error to debug if not.
	local check_mat_exists = string.match(name, "%:.+_(.+)$")
	if check_mat_exists == nil then
		core.log("warning:[3d_armor] Registered armor "..name..
		" does not have \"_material\" specified at the end of the item registration name")
	end

	core.register_tool(name, def)
end

armor.register_armor_group = function(self, group, base)
	base = base or 100
	self.registered_groups[group] = base
end

armor.register_on_update = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_update, func)
	end
end

armor.register_on_equip = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_equip, func)
	end
end

armor.register_on_unequip = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_unequip, func)
	end
end

armor.register_on_damage = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_damage, func)
	end
end

armor.register_on_destroy = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_destroy, func)
	end
end

armor.run_callbacks = function(self, callback, player, index, stack)
	if stack then
		local def = stack:get_definition() or {}
		if type(def[callback]) == "function" then
			def[callback](player, index, stack)
		end
	end

	local callbacks = self.registered_callbacks[callback]
	if callbacks then
		for _, func in pairs(callbacks) do
			func(player, index, stack)
		end
	end
end

armor.update_player_visuals = function(self, player)
	if not player then
		return
	end

	local name = player:get_player_name()
	if self.textures[name] then
		player_api.set_textures(player, {
			self.textures[name].skin,
			self.textures[name].armor,
			self.textures[name].wielditem,
		})
	end

	self:run_callbacks("on_update", player)
end

armor.set_player_armor = function(self, player)
	local name, armor_inv = self:get_valid_player(player, "[set_player_armor]")
	if not name then
		return
	end

	local state = 0
	local count = 0
	local texture = "blank.png"
	local physics = {}
	local attributes = {}
	local levels = {}
	local groups = {}
	local change = {}
	local set_worn = {}
	local armor_multi = 0
	local worn_armor = armor:get_weared_armor_elements(player)
	for _, phys in pairs(self.physics) do
		physics[phys] = 1
	end

	for _, attr in pairs(self.attributes) do
		attributes[attr] = 0
	end

	for group, _ in pairs(self.registered_groups) do
		change[group] = 1
		levels[group] = 0
	end

	local list = armor_inv:get_list("armor")
	if type(list) ~= "table" then
		return
	end

	for i, stack in pairs(list) do
		if stack:get_count() == 1 then
			local def = stack:get_definition()
			for _, element in pairs(self.elements) do
				if def.groups["armor_"..element] then
					if def.armor_groups then
						for group, level in pairs(def.armor_groups) do
							if levels[group] then
								levels[group] = levels[group] + level
							end
						end
					else
						local level = def.groups["armor_"..element]
						levels["fleshy"] = levels["fleshy"] + level
					end
					break
				end
			end
			local item = stack:get_name()
			local tex = def.texture or item:gsub("%:", "_")
			tex = tex:gsub(".png$", "")

			if not transparent_armor then
				texture = texture.."^"..tex..".png"
			end

			state = state + stack:get_wear()
			count = count + 1

			for _, phys in pairs(self.physics) do
				local value = def.groups["physics_"..phys] or 0
				physics[phys] = physics[phys] + value
			end

			for _, attr in pairs(self.attributes) do
				local value = def.groups["armor_"..attr] or 0
				attributes[attr] = attributes[attr] + value
			end
		end
	end

	-- The following code compares player worn armor items against requirements
	-- of which armor pieces are needed to be worn to meet set bonus requirements
	for loc,item in pairs(worn_armor) do
		local item_mat = string.match(item, "%:.+_(.+)$")
		local worn_key = item_mat or "unknown"

		-- Perform location checks to ensure the armor is worn correctly
		for k,set_loc in pairs(armor.config.set_elements)do
			if set_loc == loc then
				if set_worn[worn_key] == nil then
					set_worn[worn_key] = 0
					set_worn[worn_key] = set_worn[worn_key] + 1
				else
					set_worn[worn_key] = set_worn[worn_key] + 1
				end
			end
		end
	end

	-- Apply the armor multiplier only if the player is wearing a full set of armor
	for mat_name,arm_piece_num in pairs(set_worn) do
		if arm_piece_num == #armor.config.set_elements then
			armor_multi = armor.config.set_multiplier
		end
	end

	for group, level in pairs(levels) do
		if level > 0 then
			level = level * armor.config.level_multiplier
			if armor_multi ~= 0 then
				level = level * armor.config.set_multiplier
			end
		end
		local base = self.registered_groups[group]
		self.def[name].groups[group] = level
		if level > base then
			level = base
		end
		groups[group] = base - level
		change[group] = groups[group] / base
	end

	for _, phys in pairs(self.physics) do
		self.def[name][phys] = physics[phys]
	end

	-- Preserve immortal group (damage disabled for player)
	local player_groups = player:get_armor_groups()
	local immortal = player_groups.immortal
	if immortal and immortal ~= 0 then
		groups.immortal = 1
	end
	-- Preserve fall_damage_add_percent group (fall damage modifier)
	groups.fall_damage_add_percent = player_groups.fall_damage_add_percent
	player:set_armor_groups(groups)

	local player_physics_locked = player:get_meta():get_int("player_physics_locked")
	if player_physics_locked == nil or player_physics_locked == 0 then
		player:set_physics_override(physics)
	end

	self.textures[name].armor = texture
	self.def[name].level = self.def[name].groups.fleshy or 0
	self.def[name].state = state
	self.def[name].count = count
	self:update_player_visuals(player)
end

armor.punch = function(self, player, hitter, time_from_last_punch, tool_capabilities)
	local name, armor_inv = self:get_valid_player(player, "[punch]")
	if not name then
		return
	end

	local set_state
	local set_count
	local state = 0
	local count = 0
	local recip = true
	local default_groups = {cracky=3, snappy=3, choppy=3, crumbly=3, level=1}
	local list = armor_inv:get_list("armor")
	for i, stack in pairs(list) do
		if stack:get_count() == 1 then
			local itemname = stack:get_name()
			local use = core.get_item_group(itemname, "armor_use") or 0
			local damage = use > 0
			local def = stack:get_definition() or {}
			if type(def.on_punched) == "function" then
				damage = def.on_punched(player, hitter, time_from_last_punch,
					tool_capabilities) ~= false and damage == true
			end
			if damage == true and tool_capabilities then
				local damage_groups = def.damage_groups or default_groups
				local level = damage_groups.level or 0
				local groupcaps = tool_capabilities.groupcaps or {}
				local uses = 0
				damage = false
				if next(groupcaps) == nil then
					damage = true
				end
				for group, caps in pairs(groupcaps) do
					local maxlevel = caps.maxlevel or 0
					local diff = maxlevel - level
					if diff == 0 then
						diff = 1
					end
					if diff > 0 and caps.times then
						local group_level = damage_groups[group]
						if group_level then
							local time = caps.times[group_level]
							if time then
								local dt = time_from_last_punch or 0
								if dt > time / diff then
									if caps.uses then
										uses = caps.uses * math.pow(3, diff)
									end
									damage = true
									break
								end
							end
						end
					end
				end
				if damage == true and recip == true and hitter and
						def.reciprocate_damage == true and uses > 0 then
					local item = hitter:get_wielded_item()
					if item and item:get_name() ~= "" then
						item:add_wear(65535 / uses)
						hitter:set_wielded_item(item)
					end
					-- reciprocate tool damage only once
					recip = false
				end
			end
			if damage == true and hitter == "fire" then
				damage = core.get_item_group(itemname, "flammable") > 0
			end
			if damage == true then
				self:damage(player, i, stack, use)
				set_state = self.def[name].state
				set_count = self.def[name].count
			end
			state = state + stack:get_wear()
			count = count + 1
		end
	end
	if set_count and set_count ~= count then
		state = set_state or state
		count = set_count or count
	end
	self.def[name].state = state
	self.def[name].count = count
end

armor.damage = function(self, player, index, stack, use)
	local old_stack = ItemStack(stack)
	local worn_armor = armor:get_weared_armor_elements(player)

	if not worn_armor then
		return
	end

	local armor_worn_cnt = 0
	for k,v in pairs(worn_armor) do
		armor_worn_cnt = armor_worn_cnt + 1
	end

	use = math.ceil(use/armor_worn_cnt)
	stack:add_wear(use)
	self:run_callbacks("on_damage", player, index, stack)
	self:set_inventory_stack(player, index, stack)

	if stack:get_count() == 0 then
		self:run_callbacks("on_unequip", player, index, old_stack)
		self:run_callbacks("on_destroy", player, index, old_stack)
		self:set_player_armor(player)
	end
end

armor.get_weared_armor_elements = function(self, player)
    local name, inv = self:get_valid_player(player, "[get_weared_armor]")
	local weared_armor = {}
	if not name then
		return
	end

    for i=1, inv:get_size("armor") do
        local item_name = inv:get_stack("armor", i):get_name()
        local element = self:get_element(item_name)
        if element ~= nil then
            weared_armor[element] = item_name
        end
	end

	return weared_armor
end

armor.equip = function(self, player, itemstack)
    local name, armor_inv = self:get_valid_player(player, "[equip]")
    local armor_element = self:get_element(itemstack:get_name())
    if name and armor_element then
        local valid_index = {head = 1, torso = 2, legs = 3, feet = 4, shield = 5}
        local index = valid_index[armor_element]

        if not index then
            return itemstack
        end

        local current_stack = armor_inv:get_stack("armor", index)
        if not current_stack:is_empty() then
            if core.get_item_group(current_stack:get_name(), "cursed") ~= 0 then
                return itemstack
            end
            self:unequip(player, armor_element)
        end

        local stack = itemstack:take_item()
        armor_inv:set_stack("armor", index, stack)
        self:run_callbacks("on_equip", player, index, stack)
        self:set_player_armor(player)
        self:save_armor_inventory(player)

		-- sfinv support
		if core.get_modpath("sfinv") then
			sfinv.set_page(player, "sfinv:crafting")
		end
    end

    return itemstack
end

armor.unequip = function(self, player, armor_element)
    local name, armor_inv = self:get_valid_player(player, "[unequip]")
	if not name then
		return
	end

	for i=1, armor_inv:get_size("armor") do
		local stack = armor_inv:get_stack("armor", i)
		if self:get_element(stack:get_name()) == armor_element then
			armor_inv:set_stack("armor", i, "")
			core.after(0, function()
				-- resolve player object again in async function
				player = core.get_player_by_name(name)
				local inv = player:get_inventory()
				if inv:room_for_item("main", stack) then
					inv:add_item("main", stack)
				else
					core.add_item(player:get_pos(), stack)
				end
			end)
			self:run_callbacks("on_unequip", player, i, stack)
			self:set_player_armor(player)
			self:save_armor_inventory(player)
			return
		end
	end
end

armor.remove_all = function(self, player)
    local name, inv = self:get_valid_player(player, "[remove_all]")
	if not name then
		return
    end

	inv:set_list("armor", {})
	self:set_player_armor(player)
	self:save_armor_inventory(player)
end

armor.get_element = function(self, item_name)
	for _, element in pairs(armor.elements) do
		if core.get_item_group(item_name, "armor_"..element) > 0 then
			return element
		end
	end
end

armor.serialize_inventory_list = function(self, list)
	local list_table = {}
	for _, stack in ipairs(list) do
		table.insert(list_table, stack:to_string())
	end
	return core.serialize(list_table)
end

armor.deserialize_inventory_list = function(self, list_string)
	local list_table = core.deserialize(list_string)
	local list = {}
	for _, stack in ipairs(list_table or {}) do
		table.insert(list, ItemStack(stack))
	end
	return list
end

armor.load_armor_inventory = function(self, player)
	local _, inv = self:get_valid_player(player, "[load_armor_inventory]")
	if inv then
		local meta = player:get_meta()
		local armor_list_string = meta:get_string("3d_armor_inventory")
		if armor_list_string then
			inv:set_list("armor", self:deserialize_inventory_list(armor_list_string))
			return true
		end
	end
end

armor.save_armor_inventory = function(self, player)
	local _, inv = self:get_valid_player(player, "[save_armor_inventory]")
	if inv then
		local meta = player:get_meta()
		meta:set_string("3d_armor_inventory", self:serialize_inventory_list(inv:get_list("armor")))
	end
end

armor.set_inventory_stack = function(self, player, i, stack)
	local _, inv = self:get_valid_player(player, "[set_inventory_stack]")
	if inv then
		inv:set_stack("armor", i, stack)
		self:save_armor_inventory(player)
	end
end

armor.get_valid_player = function(self, player, msg)
	msg = msg or ""
	if not player then
		core.log("warning", ("3d_armor%s: Player reference is nil"):format(msg))
		return
	end

	if type(player) ~= "userdata" then
		-- Fake player, fail silently
		return
	end

	local name = player:get_player_name()
	if not name then
		core.log("warning", ("3d_armor%s: Player name is nil"):format(msg))
		return
	end

	local inv = core.get_inventory({type="detached", name=name.."_armor"})
	if not inv then
		-- This check may fail when called inside `on_joinplayer`
		-- in that case, the armor will be initialized/updated later on
		core.log("warning", ("3d_armor%s: Detached armor inventory is nil"):format(msg))
		return
	end

	return name, inv
end

armor.drop_armor = function(pos, stack)
	local node = core.get_node_or_nil(pos)
	if node then
		local obj = core.add_item(pos, stack)
		if obj then
			obj:set_velocity({x=math.random(-1, 1), y=5, z=math.random(-1, 1)})
		end
	end
end

armor.get_armor_formspec = function(self, name)
    local armor_slots = {"helmet", "chestplate", "leggings", "boots", "shield"}
    local armor_bg = ""

    local player = core.get_player_by_name(name)
    local inv = player:get_inventory()

	local index = 1
    for l = 1, 3 do
		for c = 0, 1 do
			if armor_slots[index] then
				armor_bg = armor_bg ..
					"image["..c..","..(l-0.5)..";1,1;3d_armor_inv_"..armor_slots[index].."_steel.png]"
				index=index+1
			end
		end
    end

    local form = "list[detached:"..name.."_armor;armor;0,0.5;2,3;]"..
        default.gui_slots..
        armor_bg

    return form
end

armor.show_formspec = function(self, name)
	local player = core.get_player_by_name(name)
	local form = "size[8,9.1]".."list[current_player;main;0,5.2;8,1;]"..
		"image[0,5.2;1,1;gui_hb_bg.png]"..
		"image[1,5.2;1,1;gui_hb_bg.png]"..
		"image[2,5.2;1,1;gui_hb_bg.png]"..
		"image[3,5.2;1,1;gui_hb_bg.png]"..
		"image[4,5.2;1,1;gui_hb_bg.png]"..
		"image[5,5.2;1,1;gui_hb_bg.png]"..
		"image[6,5.2;1,1;gui_hb_bg.png]"..
		"image[7,5.2;1,1;gui_hb_bg.png]"..
		"list[current_player;main;0,6.35;8,3;8]"..
		"list[current_player;craft;3,1;3,3;]"..
		"list[current_player;craftpreview;7,2;1,1;]"..
		"listring[current_player;craft]"..
		"listring[current_player;main]"

	form = form..armor:get_armor_formspec(name)

	core.show_formspec(name, "3d_armor:cmd", form)
end