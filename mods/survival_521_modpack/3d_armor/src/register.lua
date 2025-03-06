local S = core.get_translator(core.get_current_modname())

-- Admin Helmet
armor:register_armor("3d_armor:helmet_admin", {
	description = S("Admin Helmet"),
	inventory_image = "3d_armor_inv_helmet_admin.png",
	armor_groups = {fleshy=100},
	groups = {armor_head=1, armor_use=0, armor_water=1, not_in_creative_inventory=1},
	on_drop = function(itemstack, dropper, pos)
		return
	end,
})

-- Admin Chestplate
armor:register_armor("3d_armor:chestplate_admin", {
	description = S("Admin Chestplate"),
	inventory_image = "3d_armor_inv_chestplate_admin.png",
	armor_groups = {fleshy=100},
	groups = {armor_torso=1, armor_use=0, armor_water=1, not_in_creative_inventory=1},
	on_drop = function(itemstack, dropper, pos)
		return
	end
})

-- Admin Leggings
armor:register_armor("3d_armor:leggings_admin", {
	description = S("Admin Leggings"),
	inventory_image = "3d_armor_inv_leggings_admin.png",
	armor_groups = {fleshy=100},
	groups = {armor_legs=1, armor_use=0, armor_water=1, not_in_creative_inventory=1},
	on_drop = function(itemstack, dropper, pos)
		return
	end
})

-- Admin Boots
armor:register_armor("3d_armor:boots_admin", {
	description = S("Admin Boots"),
	inventory_image = "3d_armor_inv_boots_admin.png",
	armor_groups = {fleshy=100},
	groups = {armor_feet=1, armor_use=0, armor_water=1, not_in_creative_inventory=1},
	on_drop = function(itemstack, dropper, pos)
		return
	end
})

-- Admin Shield
armor:register_armor(":shields:shield_admin", {
	description = S("Admin Shield"),
	inventory_image = "shields_inv_shield_admin.png",
	groups = {armor_shield=1000, armor_use=0, not_in_creative_inventory=1},
})

if armor.materials.mithril then

	-- Mithril Helmet
	armor:register_armor("3d_armor:helmet_mithril", {
		description = S("Mithril Helmet"),
		inventory_image = "3d_armor_inv_helmet_mithril.png",
		groups = {armor_head=1, armor_use=50},
		armor_groups = {fleshy=15},
		damage_groups = {cracky=2, snappy=1, level=3},
	})

	-- Mithril Chestplate
	armor:register_armor("3d_armor:chestplate_mithril", {
		description = S("Mithril Chestplate"),
		inventory_image = "3d_armor_inv_chestplate_mithril.png",
		groups = {armor_torso=1, armor_use=50},
		armor_groups = {fleshy=21},
		damage_groups = {cracky=2, snappy=1, level=3},
	})

	-- Mithril Leggings
	armor:register_armor("3d_armor:leggings_mithril", {
		description = S("Mithril Leggings"),
		inventory_image = "3d_armor_inv_leggings_mithril.png",
		groups = {armor_legs=1, armor_use=50},
		armor_groups = {fleshy=21},
		damage_groups = {cracky=2, snappy=1, level=3},
	})

	-- Mithril Boots
	armor:register_armor("3d_armor:boots_mithril", {
		description = S("Mithril Boots"),
		inventory_image = "3d_armor_inv_boots_mithril.png",
		groups = {armor_feet=1, armor_use=50},
		armor_groups = {fleshy=15},
		damage_groups = {cracky=2, snappy=1, level=3},
	})

	-- Mithril Shield
	armor:register_armor(":shields:shield_mithril", {
		description = S("Mithril Shield"),
		inventory_image = "shields_inv_shield_mithril.png",
		groups = {armor_shield=1, armor_use=50},
		armor_groups = {fleshy=16},
		damage_groups = {cracky=2, snappy=1, level=3},
		reciprocate_damage = true,
	})

end

if armor.materials.diamond then

	-- Diamond Helmet
	armor:register_armor("3d_armor:helmet_diamond", {
		description = S("Diamond Helmet"),
		inventory_image = "3d_armor_inv_helmet_diamond.png",
		groups = {armor_head=1, armor_use=100},
		armor_groups = {fleshy=14},
		damage_groups = {cracky=2, snappy=1, choppy=1, level=2},
	})

	-- Diamond Chestplate
	armor:register_armor("3d_armor:chestplate_diamond", {
		description = S("Diamond Chestplate"),
		inventory_image = "3d_armor_inv_chestplate_diamond.png",
		groups = {armor_torso=1, armor_use=100},
		armor_groups = {fleshy=20},
		damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	})

	-- Diamond Leggings
	armor:register_armor("3d_armor:leggings_diamond", {
		description = S("Diamond Leggings"),
		inventory_image = "3d_armor_inv_leggings_diamond.png",
		groups = {armor_legs=1, armor_use=100},
		armor_groups = {fleshy=20},
		damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	})

	-- Diamond Boots
	armor:register_armor("3d_armor:boots_diamond", {
		description = S("Diamond Boots"),
		inventory_image = "3d_armor_inv_boots_diamond.png",
		groups = {armor_feet=1, armor_use=100},
		armor_groups = {fleshy=14},
		damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	})

	-- Diamond Shield
	armor:register_armor(":shields:shield_diamond", {
		description = S("Diamond Shield"),
		inventory_image = "shields_inv_shield_diamond.png",
		groups = {armor_shield=1, armor_use=100},
		armor_groups = {fleshy=15},
		damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
		reciprocate_damage = true,
	})

