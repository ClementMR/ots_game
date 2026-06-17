ots_settings = rawget(_G, "ots_settings") or {}

local FORMNAME = "ots_settings:settings"
local META_PREFIX = "ots_settings:"
local registered = {}
local order = {}

local function player_name(player_or_name)
	if type(player_or_name) == "string" then
		return player_or_name
	end
	return player_or_name and player_or_name:get_player_name()
end

local function get_meta(player_or_name)
	local name = player_name(player_or_name)
	local player = name and core.get_player_by_name(name)
	return player and player:get_meta()
end

local function clamp(value, min_value, max_value)
	value = tonumber(value) or min_value
	if value < min_value then
		return min_value
	end
	if value > max_value then
		return max_value
	end
	return value
end

local function normalize_number(value, def)
	local min_value = def.min or 0
	local max_value = def.max or 100
	value = clamp(value, min_value, max_value)
	local step = def.step or 1
	if step > 0 then
		value = math.floor((value / step) + 0.5) * step
	end
	return clamp(value, min_value, max_value)
end

local function scrollbar_to_value(raw, def)
	local pos = tonumber((raw or ""):match("%-?%d+$")) or 0
	pos = clamp(pos, 0, 1000)
	local min_value = def.min or 0
	local max_value = def.max or 100
	return normalize_number(min_value + ((max_value - min_value) * pos / 1000), def)
end

local function value_to_scrollbar(value, def)
	local min_value = def.min or 0
	local max_value = def.max or 100
	if max_value == min_value then
		return 0
	end
	return math.floor(((value - min_value) / (max_value - min_value)) * 1000 + 0.5)
end

function ots_settings.register(key, def)
	if type(key) ~= "string" or key == "" then
		error("ots_settings.register: key must be a non-empty string")
	end
	if registered[key] then
		error("ots_settings.register: setting already registered: " .. key)
	end

	def = table.copy(def or {})
	def.type = def.type or "boolean"
	if def.type == "scrollbar" then
		def.type = "number"
	end
	if def.type ~= "boolean" and def.type ~= "number" then
		error("ots_settings.register: unsupported type for " .. key)
	end
	def.label = def.label or key
	registered[key] = def
	table.insert(order, key)
end

function ots_settings.get(player_or_name, key)
	local def = registered[key]
	if not def then
		return nil
	end

	local meta = get_meta(player_or_name)
	if not meta then
		return def.default
	end

	local meta_key = META_PREFIX .. key
	if def.type == "boolean" then
		local stored = meta:get_string(meta_key)
		if stored == "" then
			return def.default == true
		end
		return stored == "true"
	end

	local stored = meta:get_string(meta_key)
	if stored == "" then
		return normalize_number(def.default or def.min or 0, def)
	end
	return normalize_number(stored, def)
end

function ots_settings.set(player_or_name, key, value)
	local def = registered[key]
	local meta = get_meta(player_or_name)
	if not def or not meta then
		return false
	end

	if def.type == "boolean" then
		value = value == true or value == "true" or value == "1"
		meta:set_string(META_PREFIX .. key, value and "true" or "false")
	else
		value = normalize_number(value, def)
		meta:set_string(META_PREFIX .. key, tostring(value))
	end

	if def.on_change then
		local name = player_name(player_or_name)
		local player = name and core.get_player_by_name(name)
		def.on_change(player, value)
	end
	return true
end

function ots_settings.get_registered()
	return registered, order
end

local function make_formspec(player)
	local fs = {
		"formspec_version[6]",
		"size[8,7]",
		"position[0.5,0.5]",
		"label[0.35,0.35;Player settings]",
		"button_exit[6.45,6.25;1.2,0.45;save;Save]",
	}

	local y = 1
	if #order == 0 then
		table.insert(fs, "label[0.35,1;No settings available]")
		return table.concat(fs, "")
	end

	for index, key in ipairs(order) do
		local def = registered[key]
		local label = core.formspec_escape(def.label)
		if def.type == "boolean" then
			table.insert(fs, ("checkbox[0.35,%f;ots_bool_%d;%s;%s]"):format(
				y, index, label, tostring(ots_settings.get(player, key))))
			y = y + 0.55
		else
			local value = ots_settings.get(player, key)
			table.insert(fs, ("label[0.35,%f;%s: %s]"):format(y, label, core.formspec_escape(tostring(value))))
			table.insert(fs, ("scrollbar[0.35,%f;7,0.35;horizontal;ots_num_%d;%u]"):format(
				y + 0.32, index, value_to_scrollbar(value, def)))
			y = y + 0.95
		end
	end

	return table.concat(fs, "")
end

function ots_settings.show(player_or_name)
	local name = player_name(player_or_name)
	local player = name and core.get_player_by_name(name)
	if not player then
		return false
	end
	core.show_formspec(name, FORMNAME, make_formspec(player))
	return true
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	for index, key in ipairs(order) do
		local def = registered[key]
		local bool_field = fields["ots_bool_" .. index]
		local num_field = fields["ots_num_" .. index]
		if def.type == "boolean" and bool_field ~= nil then
			ots_settings.set(player, key, bool_field == "true")
		elseif def.type == "number" and num_field ~= nil then
			ots_settings.set(player, key, scrollbar_to_value(num_field, def))
		end
	end
end)

core.register_chatcommand("settings", {
	description = "Open player settings",
	func = function(name)
		ots_settings.show(name)
	end,
})