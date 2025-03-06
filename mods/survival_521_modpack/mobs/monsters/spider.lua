local get_velocity = function(self)

	local v = self.object:get_velocity()

	-- sanity check
	if not v then return 0 end

	return (v.x * v.x + v.z * v.z) ^ 0.5
end

-- Spider by AspireMint (CC-BY-SA 3.0 license)

mobs:register_mob("mobs:spider", {
	--docile_by_day = true,
	group_attack = true,
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 3,
	hp_min = 10,
	hp_max = 30,
	armor = 200,
	collisionbox = {-0.8, -0.5, -0.8, 0.8, 0, 0.8},
	visual_size = {x = 1, y = 1},
	visual = "mesh",
	mesh = "mobs_spider.b3d",
	textures = {"mobs_spider_crystal.png"},
	makes_footstep_sound = false,
	sounds = {
		distance = 50,
		random = "mobs_monster",
		attack = "mobs_spider"
	},
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	view_range = 15,
	floats = 0,
	drops = {
		{name = "farming:string", chance = 1, min = 0, max = 2},
		{name = "flowers:mushroom_red", chance = 5, min = 0, max = 1},
	},
	water_damage = 5,
	lava_damage = 5,
	light_damage = 0,
	animation = {
		speed_normal = 15,
		speed_run = 20,
		stand_start = 0,
		stand_end = 0,
		walk_start = 1,
		walk_end = 21,
		run_start = 1,
		run_end = 21,
		punch_start = 25,
		punch_end = 45,
	},
	-- custom function to make spiders climb vertical facings
	do_custom = function(self, dtime)

		-- quarter second timer
		self.spider_timer = (self.spider_timer or 0) + dtime
		if self.spider_timer < 0.25 then
			return
		end
		self.spider_timer = 0

		-- need to be stopped to go onwards
		if get_velocity(self) > 0.5 then
			self.disable_falling = nil
			return
		end

		local pos = self.object:get_pos()
		local yaw = self.object:get_yaw()

		-- sanity check
		if not yaw then return end

		pos.y = pos.y + self.collisionbox[2] - 0.2

		local dir_x = -math.sin(yaw) * (self.collisionbox[4] + 0.5)
		local dir_z = math.cos(yaw) * (self.collisionbox[4] + 0.5)
		local nod = core.get_node_or_nil({
			x = pos.x + dir_x,
			y = pos.y + 0.5,
			z = pos.z + dir_z
		})

		-- get current velocity
		local v = self.object:get_velocity()

		-- can only climb solid facings
		if not nod or not core.registered_nodes[nod.name]
		or not core.registered_nodes[nod.name].walkable then
			self.disable_falling = nil
			v.y = 0
			self.object:set_velocity(v)
			return
		end

--print ("----", nod.name, self.disable_falling, dtime)

		-- turn off falling if attached to facing
		self.disable_falling = true

		-- move up facing
		v.x = 0 ; v.y = 0
		v.y = self.jump_height
		mobs:set_animation(self, "jump")
		self.object:set_velocity(v)
	end,

	-- make spiders jump at you on attack
	custom_attack = function(self, pos)

		local vel = self.object:get_velocity()

		self.object:set_velocity({
			x = vel.x * self.run_velocity,
			y = self.jump_height * 1.5,
			z = vel.z * self.run_velocity
		})

		self.pausetimer = 0.5

		return true -- continue rest of attack function
	end
})

-- below ground spawn
mobs:spawn({
	name = "mobs:spider",
	nodes = {
		"default:stone_with_mese", 
		"default:mese", 
		"default:stone"
	},
	chance = 350,
	max_light = 7,
	max_height = -40,
	active_object_count = 1,
})


mobs:register_egg("mobs:spider", "Spider", "mobs_cobweb.png", 1)