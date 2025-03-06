local function mapfix(minp, maxp)
	local vm = core.get_voxel_manip(minp, maxp)
	vm:update_liquids()
	vm:write_to_map()
	vm:update_map()
	local emin, emax = vm:get_emerged_area()
	print(core.pos_to_string(emin), core.pos_to_string(emax))
end

local previous = os.time()
local delay = 60

core.register_chatcommand("mapfix", {
	description = "Recalculate the flowing liquids and the light of a chunk",
	func = function(name)
		local pos = vector.round(core.get_player_by_name(name):getpos())
		local size = 20

		if size >= 121 then
			return false, "Radius is too big"
		end

		local time = os.time()

		if time - previous < delay then
			return false, "Wait at least " .. delay .. " seconds from the previous \"/mapfix\"."
		end

		previous = time

		core.log("action",
        name .. " uses mapfix at " .. core.pos_to_string(vector.round(pos)) .. " with radius " .. size)

        -- When passed to get_voxel_manip, positions are rounded up, to a multiple of 16 nodes in each direction.
        -- By subtracting 8 it's rounded to the nearest chunk border. max is used to avoid negative radius.
		size = math.max(math.floor(size - 8), 0)

		local minp = vector.subtract(pos, size)
		local maxp = vector.add(pos, size)

		mapfix(minp, maxp)

		core.chat_send_all("Mapfix requested by "..name.." done!")

		return true, "Done."
	end,
})

print ("[MOD] Gfix [521] loaded")