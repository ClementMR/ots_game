if not core.settings:get_bool("enable_damage") then
	core.log("warning", "[stamina] Stamina will not load if damage is disabled (enable_damage=false)")
	return
end

stamina = {}
local modname = core.get_current_modname()
local armor_mod = core.get_modpath("3d_armor") and core.global_exists("armor") and armor.def

function stamina.log(level, message, ...)
	return core.log(level, ("[%s] %s"):format(modname, message:format(...)))
end

local function get_setting(key, default)
	local value = core.settings:get("stamina." .. key)
	local num_value = tonumber(value)
	if value and not num_value then
		stamina.log("warning", "Invalid value for setting %s: %q. Using default %q.", key, value, default)
	end
	return num_value or default
end

stamina.settings = {
	-- see settingtypes.txt for descriptions
	tick = get_setting("tick", 800),
	tick_min = get_setting("tick_min", 4),
	health_tick = get_setting("health_tick", 4),
	move_tick = get_setting("move_tick", 0.5),
	exhaust_dig = get_setting("exhaust_dig", 2),
	exhaust_place = get_setting("exhaust_place", 1),
	exhaust_move = get_setting("exhaust_move", 1.5),
	exhaust_jump = get_setting("exhaust_jump", 3),
	exhaust_punch = get_setting("exhaust_punch", 25),
	exhaust_lvl = get_setting("exhaust_lvl", 160),
	heal = get_setting("heal", 1),
	heal_lvl = get_setting("heal_lvl", 5),
	starve = get_setting("starve", 1),
	starve_lvl = get_setting("starve_lvl", 3),
	visual_max = get_setting("visual_max", 20),
}

local settings = stamina.settings

local attribute = {
	saturation = "stamina:level",
	exhaustion = "stamina:exhaustion",
}

local function is_player(player)
	return (
		core.is_player(player) and
		not player.is_fake_player
	)
end

local function set_player_attribute(player, key, value)
	local meta = player:get_meta()
	if value == nil then
		meta:set_string(key, "")
	else
		meta:set_string(key, tostring(value))
	end
end

local function get_player_attribute(player, key)
	local meta = player:get_meta()
	return meta:get_string(key)
end

local hud_ids_by_player_name = {}

local function get_hud_id(player)
	return hud_ids_by_player_name[player:get_player_name()]
end

local function set_hud_id(player, hud_id)
	hud_ids_by_player_name[player:get_player_name()] = hud_id
end

--- SATURATION API ---
function stamina.get_saturation(player)
	return tonumber(get_player_attribute(player, attribute.saturation))
end

function stamina.set_saturation(player, level)
	set_player_attribute(player, attribute.saturation, level)
	player:hud_change(
		get_hud_id(player),
		"number",
		math.min(settings.visual_max, level)
	)
end

stamina.registered_on_update_saturations = {}
function stamina.register_on_update_saturation(fun)
	table.insert(stamina.registered_on_update_saturations, fun)
end

function stamina.update_saturation(player, level)
	for _, callback in ipairs(stamina.registered_on_update_saturations) do
		local result = callback(player, level)
		if result then
			return result
		end
	end

	local old = stamina.get_saturation(player)

	if level == old then -- To suppress HUD update
		return
	end

	-- players without interact priv cannot eat
	if old < settings.heal_lvl and not core.check_player_privs(player, {interact=true}) then
		return
	end

	stamina.set_saturation(player, level)
end

function stamina.change_saturation(player, change)
	if not is_player(player) or not change or change == 0 then
		return false
	end
	local level = stamina.get_saturation(player) + change
	level = math.max(level, 0)
	level = math.min(level, settings.visual_max)
	stamina.update_saturation(player, level)
	return true
end

stamina.change = stamina.change_saturation -- for backwards compatablity

--- END POISON API ---
--- EXHAUSTION API ---
stamina.exhaustion_reasons = {
	dig = "dig",
	heal = "heal",
	jump = "jump",
	move = "move",
	place = "place",
	punch = "punch",
}

function stamina.get_exhaustion(player)
	return tonumber(get_player_attribute(player, attribute.exhaustion))
end

function stamina.set_exhaustion(player, exhaustion)
	set_player_attribute(player, attribute.exhaustion, exhaustion)
end

stamina.registered_on_exhaust_players = {}
function stamina.register_on_exhaust_player(fun)
	table.insert(stamina.registered_on_exhaust_players, fun)
end

function stamina.exhaust_player(player, change, cause)
	for _, callback in ipairs(stamina.registered_on_exhaust_players) do
		local result = callback(player, change, cause)
		if result then
			return result
		end
	end

	if not is_player(player) then
		return
	end

	local exhaustion = stamina.get_exhaustion(player) or 0

	exhaustion = exhaustion + change

	if exhaustion >= settings.exhaust_lvl then
		exhaustion = exhaustion - settings.exhaust_lvl
		stamina.change_saturation(player, -1)
	end

	stamina.set_exhaustion(player, exhaustion)
end
--- END EXHAUSTION API ---

