local MP = core.get_modpath(core.get_current_modname())

-- Override

core.override_item("default:tinblock", {
    sounds = default.node_sound_stone_defaults(),
})

--  Minerals recipes

core.register_craft({
	output = "flowers:waterlily",
	recipe = {
		{"default:grass_1", "default:grass_1", ""},
		{"default:grass_1", "default:grass_1", ""},
		{"", "", ""}
	}
})

core.register_craft({
	output = "default:stone_with_coal",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:coal_lump",
	}
})

core.register_craft({
	output = "default:stone_with_iron",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:iron_lump",
	}
})

core.register_craft({
	output = "default:stone_with_tin",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:tin_lump",
	}
})

core.register_craft({
	output = "default:stone_with_copper",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:copper_lump",
	}
})

core.register_craft({
	output = "default:stone_with_gold",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:gold_lump",
	}
})

core.register_craft({
	output = "default:stone_with_mese",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:mese_crystal",
	}
})

core.register_craft({
	output = "default:stone_with_diamond",
	type = "shapeless",
	recipe = {
		"default:stone",
		"default:diamond",
	}
})

core.register_craft({
	output = "moreores:mineral_mithril",
	type = "shapeless",
	recipe = {
		"default:stone",
		"moreores:mithril_lump",
	}
})

core.register_craft({
	output = "moreores:mineral_silver",
	type = "shapeless",
	recipe = {
		"default:stone",
		"moreores:silver_lump",
	}
})

core.register_craft({
	output = "quartz:quartz_ore",
	type = "shapeless",
	recipe = {
		"default:stone",
		"quartz:quartz_crystal",
	}
})

core.register_chatcommand("placeblock", {
    params = "<x> <y> <z> <block>",
    description = "Place a block",
    privs = {server = true},
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        local x, y, z, block = param:match("^(%-?%d+) (%-?%d+) (%-?%d+) ([%w_:]+)$")
        if not x or not y or not z or not block then
            return false, "Usage: /placeblock <x> <y> <z> <block>"
        end

        if not core.registered_nodes[block] then
            return false, "Invalid block name: " .. block
        end

        x, y, z = tonumber(x), tonumber(y), tonumber(z)

		core.set_node({x = x, y = y, z = z}, {name = block})

        return true, "Block " .. block .. " placed at " .. x .. ", " .. y .. ", " .. z
    end
})

core.register_chatcommand("s_msg", {
	params = "<name> <message>",
	description = "Send a direct message to a player (Admin tunnel)",
	privs = {server=true},
	func = function(name, param)
		local sendto, message = param:match("^(%S+)%s(.+)$")
		if not sendto then
			return false, "Invalid usage, see /help s_msg."
		end

		if not core.get_player_by_name(sendto) then
			return false, "The player "..sendto.." is not online."
		end

		core.chat_send_player(sendto, core.colorize("yellow", "[Server] "..message))

		core.log("action", "[Server] sent to "..sendto..": "..message)

		return true, "Message sent to "..sendto.."."
	end,
})

core.register_chatcommand("s_all", {
	params = "<message>",
	description = "Send a message to all players (Admin tunnel)",
	privs = {server=true},
	func = function(name, param)
		if not param or param == "" then
			return false, "Invalid usage, see /help s_all."
		end

		core.chat_send_all(core.colorize("yellow", "[Server] "..param))

		core.log("action", "[Server] sent : "..param)
	end,
})

core.register_chatcommand("clear_bed", {
    description = "Clear your bed spawn position",
    privs = {interact = true},
    func = function(name)
        if beds.spawn[name] then
            beds.spawn[name] = nil
            beds.save_spawns()
            return true, "Your bed spawn position has been cleared."
        else
            return false, "You don't have a bed spawn position set."
        end
    end,
})

core.hud_replace_builtin("breath", {
	type = "statbar",
	position = {x = 0.5, y = 1},
	text = "bubble.png",
	text2 = "bubble_gone.png",
	number = core.PLAYER_MAX_BREATH_DEFAULT * 2,
	item = core.PLAYER_MAX_BREATH_DEFAULT * 2,
	direction = 0,
	size = {x = 24, y = 24},
	offset = {x = 25, y= -120},
})

--dofile(MP .. "/expire.lua")
--dofile(MP .. "/anticheat.lua")

print ("[MOD] 421 loaded")