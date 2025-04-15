-- Dungeon Master by PilzAdam

mobs:register_mob("mobs:dungeon_master", {
	type = "monster",
	passive = false,
	damage = 7,
	attack_type = "dogshoot",
	dogshoot_switch = 1,
	dogshoot_count_max = 12, -- shoot for 10 seconds
	dogshoot_count2_max = 3, -- dogfight for 3 seconds
	reach = 3,
	shoot_interval = 2.2,
	arrow = "mobs:fireball",
	shoot_offset = 1.5,
	hp_min = 42,
	hp_max = 75,
	armor = 60,
	collisionbox = {-0.7, -1, -0.7, 0.7, 1.6, 0.7},
	visual = "mesh",
	mesh = "mobs_dungeon_master.b3d",
	textures = {"mobs_dungeon_master.png"},
	makes_footstep_sound = true,
	sounds = {
		distance = 50,
		--random = "mobs_monster",
		damage = "mobs_monster_hit",
		death = "mobs_monster_death",
		shoot_attack = "mobs_fireball",
		attack = "mobs_dungeonmaster"
	},
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	view_range = 15,
	drops = {
		{name = "default:mese_crystal_fragment", chance = 1, min = 0, max = 2},
		{name = "default:mese_crystal", chance = 3, min = 0, max = 2},
		{name = "default:diamond", chance = 4, min = 0, max = 1},
		{name = "default:diamondblock", chance = 50, min = 0, max = 1},
	},
	water_damage = 1,
	lava_damage = 1,
	light_damage = 0,
	fear_height = 3,
	animation = {
		stand_start = 0,
		stand_end = 19,
		walk_start = 20,
		walk_end = 35,
		punch_start = 36,
		punch_end = 48,
		shoot_start = 36,
		shoot_end = 48,
		speed_normal = 15,
		speed_run = 15,
	},
})

mobs:spawn({
	name = "mobs:dungeon_master",
	nodes = {"default:stone"},
	chance = 800, -- 0.125%
	max_light = 5,
	max_height = -70,
	min_height = -4049,
	active_object_count = 2,
})

-- deep
mobs:spawn({
	name = "mobs:dungeon_master",
	nodes = {"default:stone"},
	chance = 500, -- 0.2%
	max_light = 6,
	max_height = -4050,
	min_height = -31000,
	active_object_count = 3,
})

mobs:register_egg("mobs:dungeon_master", "Dungeon Master", "fire_basic_flame.png", 1)

-- fireball (weapon)
mobs:register_arrow("mobs:fireball", {
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"mobs_fireball.png"},
	collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
	velocity = 7,
	--tail = 1,
	--tail_texture = "mobs_fireball.png",
	--tail_size = 10,
	glow = 5,
	expire = 0.1,

	on_activate = function(self, staticdata, dtime_s)
		-- make fireball indestructable
		self.object:set_armor_groups({immortal = 1, fleshy = 100})
	end,

	-- if player has a good weapon with 7+ damage it can deflect fireball
	on_punch = function(self, hitter, tflp, tool_capabilities, dir)

		if hitter and hitter:is_player() and tool_capabilities and dir then
			local damage = tool_capabilities.damage_groups and tool_capabilities.damage_groups.fleshy or 1
			if damage > 6 then
				self.object:set_velocity({
					x = dir.x * self.velocity,
					y = dir.y * self.velocity,
					z = dir.z * self.velocity,
				})
			end
		end
	end,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 5},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 5},
		}, nil)
	end,

	-- node hit
	hit_node = function(self, pos, node)
		mobs:boom(self, pos, 2)
	end
})