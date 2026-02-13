--[[
=====================================================================
** More Ores **
By Calinou, with the help of Nore.

Copyright © 2011-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
=====================================================================
--]]

moreores = {}

local S = core.get_translator("moreores")
moreores.S = S

-- `frame` support
local use_frame = core.get_modpath("frame")

-- Returns the crafting recipe table for a given material and item.
local function get_recipe(material, item)
	if item == "sword" then
		return {
			{material},
			{material},
			{"group:stick"},
		}
	end
	if item == "shovel" then
		return {
			{material},
			{"group:stick"},
			{"group:stick"},
		}
	end
	if item == "axe" then
		return {
			{material, material},
			{material, "group:stick"},
			{"", "group:stick"},
		}
	end
	if item == "pick" then
		return {
			{material, material, material},
			{"", "group:stick", ""},
			{"", "group:stick", ""},
		}
	end
	if item == "block" then
		return {
			{material, material, material},
			{material, material, material},
			{material, material, material},
		}
	end
	if item == "lockedchest" then
		return {
			{"group:wood", "group:wood", "group:wood"},
			{"group:wood", material, "group:wood"},
			{"group:wood", "group:wood", "group:wood"},
		}
	end
end

local function add_ore(modname, description, mineral_name, oredef, extra_node_def)
	local img_base = modname .. "_" .. mineral_name
	local toolimg_base = modname .. "_tool_"..mineral_name
	local tool_base = modname .. ":"
	local tool_post = "_" .. mineral_name
	local item_base = tool_base .. mineral_name
	local ingot = item_base .. "_ingot"
	local lump_item = item_base .. "_lump"

	local function merge_tables(t1, t2)
	    for k, v in pairs(t2) do
	        if type(v) == "table" and type(t1[k]) == "table" then
	            -- If both t1[k] and v are tables, merge them recursively
	            merge_tables(t1[k], v)
	        else
	            -- Otherwise, simply set the value
	            t1[k] = v
	        end
	    end
	    return t1
	end

	if oredef.makes.ore then
        local node_def_tbl = {
            description = S("@1 Ore", S(description)),
            tiles = {"default_stone.png^" .. modname .. "_mineral_" .. mineral_name ..
						".png"},
            groups = {cracky = oredef.ore_cracky or 2, level = oredef.ore_level or 1},
            sounds = default.node_sound_stone_defaults(),
            drop = lump_item,
        }
		if extra_node_def then
			node_def_tbl = merge_tables(node_def_tbl, extra_node_def)
		end
        core.register_node(modname .. ":mineral_" .. mineral_name, node_def_tbl)

		if use_frame then
			frame.register(modname .. ":mineral_" .. mineral_name)
		end
	end

	if oredef.makes.block then
		local block_item = item_base .. "_block"
		core.register_node(block_item, {
			description = S("@1 Block", S(description)),
			tiles = {img_base .. "_block.png"},
			groups = {cracky = oredef.block_cracky or 2, level = oredef.block_level or 3},
			is_ground_content = false,
			sounds = default.node_sound_stone_defaults(),
		})
		core.register_alias(mineral_name.."_block", block_item)
		if oredef.makes.ingot then
			core.register_craft( {
				output = block_item,
				recipe = get_recipe(ingot, "block")
			})
			core.register_craft( {
				output = ingot .. " 9",
				recipe = {
					{block_item},
				}
			})
		end
		if use_frame then
			frame.register(block_item)
		end
	end

	if oredef.makes.lump then
		core.register_craftitem(lump_item, {
			description = S("@1 Lump", S(description)),
			inventory_image = img_base .. "_lump.png",
		})
		core.register_alias(mineral_name .. "_lump", lump_item)
		if oredef.makes.ingot then
			core.register_craft({
				type = "cooking",
				output = ingot,
				recipe = lump_item,
			})
		end
		if use_frame then
			frame.register(lump_item)
		end
	end

	if oredef.makes.ingot then
		core.register_craftitem(ingot, {
			description = S("@1 Ingot", S(description)),
			inventory_image = img_base .. "_ingot.png",
		})
		core.register_alias(mineral_name .. "_ingot", ingot)
		if use_frame then
			frame.register(ingot)
		end
	end

	if oredef.makes.chest then
		core.register_craft( {
			output = "default:chest_locked",
			recipe = {
				{ingot},
				{"default:chest"},
			}
		})

		core.register_craft( {
			output = "default:chest_locked",
			recipe = get_recipe(ingot, "lockedchest")
		})
	end

	oredef.oredef_high.ore_type = "scatter"
	oredef.oredef_high.ore = modname .. ":mineral_" .. mineral_name
	oredef.oredef_high.wherein = "default:stone"

	oredef.oredef.ore_type = "scatter"
	oredef.oredef.ore = modname .. ":mineral_" .. mineral_name
	oredef.oredef.wherein = "default:stone"

	oredef.oredef_deep.ore_type = "scatter"
	oredef.oredef_deep.ore = modname .. ":mineral_" .. mineral_name
	oredef.oredef_deep.wherein = "default:stone"

	core.register_ore(oredef.oredef_high)
	core.register_ore(oredef.oredef)
	core.register_ore(oredef.oredef_deep)

	for tool_name, tooldef in pairs(oredef.tools) do
		local tdef = {
			description = "",
			inventory_image = toolimg_base .. tool_name .. ".png",
			tool_capabilities = {
				max_drop_level = 3,
				groupcaps = tooldef.groupcaps,
				damage_groups = tooldef.damage_groups,
				full_punch_interval = oredef.full_punch_interval,
			},
			sound = {breaks = "default_tool_breaks"},
			groups = tooldef.groups,
		}

		if tool_name == "sword" then
			tdef.description = S("@1 Sword", S(description))
			if tdef.groups then
				tdef.groups = merge_tables(tdef.groups, {sword = 1})
			else
				tdef.groups = {sword = 1}
			end
		end

		if tool_name == "pick" then
			tdef.description = S("@1 Pickaxe", S(description))
			if tdef.groups then
				tdef.groups = merge_tables(tdef.groups, {pickaxe = 1, tool=1})
			else
				tdef.groups = {pickaxe = 1, tool=1}
			end
		end

		if tool_name == "axe" then
			tdef.description = S("@1 Axe", S(description))
			if tdef.groups then
				tdef.groups = merge_tables(tdef.groups, {axe = 1, tool=1})
			else
				tdef.groups = {axe = 1, tool=1}
			end
		end

		if tool_name == "shovel" then
			tdef.description = S("@1 Shovel", S(description))
			if tdef.groups then
				tdef.groups = merge_tables(tdef.groups, {shovel = 1, tool=1})
			else
				tdef.groups = {shovel = 1, tool=1}
			end
			tdef.wield_image = toolimg_base .. tool_name .. ".png^[transformR90"
		end

		local fulltool_name = tool_base .. tool_name .. tool_post

		if tool_name == "hoe" and core.get_modpath("farming") then
			tdef.max_uses = tooldef.max_uses
			tdef.material = ingot
			tdef.description = S("@1 Hoe", S(description))
			farming.register_hoe(fulltool_name, tdef)
		end

		-- Hoe registration is handled above.
		-- There are no crafting recipes for hoes, as they have been
		-- deprecated from core Game:
		-- https://github.com/core/core_game/commit/9c459e77a
		if tool_name ~= "hoe" then
			core.register_tool(fulltool_name, tdef)

			if oredef.makes.ingot then
				core.register_craft({
					output = fulltool_name,
					recipe = get_recipe(ingot, tool_name)
				})
			end
		end

		core.register_alias(tool_name .. tool_post, fulltool_name)
		if use_frame then
			frame.register(fulltool_name)
		end
	end
