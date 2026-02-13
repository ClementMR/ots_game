-- Protectors

local item_stone = "default:stone"

core.register_craft({
	output = "pex:protector",
	recipe = {
		{item_stone, item_stone, item_stone},
		{item_stone, "default:steel_ingot", item_stone},
		{item_stone, item_stone, item_stone}
	}
})

core.register_craft({
	output = "pex:protector2",
	recipe = {
		{item_stone, item_stone, item_stone},
		{item_stone, "default:copper_ingot", item_stone},
		{item_stone, item_stone, item_stone}
	}
})

-- Chests

core.register_craft({
	output = "pex:chest",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "default:copper_ingot", "group:wood"},
		{"group:wood", "group:wood", "group:wood"}
	}
})

core.register_craft({
	output = "pex:chest",
	type = "shapeless",
	recipe = {
		"default:chest",
		"default:copper_ingot"
	}
})

core.register_craft({
	output = "pex:chest_hyper",
	recipe = {
		{"group:wood", "default:goldblock", "group:wood"},
		{"default:goldblock", "default:goldblock", "default:goldblock"},
		{"group:wood", "default:goldblock", "group:wood"}
	}
})

core.register_craft({
	output = "pex:mailbox",
	recipe = {
		{"group:wood", "group:wood", "default:steel_ingot"},
		{"default:paper", "default:paper", "default:paper"},
		{"group:wood", "group:wood", "group:wood"}
	}
})

-- Doors & Trapdoors

for _, recipe in ipairs({"default:copper_ingot", "default:tin_ingot"}) do

	core.register_craft({
		output = "pex:door_wood",
		recipe = {
			{"group:wood", "group:wood"},
			{"group:wood", recipe},
			{"group:wood", "group:wood"}
		}
	})

	core.register_craft({
		output = "pex:door_wood",
		type = "shapeless",
		recipe = {
			"doors:door_wood",
			recipe
		}
	})

	core.register_craft({
		output = "pex:door_steel",
		recipe = {
			{"default:steel_ingot", "default:steel_ingot"},
			{"default:steel_ingot", recipe},
			{"default:steel_ingot", "default:steel_ingot"}
		}
	})

	core.register_craft({
		output = "pex:door_steel",
		type = "shapeless",
		recipe = {
			"doors:door_steel",
			recipe
		}
	})

	core.register_craft({
		output = "pex:trapdoor 2",
		recipe = {
			{"group:wood", recipe, "group:wood"},
			{"group:wood", "group:wood", "group:wood"}
		}
	})

	core.register_craft({
		output = "pex:trapdoor",
		type = "shapeless",
		recipe = {
			"doors:trapdoor",
			recipe
		}
	})

	core.register_craft({
		output = "pex:trapdoor_steel",
		recipe = {
			{recipe, "default:steel_ingot"},
			{"default:steel_ingot", "default:steel_ingot"}
		}
	})

	core.register_craft({
		output = "pex:trapdoor_steel",
		type = "shapeless",
		recipe = {
			"doors:trapdoor_steel",
			recipe
		}
	})

end