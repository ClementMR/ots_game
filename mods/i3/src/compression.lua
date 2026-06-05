IMPORT("fmt", "copy", "insert")

local wood_types = {
	"acacia_wood", "aspen_wood", "junglewood", "pine_wood",
}

local material_tools = {
	"bronze", "diamond", "mese", "stone", "wood",
}

local armor_materials = {
	"wood", "cactus", "bronze", "diamond", "gold",
}

local material_stairs = {
	"acacia_wood", "aspen_wood", "brick", "bronzeblock", "cobble", "copperblock",
	"desert_cobble", "desert_sandstone", "desert_sandstone_block", "desert_sandstone_brick",
	"desert_stone", "desert_stone_block", "desert_stonebrick",
	"glass", "goldblock", "ice", "junglewood", "mossycobble", "obsidian",
	"obsidian_block", "obsidian_glass", "obsidianbrick", "pine_wood",
	"sandstone", "sandstone_block", "sandstonebrick",
	"silver_sandstone", "silver_sandstone_block", "silver_sandstone_brick",
	"snowblock", "steelblock", "stone", "stone_block", "stonebrick",
	"straw", "tinblock",
}

local colors = {
	"black", "blue", "brown", "cyan", "dark_green", "dark_grey", "green",
	"grey", "magenta", "orange", "pink", "red", "violet", "yellow",
}

local stained_glass_colors = copy(colors)
insert(stained_glass_colors, "white")

local to_compress = {
	["default:wood"] = {
		replace = "wood",
		by = wood_types,
	},

	["default:fence_wood"] = {
		replace = "wood",
		by = wood_types,
	},

	["default:fence_rail_wood"] = {
		replace = "wood",
		by = wood_types,
	},

	["default:mese_post_light"] = {
		replace = "mese_post_light",
		by = {
			"mese_post_light_acacia_wood",
			"mese_post_light_aspen_wood",
			"mese_post_light_junglewood",
			"mese_post_light_pine_wood",
		}
	},

	["doors:gate_wood_closed"] = {
		replace = "wood",
		by = wood_types,
	},

	["wool:white"] = {
		replace = "white",
		by = colors
	},

	["dye:white"] = {
		replace = "white",
		by = colors
	},

	["default:axe_steel"] = {
		replace = "steel",
		by = material_tools
	},

	["default:pick_steel"] = {
		replace = "steel",
		by = material_tools
	},

	["default:shovel_steel"] = {
		replace = "steel",
		by = material_tools
	},

	["default:sword_steel"] = {
		replace = "steel",
		by = material_tools
	},

	["farming:hoe_steel"] = {
		replace = "steel",
		by = material_tools
	},

	["default:glass"] = {
		replace = "default:glass",
		by = {"default:obsidian_glass"},
	},

	["stairs:slab_wood"] = {
		replace = "wood",
		by = material_stairs
	},

	["stairs:stair_wood"] = {
		replace = "wood",
		by = material_stairs
	},

	["stairs:stair_inner_wood"] = {
		replace = "wood",
		by = material_stairs
	},

	["stairs:stair_outer_wood"] = {
		replace = "wood",
		by = material_stairs
	},

	["walls:cobble"] = {
		replace = "cobble",
		by = {"desertcobble", "mossycobble"}
	},
}

if core.get_modpath("moreores") then
	local moreores_materials = {"silver", "mithril"}

	for _, tool in ipairs({"axe", "pick", "shovel", "sword"}) do
		local extras = to_compress["default:" .. tool .. "_steel"].extra or {}
		to_compress["default:" .. tool .. "_steel"].extra = extras

		for _, material in ipairs(moreores_materials) do
			insert(extras, "moreores:" .. tool .. "_" .. material)
		end
	end

	local hoe_extras = to_compress["farming:hoe_steel"].extra or {}
	to_compress["farming:hoe_steel"].extra = hoe_extras

	for _, material in ipairs(moreores_materials) do
		insert(hoe_extras, "moreores:hoe_" .. material)
	end

	insert(armor_materials, "mithril")
end

if core.get_modpath("ethereal") then
	insert(armor_materials, "crystal")
end

if core.get_modpath("nether") then
	insert(armor_materials, "nether")
end

if core.get_modpath("3d_armor") then
	to_compress["3d_armor:helmet_steel"] = {
		replace = "steel",
		by = armor_materials,
	}

	to_compress["3d_armor:chestplate_steel"] = {
		replace = "steel",
		by = armor_materials,
	}

	to_compress["3d_armor:leggings_steel"] = {
		replace = "steel",
		by = armor_materials,
	}

	to_compress["3d_armor:boots_steel"] = {
		replace = "steel",
		by = armor_materials,
	}

	to_compress["shields:shield_steel"] = {
		replace = "steel",
		by = armor_materials,
		extra = {
			"shields:shield_enhanced_wood",
			"shields:shield_enhanced_cactus",
		},
	}
end

if core.get_modpath("stainedglass") then
	for _, color in ipairs(stained_glass_colors) do
		insert(to_compress["default:glass"].by, "stainedglass:stained_glass_" .. color)
	end
end

if core.get_modpath("xpanes") then
	local pane_types = {"xpanes:obsidian_pane_flat"}

	if core.get_modpath("stainedglass") then
		for _, color in ipairs(stained_glass_colors) do
			insert(pane_types, "xpanes:pane_" .. color .. "_flat")
		end
	end

	to_compress["xpanes:pane_flat"] = {
		replace = "xpanes:pane_flat",
		by = pane_types,
	}
