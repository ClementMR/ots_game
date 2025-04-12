-- Dirt Monster by PilzAdam

mobs:register_mob("mobs:dirt_monster", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 2,
	damage = 2,
	hp_min = 5,
	hp_max = 27,
	armor = 100,
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	visual = "mesh",
	mesh = "mobs_stone_monster.b3d",
	textures = {"mobs_dirt_monster.png"},
	makes_footstep_sound = true,
	sounds = {
		--distance = 50,
		--random = "mobs_monster",
		damage = "mobs_monster_hit",
		death = "mobs_monster_death"
	},
	view_range = 15,
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:dirt", chance = 1, min = 0, max = 2},
		{name = "default:grass_1", chance = 5, min = 0, max = 2},
		{name = "default:dirt_with_grass", chance = 50, min = 0, max = 1}
	},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 3,
	fear_height = 4,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 14,
		walk_start = 15,
		walk_end = 38,
		run_start = 40,
		run_end = 63,
		punch_start = 40,
		punch_end = 63,
	},
})

mobs:spawn({
	name = "mobs:dirt_monster",
	nodes = {
		"default:dirt_with_grass",
		"default:dirt_with_coniferous_litter",
		"default:dirt_with_snow",
		"default:dirt_with_dry_grass",
		"default:dry_dirt_with_dry_grass"
	},
	chance = 200,
	max_light = 7,
	min_height = 0,
	active_object_count = 4,
	day_toggle = false,
})

mobs:register_egg("mobs:dirt_monster", "Dirt Monster", "default_dirt.png", 1)