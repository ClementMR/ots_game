-- Lava Flan by Zeg9 (additional textures by JurajVajda)

mobs:register_mob("mobs:lava_flan", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 3,
	hp_min = 10,
	hp_max = 35,
	armor = 80,
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5},
	visual = "mesh",
	mesh = "zmobs_lava_flan.x",
	textures = {"zmobs_lava_flan2.png"},
	makes_footstep_sound = false,
	sounds = {
		distance = 50,
		random = "mobs_lavaflan",
		attack = "mobs_lavaflan",
		--damage = "mobs_monster_hit",
		--death = "mobs_monster_death"
	},
	walk_velocity = 0.5,
	run_velocity = 2,
	jump = true,
	view_range = 10,
	floats = 1,
	drops = {
		{name = "default:obsidian", chance = 2, min = 1, max = 4},
		{name = "tnt:tnt", chance = 5, min = 1, max = 2}
	},
	water_damage = 8,
	lava_damage = -1,
	fire_damage = 0,
	light_damage = 0,
	fly_in = {"default:lava_source", "default:lava_flowing"},
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 8,
		walk_start = 10,
		walk_end = 18,
		run_start = 20,
		run_end = 28,
		punch_start = 20,
		punch_end = 28
	},
	on_die = function(self, pos)

		local cod = self.cause_of_death or {}
		local def = cod.node and core.registered_nodes[cod.node]

		if def and def.groups and def.groups.water then

			pos.y = pos.y + 1

			mobs:effect(pos, 40, "tnt_smoke.png", 3, 5, 2, 0.5, nil, false)

			core.sound_play("fire_extinguish_flame",
				{pos = pos, max_hear_distance = 12, gain = 1.5}, true)

			self.object:remove()
		else
			if core.get_node(pos).name == "air" then
				core.set_node(pos, {name = "fire:basic_flame"})
			end

			mobs:effect(pos, 40, "fire_basic_flame.png", 2, 3, 2, 5, 10, nil)

			self.object:remove()
		end
	end,
	glow = 10,
})

mobs:spawn({
	name = "mobs:lava_flan",
	nodes = {"default:lava_source"},
	chance = 500,
	max_height = 0,
	active_object_count = 3,
})

mobs:register_egg("mobs:lava_flan", "Lava Flan", "default_lava.png", 1)