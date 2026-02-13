local world_path = core.get_worldpath()

areas.config = {}

areas.config.filename = world_path .. "/areas.dat"

areas.config.use_smallest_area_precedence = core.settings:get_bool("areas.use_smallest_area_precedence") or false
areas.config.self_protection = core.settings:get_bool("areas.self_protection") or false
areas.config.self_protection_privilege = core.settings:get("areas.self_protection_privilege") or "interact"
areas.config.tick = core.settings:get("areas.tick") or 0.5
areas.config.legacy_table = core.settings:get_bool("areas.legacy_table") or false

-- Self protection (normal)
areas.config.self_protection_max_size = core.settings:get_pos("areas.self_protection_max_size") or {x=64,y=128,z=64}
areas.config.self_protection_max_areas = core.settings:get("areas.self_protection_max_areas") or 4

-- Self protection (high)
areas.config.self_protection_max_size_high = core.settings:get_pos("areas.self_protection_max_size_high")or
	{x=512, y=512, z=512}
areas.config.self_protection_max_areas_high = core.settings:get("areas.self_protection_max_areas_high") or 32

--[[
local function setting(name, tp, default)
	local full_name = "areas." .. name
	local value
	if tp == "bool" then
		value = core.settings:get_bool(full_name)
		default = value == nil and core.is_yes(default)
	elseif tp == "string" then
		value = core.settings:get(full_name)
	elseif tp == "v3f" then
		value = core.setting_get_pos(full_name)
		default = value == nil and core.string_to_pos(default)
	elseif tp == "float" or tp == "int" then
		value = tonumber(core.settings:get(full_name))
		local v, other = default:match("^(%S+) (.+)")
		default = value == nil and tonumber(other and v or default)
	else
		error("Cannot parse setting type " .. tp)
	end

	if value == nil then
		value = default
		print(full_name .. " " .. dump(value))
		assert(default ~= nil, "Cannot parse default for " .. full_name)
	end
	--print("add", name, default, value)
	areas.config[name] = value
end

local file = io.open(areas.modpath .. "/settingtypes.txt", "r")
for line in file:lines() do
	local name, tp, value = line:match("^areas%.(%S+) %(.*%) (%S+) (.*)")
	if value then
		setting(name, tp, value)
	end
end
file:close()

--------------
-- Settings --
--------------

setting("filename", "string", world_path.."/areas.dat")
]]