end

local oredefs = {
	silver = {
		description = "Silver",
		makes = {ore = true, block = true, lump = true, ingot = true, chest = true},
		ore_cracky = 3,
		ore_level = 2,
		block_cracky = 2,
		block_level = 2,
		oredef_high= {
			clust_scarcity = 12 * 12 * 12,
			clust_num_ores = 4,
			clust_size = 3,
			y_min = 1025,
			y_max = 31000,
		},
		oredef = {
			clust_scarcity = 14 * 14 *14,
			clust_num_ores = 2,
			clust_size = 3,
			y_min = -127,
			y_max = -64,
		},
		oredef_deep = {
			clust_scarcity = 12 * 12 * 12,
			clust_num_ores = 4,
			clust_size = 3,
			y_min = -31000,
			y_max = -128,
		},
		tools = {
			pick = {
				groupcaps = {
					cracky = {times = {[1] = 2.60, [2] = 1.00, [3] = 0.60}, uses = 50, maxlevel = 1},
				},
				damage_groups = {fleshy = 4},
			},
			hoe = {
				max_uses = 100,
			},
			shovel = {
				groupcaps = {
					crumbly = {times = {[1] = 1.10, [2] = 0.40, [3] = 0.25}, uses = 50, maxlevel = 1},
				},
				damage_groups = {fleshy = 3},
			},
			axe = {
				groupcaps = {
					choppy = {times = {[1] = 2.50, [2] = 0.80, [3] = 0.50}, uses = 50, maxlevel = 1},
					fleshy = {times = {[2] = 1.10, [3] = 0.60}, uses = 50, maxlevel = 1},
				},
				damage_groups = {fleshy = 5},
			},
			sword = {
				groupcaps = {
					fleshy = {times = {[2] = 0.70, [3] = 0.30}, uses = 50, maxlevel = 1},
					snappy = {times = {[1] = 1.70, [2] = 0.70, [3] = 0.30}, uses = 50, maxlevel = 1},
					choppy = {times = {[3] = 0.80}, uses = 50, maxlevel = 0},
				},
				damage_groups = {fleshy = 6},
			},
		},
		full_punch_interval = 1.0,
	},
	mithril = {
		description = "Mithril",
		makes = {ore = true, block = true, lump = true, ingot = true, chest = false},
		ore_cracky = 2,
		ore_level = 2,
		block_cracky = 1,
		block_level = 3,
		oredef_high = {
			clust_scarcity = 17 * 17 * 17,
			clust_num_ores = 1,
			clust_size = 3,
			y_min = 2049,
			y_max = 31000,
		},
		oredef = {
			clust_scarcity = 18 * 18 * 18,
			clust_num_ores = 1,
			clust_size = 3,
			y_min = -4095,
			y_max = -512,
		},
		oredef_deep = {
			clust_scarcity = 17 * 17 * 17,
			clust_num_ores = 1,
			clust_size = 3,
			y_min = -31000,
			y_max = -4096,
		},
		tools = {
			pick = {
				groupcaps = {
					cracky = {times = {[1] = 1.70, [2] = 0.90, [3] = 0.40}, uses = 200, maxlevel = 3},
				},
				damage_groups = {fleshy = 6},
			},
			hoe = {
				max_uses = 1000,
			},
			shovel = {
				groupcaps = {
					crumbly = {times = {[1] = 1.30, [2] = 0.50, [3] = 0.30}, uses = 200, maxlevel = 3},
				},
				damage_groups = {fleshy = 5},
			},
			axe = {
				groupcaps = {
					choppy = {times = {[1] = 1.90, [2] = 0.50, [3] = 0.30}, uses = 200, maxlevel = 3},
					fleshy = {times = {[2] = 1.10, [3] = 0.60}, uses = 200, maxlevel = 3},
				},
				damage_groups = {fleshy = 7},
			},
			sword = {
				groupcaps = {
					fleshy = {times = {[2] = 0.70, [3] = 0.30}, uses = 200, maxlevel = 3},
					snappy = {times = {[1] = 1.40, [2] = 0.60, [3] = 0.20}, uses = 200, maxlevel = 3},
					choppy = {times = {[3] = 0.70}, uses = 200, maxlevel = 0},
				},
				damage_groups = {fleshy = 9},
			},
		},
		full_punch_interval = 0.45,
	}
}

core.register_alias("moreores:mineral_tin", "default:stone_with_tin")
core.register_alias("moreores:tin_lump", "default:tin_lump")
core.register_alias("moreores:tin_ingot", "default:tin_ingot")
core.register_alias("moreores:tin_block", "default:tinblock")

for orename, def in pairs(oredefs) do
	-- Register everything
	add_ore("moreores", def.description, orename, def, def.extra_node_def)
end

print ("[MOD] Moreores loaded")