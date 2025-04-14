local anticheat = {}

local history_length = 200
local player_info = {}
local checks = {}

local function split_command(input)
    local space_pos = input:find(" ")

    if space_pos then
        local command = input:sub(1, space_pos - 1)
        local param = input:sub(space_pos + 1)
        return command, param
    else
        return input, ""
    end
end

function anticheat.flag(player, check_name)
    local check = checks[check_name]
    local time = core.get_server_uptime()
    local player_name = player:get_player_name()
    if not player_info[player_name].violations[check_name] then player_info[player_name].violations[check_name] = {} end
    local violations = player_info[player_name].violations[check_name]

    -- Prevents flags from happening too fast
    if check.violation_delay and check.violation_delay >= 0 and #violations > 0 and time - violations[#violations] < check.violation_delay then
        return
    end

    -- Iterate backwards and remove anything too old
    for i = #violations, 1, -1 do
        if check.violation_period and check.violation_period >= 0 and time - violations[i] > check.violation_period then
            table.remove(violations, i)
        end
    end

    -- Add the violation/flag
    table.insert(violations, time)

    if check.violation_punish and check.violation_punish >= 1 and #violations >= check.violation_punish then
        -- The punishment command might not disconnect the player, so we reset their violations
        player_info[player_name].violations[check_name] = {}

        local punishment_command, punishment_params = split_command("kick @player Cheating detected. If this is incorrect, you may rejoin.")
        if #punishment_command > 0 then
            local cmd = core.registered_chatcommands[punishment_command]
            if cmd then
                -- Runs the command as the admin user
                cmd.func(core.settings:get("name"), punishment_params:gsub("@player", player_name):gsub("@check", check.title))

                if core.get_modpath("relay") then
                    relay.send("Anticheat: "..player_name.." was punished for using "..check.title..".")
                end
            end
        end

        for _, loop_player in ipairs(core.get_connected_players()) do
            local loop_player_name = loop_player:get_player_name()
            if core.check_player_privs(loop_player_name, { server = true }) then
                core.chat_send_player(loop_player_name, core.colorize("#FFFFFF", player_name)
                    .. core.colorize("#CCCCCC", " was punished for using ")
                    .. core.colorize("#FFFFFF", check.title)
                    .. core.colorize("#CCCCCC", "."))
            end
        end
    elseif (check.violation_alert and check.violation_alert >= 1 and #violations >= check.violation_alert) then
        for _, loop_player in ipairs(core.get_connected_players()) do
            local loop_player_name = loop_player:get_player_name()
            if core.check_player_privs(loop_player_name, { server = true }) then
                core.chat_send_player(loop_player_name, core.colorize("#FFFFFF", player_name)
                    .. core.colorize("#CCCCCC", " was caught using ")
                    .. core.colorize("#FFFFFF", check.title)
                    .. core.colorize("#FF9F1C", " #" .. #violations))
            end
        end
    end
end

function anticheat.register_check(name, info)
    checks[name] = info
end

function anticheat.clear_history(player)
    if not player_info[player:get_player_name()] then return end -- Once the set_pos has been wrapped, static spawn point will try to call set pos before we can set anything up, which calls this
    player_info[player:get_player_name()].position_history = {}
    --player_info[player:get_player_name()].velocity_history = {}
    --player_info[player:get_player_name()].ground_history = {}
    player_info[player:get_player_name()].max_speed_history = {}
end

local wrapped_player = false
core.register_on_joinplayer(function(player, last_login)
    player_info[player:get_player_name()] = {
        violations = {}
    }
    anticheat.clear_history(player)

    if not wrapped_player then
        wrapped_player = true
        -- Overrides for all players
        local set_pos = player.set_pos
        getmetatable(player).set_pos = function(...)
            print(select(1, ...))
            anticheat.clear_history(select(1, ...))
            return set_pos(...)
        end

        local add_pos = player.add_pos
        getmetatable(player).add_pos = function(...)
            anticheat.clear_history(select(1, ...))
            return add_pos(...)
        end

        local add_velocity = player.add_velocity
        getmetatable(player).add_velocity = function(...)
            anticheat.clear_history(select(1, ...))
            return add_velocity(...)
        end
    end
end)

core.register_on_leaveplayer(function(player, timed_out)
    player_info[player:get_player_name()] = nil
end)

core.register_on_respawnplayer(function(player)
    anticheat.clear_history(player)
end)

function anticheat.is_setback_enabled()
    return true
end

local function update_history(history_table, new_value)
    table.insert(history_table, 1, new_value)
    if #history_table > history_length then
        table.remove(history_table)
    end
end

local function on_ground(player)
    local pos = player:get_pos()
    local allowed_dist = 0.4
    local points = {
        {x = pos.x, y = pos.y - 0.5, z = pos.z},
        {x = pos.x + allowed_dist, y = pos.y - 0.5, z = pos.z},
        {x = pos.x - allowed_dist, y = pos.y - 0.5, z = pos.z},
        {x = pos.x, y = pos.y - 0.5, z = pos.z + allowed_dist},
        {x = pos.x, y = pos.y - 0.5, z = pos.z - allowed_dist},
    }
    
    for _, check_pos in ipairs(points) do
        local node = core.get_node(check_pos)
        local node_def = core.registered_nodes[node.name]
        if node_def and (node_def.walkable or node_def.liquidtype ~= "none" or node_def.climbable) then
            return true
        end
    end
    
    return false
end

local function eq_for(arr, prop)
    local last_value = nil
    for i, v in ipairs(arr) do
        if i > 1 then
            if prop then
                if v[prop] ~= last_value then
                    return i - 1
                end
            else
                if v ~= last_value then
                    return i - 1
                end
            end
        end
        if prop then
            last_value = v[prop]
        else
            last_value = v
        end
    end
    return #arr
end

local function le_for(arr, prop, margin)
    if not margin then margin = 0 end
    local last_value = nil
    for i, v in ipairs(arr) do
        if i > 1 then
            if prop then
                if v[prop] - margin > last_value then
                    return i - 1
                end
            else
                if v - margin > last_value then
                    return i - 1
                end
            end
        end
        if prop then
            last_value = v[prop] - margin
        else
            last_value = v - margin
        end
    end
    return #arr
end

--
--- Checks
--

--[[
anticheat.register_check("fly", {
    title = "Fly",
    violation_delay = 2,
    violation_period = 60 * 5,
    violation_alert = 3,
    violation_punish = 6,
    globalstep = function(player, info, flag)
        --if not core.settings:get_bool("anticheat_fly_a_enabled", true) then return end
        if core.check_player_privs(player, { fly = true }) then return end

        local y_margin = 0.5
        if info.ground_history[1] == false and eq_for(info.ground_history) >= 70 and info.velocity_history[1].y >= -y_margin and le_for(info.velocity_history, "y", y_margin) >= 30 then
            if anticheat.is_setback_enabled() then
                local old_pos = info.position_history[eq_for(info.ground_history)+1] or info.position_history[#info.position_history]
                player:set_pos(old_pos)
            end

            flag()
        end
    end
})
]]

anticheat.register_check("speed", {
    title = "Speed",
    violation_delay = 1,
    violation_period = 60 * 5,
    violation_alert = 3,
    violation_punish = 6,
    globalstep = function(player, info, flag)
        if core.check_player_privs(player, { fast = true }) then return end
        if #info.position_history < 60 then return end
        if eq_for(info.max_speed_history) < 20 then return end

        -- the added amount is to give some breathing room
        local max_speed = info.max_speed_history[1] + 1
        local vel_speed = math.hypot(player:get_velocity().x, player:get_velocity().z)
        --local pos_speed = math.hypot(info.position_history[1].x - info.position_history[2].x, info.position_history[1].z - info.position_history[2].z) * 10
        local pos_speed = 0 -- Seems to false every once in a while if we do the above. TODO: We should get the average speed over a second or so

        -- Maybe also check if the speed is increasing
        if pos_speed > max_speed or vel_speed > max_speed then
            if anticheat.is_setback_enabled() then
                local old_pos = info.position_history[2]
                player:set_pos(old_pos)
            end

            flag()
        end
    end
})

core.register_on_joinplayer(function(player, last_login)
    local info = player_info[player:get_player_name()]

    -- Checks
    for name, check in pairs(checks) do
        if check.joinplayer then
            local function flag()
                anticheat.flag(player, name)
            end

            check.joinplayer(player, info, flag)
        end
    end
end)

core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        local info = player_info[player:get_player_name()]

        -- History
        local pos = player:get_pos()
        update_history(info.position_history, pos)
        --update_history(info.velocity_history, player:get_velocity())
        --update_history(info.ground_history, on_ground(player))
        update_history(info.max_speed_history, player:get_physics_override().speed * player:get_physics_override().speed_walk * 4)

        -- Checks
        for name, check in pairs(checks) do
            if check.globalstep then
                local function flag()
                    anticheat.flag(player, name)
                end

                check.globalstep(player, info, flag)
            end
        end
    end
end)