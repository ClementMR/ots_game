-- Tree Monster (or Tree Gollum) by PilzAdam

mobs:register_mob("mobs:tree_monster", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	attack_animals = true,
	--specific_attack = {"player", "mobs_animal:chicken"},
	reach = 2,
	damage = 2,
	hp_min = 20,
	hp_max = 40,
	armor = 100,
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	visual = "mesh",
	mesh = "mobs_tree_monster.b3d",
	textures = {"mobs_tree_monster.png"},
	makes_footstep_sound = true,
	sounds = {
		--distance = 50,
		--random = "mobs_monster",
		damage = "mobs_monster_hit",
		death = "mobs_monster_death"
	},
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	view_range = 15,
	drops = {
		{name = "default:stick", chance = 1, min = 0, max = 2},
		{name = "default:sapling", chance = 2, min = 0, max = 2},
		{name = "default:junglesapling", chance = 3, min = 0, max = 2},
		{name = "default:apple", chance = 4, min = 1, max = 2},
	},
	water_damage = 0,
	lava_damage = 0,
	light_damage = 2,
	fall_damage = 0,
	immune_to = {
		{"default:axe_wood", 0}, -- wooden axe doesnt hurt wooden monster
		{"default:axe_stone", 4}, -- axes deal more damage to tree monster
		{"default:axe_bronze", 5},
		{"default:axe_steel", 5},
		{"default:axe_mese", 7},
		{"default:axe_diamond", 9},
		{"default:sapling", -5}, -- default and jungle saplings heal
		{"default:junglesapling", -5},
--		{"all", 0}, -- only weapons on list deal damage
	},
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 24,
		walk_start = 25,
		walk_end = 47,
		run_start = 48,
		run_end = 62,
		punch_start = 48,
		punch_end = 62,
	},
})

mobs:spawn({
	name = "mobs:tree_monster",
	nodes = {
		"group:leaves",
		"default:dirt_with_rainforest_litter"
	},
	max_light = 7,
	chance = 300, -- 0.3%
	min_height = 0,
	active_object_count = 2,
	day_toggle = false,
})

mobs:register_egg("mobs:tree_monster", "Tree Monster", "default_tree_top.png", 1)