local last_mapfix = {}
local cooldown = 60

local function mapfix(minp, maxp)
	local vm = core.get_voxel_manip(minp, maxp)
	vm:update_liquids()
	vm:write_to_map()
	vm:update_map()
	local emin, emax = vm:get_emerged_area()
	print(core.pos_to_string(emin), core.pos_to_string(emax))
end

core.register_chatcommand("mapfix", {
	description = "Recalculate the flowing liquids and the light of a chunk",
	func = function(name)
		local pos = vector.round(core.get_player_by_name(name):get_pos())
		local size = 30

        local current_time = os.time()
        local last_time = last_mapfix[name] or 0

        if current_time - last_time < cooldown then
            local remaining = math.ceil(cooldown - (current_time - last_time))
            return false, ("Please wait %d seconds before using %s again."):format(remaining, "/mapfix")
        end

        last_mapfix[name] = current_time

		core.log("action", name .. " uses mapfix at " .. core.pos_to_string(vector.round(pos)) .. " with radius " .. size)

        -- When passed to get_voxel_manip, positions are rounded up, to a multiple of 16 nodes in each direction.
        -- By subtracting 8 it's rounded to the nearest chunk border. max is used to avoid negative radius.
		size = math.max(math.floor(size - 8), 0)

		local minp = vector.subtract(pos, size)
		local maxp = vector.add(pos, size)

		mapfix(minp, maxp)

		core.chat_send_all(core.colorize("grey", ("[Mapfix] " .. name .. " has fixed the map with radius " .. size)))
	end,
})

print ("[MOD] Mapfix loaded")