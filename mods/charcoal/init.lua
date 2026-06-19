local S = core.get_translator("charcoal")

core.register_craftitem("charcoal:charcoal", {
    description = S("Charcoal"),
    inventory_image = "default_coal_lump.png",
})

core.register_node("charcoal:charcoalblock", {
	description = S("Charcoal Block"),
	tiles = {"default_coal_block.png"},
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})

core.register_craft({
	output = "charcoal:charcoalblock",
	recipe = {
		{"charcoal:charcoal", "charcoal:charcoal", "charcoal:charcoal"},
		{"charcoal:charcoal", "charcoal:charcoal", "charcoal:charcoal"},
		{"charcoal:charcoal", "charcoal:charcoal", "charcoal:charcoal"},
	}
})

core.register_craft({
	output = "charcoal:charcoal 9",
	recipe = {
		{"charcoal:charcoalblock"},
	}
})

core.register_craft({
	type = "fuel",
	recipe = "charcoal:charcoalblock",
	burntime = 375,
})

core.register_craft({
	type = "cooking",
	output = "charcoal:charcoal",
	recipe = "group:tree",
})

core.register_craft({
	type = "fuel",
	recipe = "charcoal:charcoal",
	burntime = 40,
})

print ("[MOD] Charcoal loaded")