end

if armor.materials.gold then

	-- Gold Helmet
	armor:register_armor("3d_armor:helmet_gold", {
		description = S("Gold Helmet"),
		inventory_image = "3d_armor_inv_helmet_gold.png",
		groups = {armor_head=1, armor_use=250},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	})

	-- Gold Chestplate
	armor:register_armor("3d_armor:chestplate_gold", {
		description = S("Gold Chestplate"),
		inventory_image = "3d_armor_inv_chestplate_gold.png",
		groups = {armor_torso=1, armor_use=250},
		armor_groups = {fleshy=16},
		damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	})

	-- Gold Leggings
	armor:register_armor("3d_armor:leggings_gold", {
		description = S("Gold Leggings"),
		inventory_image = "3d_armor_inv_leggings_gold.png",
		groups = {armor_legs=1, armor_use=250},
		armor_groups = {fleshy=16},
		damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	})

	-- Gold Boots
	armor:register_armor("3d_armor:boots_gold", {
		description = S("Gold Boots"),
		inventory_image = "3d_armor_inv_boots_gold.png",
		groups = {armor_feet=1, armor_use=250},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	})

	-- Gold Shield
	armor:register_armor(":shields:shield_gold", {
		description = S("Gold Shield"),
		inventory_image = "shields_inv_shield_gold.png",
		groups = {armor_shield=1, armor_use=250},
		armor_groups = {fleshy=11},
		damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
		reciprocate_damage = true,
	})

end

if armor.materials.bronze then

	-- Bronze Helmet
	armor:register_armor("3d_armor:helmet_bronze", {
		description = S("Bronze Helmet"),
		inventory_image = "3d_armor_inv_helmet_bronze.png",
		groups = {armor_head=1, armor_use=250},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	})

	-- Bronze Chestplate
	armor:register_armor("3d_armor:chestplate_bronze", {
		description = S("Bronze Chestplate"),
		inventory_image = "3d_armor_inv_chestplate_bronze.png",
		groups = {armor_torso=1, armor_use=250},
		armor_groups = {fleshy=15},
		damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	})

	-- Bronze Leggings
	armor:register_armor("3d_armor:leggings_bronze", {
		description = S("Bronze Leggings"),
		inventory_image = "3d_armor_inv_leggings_bronze.png",
		groups = {armor_legs=1, armor_use=250},
		armor_groups = {fleshy=15},
		damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	})

	-- Bronze Boots
	armor:register_armor("3d_armor:boots_bronze", {
		description = S("Bronze Boots"),
		inventory_image = "3d_armor_inv_boots_bronze.png",
		groups = {armor_feet=1, armor_use=250},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	})

	-- Bronze Shield
	armor:register_armor(":shields:shield_bronze", {
		description = S("Bronze Shield"),
		inventory_image = "shields_inv_shield_bronze.png",
		groups = {armor_shield=1, armor_use=250},
		armor_groups = {fleshy=11},
		damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
		reciprocate_damage = true,
	})

end

if armor.materials.steel then

	-- Steel Helmet
	armor:register_armor("3d_armor:helmet_steel", {
		description = S("Steel Helmet"),
		inventory_image = "3d_armor_inv_helmet_steel.png",
		groups = {armor_head=1, armor_use=500},
		armor_groups = {fleshy=9},
		damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	})

	-- Steel Chestplate
	armor:register_armor("3d_armor:chestplate_steel", {
		description = S("Steel Chestplate"),
		inventory_image = "3d_armor_inv_chestplate_steel.png",
		groups = {armor_torso=1, armor_use=500},
		armor_groups = {fleshy=14},
		damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	})

	-- Steel Leggings
	armor:register_armor("3d_armor:leggings_steel", {
		description = S("Steel Leggings"),
		inventory_image = "3d_armor_inv_leggings_steel.png",
		groups = {armor_legs=1, armor_use=500},
		armor_groups = {fleshy=14},
		damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	})

	-- Steel Boots
	armor:register_armor("3d_armor:boots_steel", {
		description = S("Steel Boots"),
		inventory_image = "3d_armor_inv_boots_steel.png",
		groups = {armor_feet=1, armor_use=500},
		armor_groups = {fleshy=9},
		damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	})

	-- Steel Shield
	armor:register_armor(":shields:shield_steel", {
		description = S("Steel Shield"),
		inventory_image = "shields_inv_shield_steel.png",
		groups = {armor_shield=1, armor_use=500},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	})

