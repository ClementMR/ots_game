-- Sand Monster by PilzAdam

mobs:register_mob("mobs:sand_monster", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	--specific_attack = {"player", "mobs_npc:npc"},
	--ignore_invisibility = true,
	reach = 2,
	damage = 1,
	hp_min = 4,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	visual = "mesh",
	mesh = "mobs_sand_monster.b3d",
	textures = {"mobs_sand_monster.png"},
	makes_footstep_sound = true,
	sounds = {
		--distance = 50,
		--random = "mobs_monster",
		damage = "mobs_monster_hit",
		death = "mobs_monster_death"
	},
	walk_velocity = 1.5,
	run_velocity = 4,
	view_range = 10,
	jump = true,
	floats = 0,
	drops = {
		{name = "default:desert_sand", chance = 1, min = 3, max = 5},
	},
	water_damage = 3,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 4,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 39,
		walk_start = 41,
		walk_end = 72,
		run_start = 74,
		run_end = 105,
		punch_start = 74,
		punch_end = 105,
	},
	immune_to = {
		{"default:shovel_wood", 3}, -- shovels deal more damage to sand monster
		{"default:shovel_stone", 3},
		{"default:shovel_bronze", 4},
		{"default:shovel_steel", 4},
		{"default:shovel_mese", 5},
		{"default:shovel_diamond", 7},
	},
})

mobs:spawn({
	name = "mobs:sand_monster",
	nodes = {"default:desert_sand"},
	chance = 300,
	min_height = 0,
	active_object_count = 5,
})

mobs:register_egg("mobs:sand_monster", "Sand Monster", "default_desert_sand.png", 1)