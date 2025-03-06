core.register_craftitem("charcoal:charcoal", {
    description = "Charcoal",
    inventory_image = "default_coal_lump.png",
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

print ("[MOD] Charcoal [521] loaded")