end

if armor.materials.cactus then

	-- Cactus Helmet
	armor:register_armor("3d_armor:helmet_cactus", {
		description = S("Cactus Helmet"),
		inventory_image = "3d_armor_inv_helmet_cactus.png",
		groups = {armor_head=1, armor_use=1000},
		armor_groups = {fleshy=5},
		damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	})

	-- Cactus Chestplate
	armor:register_armor("3d_armor:chestplate_cactus", {
		description = S("Cactus Chestplate"),
		inventory_image = "3d_armor_inv_chestplate_cactus.png",
		groups = {armor_torso=1, armor_use=1000},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	})

	-- Cactus Leggings
	armor:register_armor("3d_armor:leggings_cactus", {
		description = S("Cactus Leggings"),
		inventory_image = "3d_armor_inv_leggings_cactus.png",
		groups = {armor_legs=1, armor_use=1000},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	})

	-- Cactus Boots
	armor:register_armor("3d_armor:boots_cactus", {
		description = S("Cactus Boots"),
		inventory_image = "3d_armor_inv_boots_cactus.png",
		groups = {armor_feet=1, armor_use=1000},
		armor_groups = {fleshy=5},
		damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	})

	-- Cactus Shield
	armor:register_armor(":shields:shield_cactus", {
		description = S("Cactus Shield"),
		inventory_image = "shields_inv_shield_cactus.png",
		groups = {armor_shield=1, armor_use=1000},
		armor_groups = {fleshy=6},
		damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
		reciprocate_damage = true,
	})

	core.register_craft({
		type = "fuel",
		recipe = "shields:shield_cactus",
		burntime = 16,
	})

	local cactus_armor_fuel = {
		helmet = 14,
		chestplate = 16,
		leggings = 15,
		boots = 13
	}

	for armor, burn in pairs(cactus_armor_fuel) do
		core.register_craft({
			type = "fuel",
			recipe = "3d_armor:" .. armor .. "_cactus",
			burntime = burn,
		})
	end

end

if armor.materials.wood then

	-- Wood Helmet
	armor:register_armor("3d_armor:helmet_wood", {
		description = S("Wood Helmet"),
		inventory_image = "3d_armor_inv_helmet_wood.png",
		groups = {armor_head=1, armor_use=2000, flammable=1},
		armor_groups = {fleshy=4},
		damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
	})

	-- Wood Chestplate
	armor:register_armor("3d_armor:chestplate_wood", {
		description = S("Wood Chestplate"),
		inventory_image = "3d_armor_inv_chestplate_wood.png",
		groups = {armor_torso=1, armor_use=2000, flammable=1},
		armor_groups = {fleshy=9},
		damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
	})

	-- Wood Leggings
	armor:register_armor("3d_armor:leggings_wood", {
		description = S("Wood Leggings"),
		inventory_image = "3d_armor_inv_leggings_wood.png",
		groups = {armor_legs=1, armor_use=2000, flammable=1},
		armor_groups = {fleshy=9},
		damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
	})

	-- Wood Boots
	armor:register_armor("3d_armor:boots_wood", {
		description = S("Wood Boots"),
		inventory_image = "3d_armor_inv_boots_wood.png",
        groups = {armor_feet=1, armor_use=2000, flammable=1},
		armor_groups = {fleshy=4},
		damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
	})

	-- Wood Shield
	armor:register_armor(":shields:shield_wood", {
		description = S("Wooden Shield"),
		inventory_image = "shields_inv_shield_wood.png",
		groups = {armor_shield=1, armor_use=2000, flammable=1},
		armor_groups = {fleshy=5},
		damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
		reciprocate_damage = true,
	})

	core.register_craft({
		type = "fuel",
		recipe = "shields:shield_wood",
		burntime = 8,
	})

	local wood_armor_fuel = {
		helmet = 6,
		chestplate = 8,
		leggings = 7,
		boots = 5
	}

	for armor, burn in pairs(wood_armor_fuel) do
		core.register_craft({
			type = "fuel",
			recipe = "3d_armor:" .. armor .. "_wood",
			burntime = burn,
		})
	end

end

for k, v in pairs(armor.materials) do

	core.register_craft({
		output = "3d_armor:helmet_"..k,
		recipe = {
			{v, v, v},
			{v, "", v},
			{"", "", ""},
		},
	})

	core.register_craft({
		output = "3d_armor:chestplate_"..k,
		recipe = {
			{v, "", v},
			{v, v, v},
			{v, v, v},
		},
	})

	core.register_craft({
		output = "3d_armor:leggings_"..k,
		recipe = {
			{v, v, v},
			{v, "", v},
			{v, "", v},
		},
	})

	core.register_craft({
		output = "3d_armor:boots_"..k,
		recipe = {
			{v, "", v},
			{v, "", v},
		},
	})

	core.register_craft({
		output = "shields:shield_"..k,
		recipe = {
			{v, v, v},
			{v, v, v},
			{"", v, ""},
		},
	})
end