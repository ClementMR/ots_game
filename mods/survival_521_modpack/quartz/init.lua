local S = core.get_translator("quartz")

--
--  Item Registration
--

--  Quartz Crystal
core.register_craftitem("quartz:quartz_crystal", {
	description = S("Quartz Crystal"),
	inventory_image = "quartz_crystal_full.png",
})

--
-- Node Registration
--

--  Ore
core.register_node("quartz:quartz_ore", {
	description = S("Quartz Ore"),
	tiles = {"default_stone.png^quartz_ore.png"},
	groups = {cracky=3, stone=1},
	drop = 'quartz:quartz_crystal',
	sounds = default.node_sound_stone_defaults(),
})

core.register_ore({
	ore_type = "scatter",
	ore = "quartz:quartz_ore",
	wherein = "default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 6,
	clust_size = 5,
	y_min = -31000,
	y_max = -5,
})

-- Quartz Block
core.register_node("quartz:block", {
	description = S("Quartz Block"),
	tiles = {"quartz_block.png"},
	groups = {cracky=3, oddly_breakable_by_hand=1},
	sounds = default.node_sound_glass_defaults(),
})

-- Chiseled Quartz
core.register_node("quartz:chiseled", {
	description = S("Chiseled Quartz"),
	tiles = {"quartz_chiseled.png"},
	groups = {cracky=3, oddly_breakable_by_hand=1},
	sounds = default.node_sound_glass_defaults(),
})

-- Quartz Pillar
core.register_node("quartz:pillar", {
	description = S("Quartz Pillar"),
	paramtype2 = "facedir",
	tiles = {"quartz_pillar_top.png", "quartz_pillar_top.png",
		"quartz_pillar_side.png"},
	groups = {cracky=3, oddly_breakable_by_hand=1},
	sounds = default.node_sound_glass_defaults(),
	on_place = core.rotate_node
})

-- Stairs & Slabs
stairs.register_stair_and_slab("quartzblock", "quartz:block",
		{cracky=3, oddly_breakable_by_hand=1},
		{"quartz_block.png"},
		S("Quartz Stair"),
		S("Quartz Slab"),
		default.node_sound_glass_defaults(),
		nil,
		S("Inner Quartz Stair"),
		S("Outer Quartz Stair")
	)

stairs.register_stair_and_slab("quartzstair", "quartz:pillar",
		{cracky=3, oddly_breakable_by_hand=1},
		{"quartz_pillar_top.png", "quartz_pillar_top.png",
			"quartz_pillar_side.png"},
		S("Quartz Pillar Stair"),
		S("Quartz Pillar Slab"),
		default.node_sound_glass_defaults(),
		nil,
		S("Inner Quartz Pillar Stair"),
		S("Outer Quartz Pillar Stair")
	)

--
-- Crafting
--

-- Quartz Block
core.register_craft({
	output = '"quartz:block" 4',
	recipe = {
		{'quartz:quartz_crystal', 'quartz:quartz_crystal', ''},
		{'quartz:quartz_crystal', 'quartz:quartz_crystal', ''},
		{'', '', ''}
	}
})

-- Chiseled Quartz
core.register_craft({
	output = 'quartz:chiseled 4',
	recipe = {
		{'quartz:block', 'quartz:block', ''},
		{'quartz:block', 'quartz:block', ''},
		{'',             '',             ''},
	}
})

-- Quartz Pillar
core.register_craft({
	output = 'quartz:pillar 2',
	recipe = {
		{'quartz:block', '', ''},
		{'quartz:block', '', ''},
		{'', '', ''},
	}
})

print ("[MOD] Quartz [521] loaded")