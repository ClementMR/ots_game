local S = core.get_translator("ots_main")

local SOURCE = "ots_main:viscous_source"
local FLOWING = "ots_main:viscous_flowing"

core.register_node(SOURCE, {
	description = S("Viscous Liquid Source"),
	drawtype = "liquid",
	waving = 2,
	tiles = {{
		name = "ots_viscous_source_animated.png",
		backface_culling = false,
		animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 8.0},
	}},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = FLOWING,
	liquid_alternative_source = SOURCE,
	liquid_viscosity = 7,
	liquid_range = 3,
	liquid_renewable = false,
	move_resistance = 6,
	post_effect_color = {a = 185, r = 36, g = 120, b = 42},
	groups = {liquid = 3, viscous_liquid = 1, cools_lava = 1},
	sounds = default.node_sound_water_defaults(),
})

core.register_node(FLOWING, {
	description = S("Flowing Viscous Liquid"),
	drawtype = "flowingliquid",
	waving = 2,
	tiles = {"ots_viscous.png"},
	special_tiles = {
		{
			name = "ots_viscous_flowing_animated.png",
			backface_culling = false,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 4.0},
		},
		{
			name = "ots_viscous_flowing_animated.png",
			backface_culling = true,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 4.0},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = FLOWING,
	liquid_alternative_source = SOURCE,
	liquid_viscosity = 7,
	liquid_range = 3,
	liquid_renewable = false,
	move_resistance = 6,
	post_effect_color = {a = 185, r = 36, g = 120, b = 42},
	groups = {liquid = 3, viscous_liquid = 1, not_in_creative_inventory = 1, cools_lava = 1},
	sounds = default.node_sound_water_defaults(),
})

if bucket then
	bucket.register_liquid(
		SOURCE,
		FLOWING,
		":bucket:bucket_viscous",
		"bucket.png^ots_viscous_bucket_overlay.png",
		S("Viscous Liquid Bucket")
	)

	core.register_craft({
		type = "shapeless",
		output = "bucket:bucket_viscous",
		recipe = {
			"bucket:bucket_water",
			"default:cactus",
		},
		replacements = {
			{"bucket:bucket_water", "bucket:bucket_empty"},
		},
	})
end

local function is_viscous_liquid(node_name)
	return core.get_item_group(node_name, "viscous_liquid") > 0
end

local function player_in_viscous_liquid(player)
	local pos = player:get_pos()
	if not pos then
		return false
	end

	local checks = {
		{x = pos.x, y = pos.y + 0.1, z = pos.z},
		{x = pos.x, y = pos.y + 0.9, z = pos.z},
		{x = pos.x, y = pos.y - 0.2, z = pos.z},
	}
	for _, check_pos in ipairs(checks) do
		if is_viscous_liquid(core.get_node(check_pos).name) then
			return true
		end
	end
	return false
end

core.register_on_player_hpchange(function(player, hp_change, reason)
	if hp_change >= 0 or not reason or reason.type ~= "fall" then
		return hp_change
	end
	if not player_in_viscous_liquid(player) then
		return hp_change
	end

	local reduced = math.floor((-hp_change * 0.25) + 0.5)
	if reduced <= 1 then
		return 0
	end
	return -reduced
end, true)