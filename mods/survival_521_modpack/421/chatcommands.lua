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

local function getopts(command, param)
	local opts = ""
	local args = {}
	for match in param:gmatch("%S+") do
		if match:byte(1) == 45 then -- 45 = '-'
			local second = match:byte(2)
			if second == 45 then
				return false, "Invalid parameters (see /help " .. command ..")."
			elseif second and (second < 48 or second > 57) then -- 48 = '0', 57 = '9'
				opts = opts .. match:sub(2)
			else
				-- numeric, add it to args
				args[#args + 1] = match
			end
		else
			args[#args + 1] = match
		end
	end
	return opts, args
end

local function format_help_line(cmd, def)
	local cmd_marker = INIT == "client" and "." or "/"
	local msg = core.colorize("#00ffff", cmd_marker .. cmd)
	if def.params and def.params ~= "" then
		msg = msg .. " " .. def.params
	end
	if def.description and def.description ~= "" then
		msg = msg .. ": " .. def.description
	end
	return msg
end

core.override_chatcommand("help", {
    func = function(name, param)
        local opts, args = getopts("help", param)
        if not opts then
            return false, args
        end
        if #args > 1 then
            return false, "Too many arguments, try using just /help <command>"
        end

        if #args == 0 then
            local cmds = {}
            for cmd, def in pairs(core.registered_chatcommands) do
                if core.check_player_privs(name, def.privs) then
                    cmds[#cmds + 1] = cmd
                end
            end
            table.sort(cmds)
            local msg
            msg = "Available commands: "
                .. table.concat(cmds, " ") .. "\n"
                .. "Use \"/help <cmd>\" to get more "
                .. "information, or \"/help all\" to list "
                .. "everything."
            return true, msg
        elseif args[1] == "all" then
            local cmds = {}
            for cmd, def in pairs(core.registered_chatcommands) do
                if core.check_player_privs(name, def.privs) then
                    cmds[#cmds + 1] = format_help_line(cmd, def)
                end
            end
            table.sort(cmds)
            return true, "Available commands:\n"..table.concat(cmds, "\n")
        elseif args[1] == "privs" then
            local privs = {}
            for priv, def in pairs(core.registered_privileges) do
                privs[#privs + 1] = priv .. ": " .. def.description
            end
            table.sort(privs)
            return true, "Available privileges:".."\n"..table.concat(privs, "\n")
        else
            local cmd = args[1]
            local def = core.registered_chatcommands[cmd]
            if not def then
                return false, "Command not available: "..cmd
            else
                return true, format_help_line(cmd, def)
            end
        end
    end
})