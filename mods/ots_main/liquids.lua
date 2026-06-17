local SOURCE = "ots_main:viscous_source"
local FLOWING = "ots_main:viscous_flowing"
local texture_mod = "^[colorize:#4E245F:145^[opacity:210"
local source_texture = "default_water_source_animated.png" .. texture_mod
local flowing_texture = "default_water_flowing_animated.png" .. texture_mod

core.register_node(SOURCE, {
	description = "Viscous Liquid Source",
	drawtype = "liquid",
	waving = 1,
	tiles = {{
		name = source_texture,
		backface_culling = false,
		animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 4.0},
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
	liquid_range = 2,
	liquid_renewable = false,
	post_effect_color = {a = 170, r = 58, g = 20, b = 72},
	groups = {liquid = 3, viscous_liquid = 1, cools_lava = 1},
	sounds = default.node_sound_water_defaults(),
})

core.register_node(FLOWING, {
	description = "Flowing Viscous Liquid",
	drawtype = "flowingliquid",
	waving = 1,
	tiles = {"default_water.png" .. texture_mod},
	special_tiles = {
		{
			name = flowing_texture,
			backface_culling = false,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0},
		},
		{
			name = flowing_texture,
			backface_culling = true,
			animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0},
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
	liquid_range = 2,
	liquid_renewable = false,
	post_effect_color = {a = 170, r = 58, g = 20, b = 72},
	groups = {liquid = 3, viscous_liquid = 1, not_in_creative_inventory = 1, cools_lava = 1},
	sounds = default.node_sound_water_defaults(),
})

if bucket then
	bucket.register_liquid(
		SOURCE,
		FLOWING,
		"ots_main:bucket_viscous",
		"bucket.png^(default_water.png" .. texture_mod .. ")",
		"Viscous Liquid Bucket"
	)
end

if core.settings:get_bool("ots_main_viscous_lakes", true) then
	core.register_ore({
		ore_type = "blob",
		ore = SOURCE,
		wherein = {"default:stone", "default:desert_stone", "default:sandstone", "default:dirt"},
		clust_scarcity = 36 * 36 * 36,
		clust_size = 5,
		y_min = -96,
		y_max = 16,
		noise_threshold = 0.55,
		noise_params = {
			offset = 0,
			scale = 1,
			spread = {x = 32, y = 16, z = 32},
			seed = 91247,
			octaves = 3,
			persist = 0.45,
		},
	})
end