-- Time based stamina functions
local function move_tick()
	for _,player in ipairs(core.get_connected_players()) do
		local controls = player:get_player_control()
		local is_moving = controls.up or controls.down or controls.left or controls.right
		local velocity = player:get_velocity()
		velocity.y = 0
		local horizontal_speed = vector.length(velocity)
		local has_velocity = horizontal_speed > 0.05

		if controls.jump then
			stamina.exhaust_player(player, settings.exhaust_jump, stamina.exhaustion_reasons.jump)
		elseif is_moving and has_velocity then
			stamina.exhaust_player(player, settings.exhaust_move, stamina.exhaustion_reasons.move)
		end
	end
end

local function stamina_tick()
	-- lower saturation by 1 point after settings.tick second(s)
	for _,player in ipairs(core.get_connected_players()) do
		local saturation = stamina.get_saturation(player)
		if saturation > settings.tick_min then
			stamina.update_saturation(player, saturation - 1)
		end
	end
end

local function health_tick()
	-- heal or damage player, depending on saturation
	for _,player in ipairs(core.get_connected_players()) do
		local air = player:get_breath() or 0
		local hp = player:get_hp()
		local hp_max = player:get_properties().hp_max
		local saturation = stamina.get_saturation(player)

		-- don't heal if dead, drowning, or poisoned
		local should_heal = (
			saturation >= settings.heal_lvl and
			hp < hp_max and
			hp > 0 and
			air > 0
		)
		-- or damage player by 1 hp if saturation is < 2 (of 30)
		local is_starving = (
			saturation < settings.starve_lvl and
			hp > 0
		)

		if should_heal then
			player:set_hp(hp + settings.heal, {type = "set_hp", cause = "stamina:heal"})
			stamina.exhaust_player(player, settings.exhaust_lvl, stamina.exhaustion_reasons.heal)
		elseif is_starving then
			player:set_hp(hp - settings.starve, {type = "set_hp", cause = "stamina:starve"})
		end
	end
end

local stamina_timer = 0
local health_timer = 0
local action_timer = 0

local function stamina_globaltimer(dtime)
	stamina_timer = stamina_timer + dtime
	health_timer = health_timer + dtime
	action_timer = action_timer + dtime

	if action_timer > settings.move_tick then
		action_timer = 0
		move_tick()
	end

	if stamina_timer > settings.tick then
		stamina_timer = 0
		stamina_tick()
	end

	if health_timer > settings.health_tick then
		health_timer = 0
		health_tick()
	end
end

-- override core.do_item_eat() so we can redirect hp_change to stamina
stamina.core_item_eat = core.do_item_eat
function core.do_item_eat(hp_change, replace_with_item, itemstack, player, pointed_thing)
	for _, callback in ipairs(core.registered_on_item_eats) do
		local result = callback(hp_change, replace_with_item, itemstack, player, pointed_thing)
		if result then
			return result
		end
	end

	if not is_player(player) or not itemstack then
		return itemstack
	end

	local level = stamina.get_saturation(player) or 0
	if level >= settings.visual_max and hp_change > 0 then
		-- don't eat if player is full and item provides saturation
		return itemstack
	end

	local itemname = itemstack:get_name()
	if replace_with_item then
		stamina.log("action", "%s eats %s for %s stamina, replace with %s",
			player:get_player_name(), itemname, hp_change, replace_with_item)
	else
		stamina.log("action", "%s eats %s for %s stamina",
			player:get_player_name(), itemname, hp_change)
	end

	if hp_change > 0 then
		stamina.change_saturation(player, hp_change)
		stamina.set_exhaustion(player, 0)
	end

	itemstack:take_item()
	player:set_wielded_item(itemstack)
	replace_with_item = ItemStack(replace_with_item)
	if not replace_with_item:is_empty() then
		local inv = player:get_inventory()
		replace_with_item = inv:add_item("main", replace_with_item)
		if not replace_with_item:is_empty() then
			local pos = player:get_pos()
			pos.y = math.floor(pos.y - 1.0)
			core.add_item(pos, replace_with_item)
		end
	end

	return nil -- don't overwrite wield item a second time
end

core.register_on_joinplayer(function(player)
	local level = stamina.get_saturation(player) or settings.visual_max
	local id = player:hud_add({
		name = "stamina",
		type = "statbar",
		position = {x = 0.5, y = 1},
		size = {x = 24, y = 24},
		text = "stamina_hud_fg.png",
		number = level,
		item = settings.visual_max,
		alignment = {x = -1, y = -1},
		offset = {x = 25, y = -90},
		max = 0,
	})

	set_hud_id(player, id)
	stamina.set_saturation(player, level)
	-- remove legacy hud_id from player metadata
	set_player_attribute(player, "stamina:hud_id", nil)
end)

core.register_on_leaveplayer(function(player)
	set_hud_id(player, nil)
end)

core.register_globalstep(stamina_globaltimer)

core.register_on_placenode(function(pos, oldnode, player, ext)
	stamina.exhaust_player(player, settings.exhaust_place, stamina.exhaustion_reasons.place)
end)
core.register_on_dignode(function(pos, oldnode, player, ext)
	stamina.exhaust_player(player, settings.exhaust_dig, stamina.exhaustion_reasons.dig)
end)
core.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	stamina.exhaust_player(hitter, settings.exhaust_punch, stamina.exhaustion_reasons.punch)
end)
core.register_on_respawnplayer(function(player)
	stamina.update_saturation(player, settings.visual_max)
end)

print ("[MOD] Stamina [521] loaded")