end

local circular_saw_names = {
	{"micro", "_1"},
	{"panel", "_1"},
	{"micro", "_2"},
	{"panel", "_2"},
	{"micro", "_4"},
	{"panel", "_4"},
	{"micro", ""},
	{"panel", ""},

	{"micro", "_12"},
	{"panel", "_12"},
	{"micro", "_14"},
	{"panel", "_14"},
	{"micro", "_15"},
	{"panel", "_15"},
	{"stair", "_outer"},
	{"stair", ""},

	{"stair", "_inner"},
	{"slab", "_1"},
	{"slab", "_2"},
	{"slab", "_quarter"},
	{"slab", ""},
	{"slab", "_three_quarter"},
	{"slab", "_14"},
	{"slab", "_15"},

	{"slab", "_two_sides"},
	{"slab", "_three_sides"},
	{"slab", "_three_sides_u"},
	{"stair", "_half"},
	{"stair", "_alt_1"},
	{"stair", "_alt_2"},
	{"stair", "_alt_4"},
	{"stair", "_alt"},
	{"stair", "_right_half"},

	{"slope", ""},
	{"slope", "_half"},
	{"slope", "_half_raised"},
	{"slope", "_inner"},
	{"slope", "_inner_half"},
	{"slope", "_inner_half_raised"},
	{"slope", "_inner_cut"},
	{"slope", "_inner_cut_half"},

	{"slope", "_inner_cut_half_raised"},
	{"slope", "_outer"},
	{"slope", "_outer_half"},
	{"slope", "_outer_half_raised"},
	{"slope", "_outer_cut"},
	{"slope", "_outer_cut_half"},
	{"slope", "_outer_cut_half_raised"},
	{"slope", "_cut"},
}

local moreblocks_nodes = {
	"coal_stone",
	"wood_tile",
	"iron_checker",
	"circle_stone_bricks",
	"cobble_compressed",
	"plankstone",
	"clean_glass",
	"split_stone_tile",
	"all_faces_tree",
	"dirt_compressed",
	"coal_checker",
	"clean_glow_glass",
	"tar",
	"clean_super_glow_glass",
	"stone_tile",
	"cactus_brick",
	"super_glow_glass",
	"desert_cobble_compressed",
	"copperpatina",
	"coal_stone_bricks",
	"glow_glass",
	"cactus_checker",
	"all_faces_pine_tree",
	"all_faces_aspen_tree",
	"all_faces_acacia_tree",
	"all_faces_jungle_tree",
	"iron_stone",
	"grey_bricks",
	"wood_tile_left",
	"wood_tile_down",
	"wood_tile_center",
	"wood_tile_right",
	"wood_tile_full",
	"checker_stone_tile",
	"iron_glass",
	"iron_stone_bricks",
	"wood_tile_flipped",
	"wood_tile_offset",
	"coal_glass",

	"straw",

	"stone",
	"stone_block",
	"cobble",
	"mossycobble",
	"brick",
	"sandstone",
	"steelblock",
	"goldblock",
	"copperblock",
	"bronzeblock",
	"diamondblock",
	"tinblock",
	"desert_stone",
	"desert_stone_block",
	"desert_cobble",
	"meselamp",
	"glass",
	"tree",
	"wood",
	"jungletree",
	"junglewood",
	"pine_tree",
	"pine_wood",
	"acacia_tree",
	"acacia_wood",
	"aspen_tree",
	"aspen_wood",
	"obsidian",
	"obsidian_block",
	"obsidianbrick",
	"obsidian_glass",
	"stonebrick",
	"desert_stonebrick",
	"sandstonebrick",
	"silver_sandstone",
	"silver_sandstone_brick",
	"silver_sandstone_block",
	"desert_sandstone",
	"desert_sandstone_brick",
	"desert_sandstone_block",
	"sandstone_block",
	"coral_skeleton",
	"ice",
}

local colors_moreblocks = copy(colors)
insert(colors_moreblocks, "white")

local moreblocks_mods = {
	wool = colors_moreblocks,
	moreblocks = moreblocks_nodes,
}

local t = {}

for mod, v in pairs(moreblocks_mods) do
for _, nodename in ipairs(v) do
	t[nodename] = {}

	for _, shape in ipairs(circular_saw_names) do
		if shape[1] ~= "slope" or shape[2] ~= "" then
			insert(t[nodename], fmt("%s_%s%s", shape[1], nodename, shape[2]))
		end
	end

	local slope_name = fmt("slope_%s", nodename)

	to_compress[fmt("%s:%s", mod, slope_name)] = {
		replace = slope_name,
		by = t[nodename],
	}
end
end

local compressed = {}

for k, v in pairs(to_compress) do
	compressed[k] = compressed[k] or {}

	for _, str in ipairs(v.by) do
		local it = k:gsub(v.replace, str)
		insert(compressed[k], it)
	end

	for _, it in ipairs(v.extra or {}) do
		insert(compressed[k], it)
	end
end

local _compressed = {}

for _, v in pairs(compressed) do
for _, v2 in ipairs(v) do
	_compressed[v2] = true
end
end

i3.compress_groups, i3.compressed = compressed, _compressed
