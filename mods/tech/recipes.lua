core.register_craft({
	output = "tech:advanced_combination",
	recipe = {
		{"tech:advanced_component", "tech:basic_combination", "tech:advanced_component"},
		{"tech:basic_combination", "tech:advanced_component", "tech:basic_combination"},
		{"tech:advanced_component", "tech:basic_combination", "tech:advanced_component"}
	}
})

core.register_craft({
	output = "tech:advanced_component",
	recipe = {
		{"moreores:silver_ingot", "default:diamond", "moreores:silver_ingot"},
		{"default:mese_crystal", "tech:basic_component", "default:mese_crystal"},
		{"tech:basic_component", "tech:basic_component", "tech:basic_component"}
	}
})

core.register_craft({
	output = "tech:basic_combination",
	recipe = {
		{"tech:basic_component", "", "tech:basic_component"},
		{"", "tech:basic_component", ""},
		{"tech:basic_component", "", "tech:basic_component"}
	}
})

core.register_craft({
	output = "tech:basic_component",
	recipe = {
		{"default:mese_crystal_fragment", "default:gold_ingot", "default:mese_crystal_fragment"},
		{"default:steel_ingot", "default:obsidian_shard", "default:steel_ingot"},
		{"default:bronze_ingot", "default:obsidian_shard", "default:bronze_ingot"}
	}
})

core.register_craft({
	output = "tech:blank_locator",
	recipe = {
		{"", "tech:advanced_component", ""},
		{"tech:basic_component", "moreores:silver_ingot", "tech:basic_component"},
		{"tech:basic_component", "tech:basic_component", "tech:basic_component"}
	}
})

core.register_craft({
	output = "tech:core",
	recipe = {
		{"tech:advanced_combination", "", "tech:advanced_combination"},
		{"tech:advanced_combination", "moreores:mithril_ingot", "tech:advanced_combination"},
		{"tech:advanced_combination", "default:mese", "tech:advanced_combination"}
	}
})

core.register_craft({
	output = "tech:teleporter",
	recipe = {
		{"tech:advanced_component", "moreores:mithril_block", "tech:advanced_component"},
		{"tech:basic_combination", "tech:core", "tech:basic_combination"},
		{"default:mese_crystal", "tech:advanced_combination", "default:mese_crystal"}
	}
})

core.register_craft({
	output = "tech:source 8",
	recipe = {
		{"default:mese_crystal_fragment","default:gold_ingot", "default:mese_crystal_fragment"}
	}
})