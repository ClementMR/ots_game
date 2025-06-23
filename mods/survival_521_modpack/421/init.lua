local MP = core.get_modpath(core.get_current_modname())

-- Override

core.override_item("default:tinblock", {
    sounds = default.node_sound_stone_defaults(),
})

--  Minerals recipes

core.register_craft({
	output = "flowers:waterlily",
	recipe = {
		{"default:grass_1", "default:grass_1", ""},
		{"default:grass_1", "default:grass_1", ""},
		{"", "", ""}
	}
})

core.register_craft({
	output = "default:stone_with_coal",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:coal_lump",
	}
})

core.register_craft({
	output = "default:stone_with_iron",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:iron_lump",
	}
})

core.register_craft({
	output = "default:stone_with_tin",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:tin_lump",
	}
})

core.register_craft({
	output = "default:stone_with_copper",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:copper_lump",
	}
})

core.register_craft({
	output = "default:stone_with_gold",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:gold_lump",
	}
})

core.register_craft({
	output = "default:stone_with_mese",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:mese_crystal",
	}
})

core.register_craft({
	output = "default:stone_with_diamond",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:diamond",
	}
})

core.register_craft({
	output = "moreores:mineral_mithril",
	type = "shapeless",
	recipe = {
		"default:stone",
		"moreores:mithril_lump",
	}
})

core.register_craft({
	output = "moreores:mineral_silver",
	type = "shapeless",
	recipe = {
		"default:stone",
		"moreores:silver_lump",
	}
})

core.register_craft({
	output = "quartz:quartz_ore",
	type = "shapeless",
	recipe = {
		"default:stone",
		"quartz:quartz_crystal",
	}
})

core.hud_replace_builtin("breath", {
	type = "statbar",
	position = {x = 0.5, y = 1},
	text = "bubble.png",
	text2 = "bubble_gone.png",
	number = core.PLAYER_MAX_BREATH_DEFAULT * 2,
	item = core.PLAYER_MAX_BREATH_DEFAULT * 2,
	direction = 0,
	size = {x = 24, y = 24},
	offset = {x = 25, y= -120},
})

dofile(MP .. "/expire.lua")
dofile(MP .. "/chatcommands.lua")

print ("[MOD] 421 loaded")