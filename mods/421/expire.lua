expired_players = {}

local storage_file = core.get_worldpath() .. "/expired_players.txt"

local function save_player(name, b)
    expired_players[name] = b

    if b then
        local file = io.open(storage_file, "a")
        if file then
            file:write(name .. "\n")
            file:close()
        else
            core.log("error", "[Expire] Failed to write in file")
        end
    else
        local new_data = {}
        local file = io.open(storage_file, "r")
        if file then
            for line in file:lines() do
                if line:trim() ~= name then
                    table.insert(new_data, line)
                end
            end
            file:close()
        else
            core.log("error", "[Expire] Failed to read file for "..name)
            return
        end

        file = io.open(storage_file, "w")
        if file then
            for _, player in ipairs(new_data) do
                file:write(player .. "\n")
            end
            file:close()
        else
            core.log("error", "[Expire] Failed to rewrite file for "..name)
        end
    end
end

core.register_on_mods_loaded(function()
    local file = io.open(storage_file, "r")
    if file then
        for line in file:lines() do
            expired_players[line:trim()] = true
        end
        file:close()
    else
        core.log("error", "[Expire] Failed to read file")
    end
end)

core.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local meta = player:get_meta()

    if not core.check_player_privs(player, {server = true}) then
        meta:set_string("exp_last_login", tostring(os.time()))
    else
        meta:set_string("exp_last_login", "")
    end

    -- Only works if player is expired
    if expired_players[name] then
        local inv = player:get_inventory()
        inv:set_list("pex:hyper_chest", {})

        if core.get_modpath("3d_armor") then
            armor:remove_all(player)
        end

        -- TODO : clear bed position

        if core.get_modpath("skins") then
            skins.set_player_skin(player, "character.png")
            core.set_player_privs(name, {interact = true, shout = true})
        end

        local spawn = core.setting_get_pos("static_spawnpoint")
        if spawn then
            player:set_pos(spawn)
        end

        save_player(name, false)
    end
end)

core.register_chatcommand("expire_player", {
    params = "<name>",
    description = "Expire a player",
    privs = {server = true},
    func = function(name, param)
        local target_name = param:trim()
        if target_name == "" then
            return false, "Usage: /expire_player <playername>"
        end

        if not core.get_player_by_name(target_name) then
            return false, "Player not online."
        end

        save_player(target_name, true)

        return true, "Player " .. target_name .. " has been expired."
    end
})

core.register_abm({
    nodenames = {"default:chest_locked"},
    interval = 10,
    chance = 1,

    action = function(pos, node)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")

        if expired_players[owner] then
            local inv = meta:get_inventory()
            local list = inv:get_list("main")

            core.set_node(pos, {name = "default:chest", param2 = node.param2})

            local new_meta = core.get_meta(pos)
            new_meta:set_string("infotext", "Chest (" .. owner .. ")")
            new_meta:get_inventory():set_list("main", list)

            if new_meta:get_inventory():room_for_item("main", "default:steel_ingot") then
                new_meta:get_inventory():add_item("main", "default:steel_ingot")
            end

            core.log("action", "[Expire] Replaced locked chest of " .. owner .. " at " .. core.pos_to_string(pos))
        end
    end
})

core.register_abm({
    nodenames = {"pex:mailbox"},
    interval = 10,
    chance = 1,

    action = function(pos, node)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")

        if expired_players[owner] then
            local inv = meta:get_inventory()
            local list = inv:get_list("main")

            core.set_node(pos, {name = "default:chest", param2 = node.param2})

            local new_meta = core.get_meta(pos)
            new_meta:set_string("infotext", "Mailbox (" .. owner .. ")")
            new_meta:get_inventory():set_list("main", list)

            if new_meta:get_inventory():room_for_item("main", "default:steel_ingot") then
                new_meta:get_inventory():add_item("main", "default:steel_ingot")
            end

            core.log("action", "[Expire] Replaced mailbox of " .. owner .. " at " .. core.pos_to_string(pos))
        end
    end
})

local protector = "pex:protector"
core.register_abm({
    nodenames = {protector},
    interval = 10,
    chance = 1,

    action = function(pos, node)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")

        if expired_players[owner] then
            local inv = meta:get_inventory()
            core.set_node(pos, {name = "default:chest", param2 = node.param2})

            local new_meta = core.get_meta(pos)
            new_meta:set_string("infotext", "Chest (" .. owner .. ")")
            new_meta:get_inventory():add_item("main", protector)

            core.log("action", "[Expire] Replaced protector of " .. owner .. " at " .. core.pos_to_string(pos))
        end
    end
})

local protector2 = "pex:protector2"
core.register_abm({
    nodenames = {protector2},
    interval = 10,
    chance = 1,

    action = function(pos, node)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")

        if expired_players[owner] then
            local inv = meta:get_inventory()
            core.set_node(pos, {name = "default:chest", param2 = node.param2})

            local new_meta = core.get_meta(pos)
            new_meta:set_string("infotext", "Chest (" .. owner .. ")")
            new_meta:get_inventory():add_item("main", protector2)

            core.log("action", "[Expire] Replaced protector logo of " .. owner .. " at " .. core.pos_to_string(pos))
        end
    end
})

core.register_abm({
    nodenames = {
        "doors:door_steel_a",
        "doors:door_steel_b",
        "doors:door_steel_c",
        "doors:door_steel_d"
    },
    interval = 10,
    chance = 1,

    action = function(pos, node)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")

        if expired_players[owner] then
            local inv = meta:get_inventory()
            core.set_node(pos, {name = "default:chest", param2 = node.param2})

            local new_meta = core.get_meta(pos)
            new_meta:set_string("infotext", "Chest (" .. owner .. ")")
            new_meta:get_inventory():add_item("main", "doors:door_steel")

            core.log("action", "[Expire] Replaced steel door of " .. owner .. " at " .. core.pos_to_string(pos))
        end
    end
})

core.register_abm({
    nodenames = {
        "xpanes:door_steel_bar_a",
        "xpanes:door_steel_bar_b",
        "xpanes:door_steel_bar_c",
        "xpanes:door_steel_bar_d"
    },
    interval = 10,
    chance = 1,

    action = function(pos, node)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")

        if expired_players[owner] then
            local inv = meta:get_inventory()
            core.set_node(pos, {name = "default:chest", param2 = node.param2})

            local new_meta = core.get_meta(pos)
            new_meta:set_string("infotext", "Chest (" .. owner .. ")")
            new_meta:get_inventory():add_item("main", "xpanes:door_steel_bar")

            core.log("action", "[Expire] Replaced xpanes steel door of " .. owner .. " at " .. core.pos_to_string(pos))
        end
    end
})

core.register_abm({
    nodenames = {
        "doors:trapdoor_steel",
        "doors:trapdoor_steel_open"
    },
    interval = 10,
    chance = 1,

    action = function(pos, node)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")

        if expired_players[owner] then
            local inv = meta:get_inventory()
            core.set_node(pos, {name = "default:chest", param2 = node.param2})

            local new_meta = core.get_meta(pos)
            new_meta:set_string("infotext", "Chest (" .. owner .. ")")
            new_meta:get_inventory():add_item("main", "doors:trapdoor_steel")

            core.log("action", "[Expire] Replaced steel door of " .. owner .. " at " .. core.pos_to_string(pos))
        end
    end
})

core.register_abm({
    nodenames = {
        "xpanes:trapdoor_steel_bar",
        "xpanes:trapdoor_steel_bar_open"
    },
    interval = 10,
    chance = 1,

    action = function(pos, node)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")

        if expired_players[owner] then
            local inv = meta:get_inventory()
            core.set_node(pos, {name = "default:chest", param2 = node.param2})

            local new_meta = core.get_meta(pos)
            new_meta:set_string("infotext", "Chest (" .. owner .. ")")
            new_meta:get_inventory():add_item("main", "xpanes:trapdoor_steel_bar")

            core.log("action", "[Expire] Replaced xpanes steel door of " .. owner .. " at " .. core.pos_to_string(pos))
        end
    end
})

local teleporter = "tech:teleporter"
core.register_abm({
    nodenames = {teleporter},
    interval = 10,
    chance = 1,

    action = function(pos, node)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")

        if expired_players[owner] then
            local inv = meta:get_inventory()
            local items = {}

            for _, list in ipairs({"locator", "core", "source"}) do
                local inv_list = inv:get_list(list)
                if inv_list then
                    for _, item in ipairs(inv_list) do
                        table.insert(items, item)
                    end
                end
            end

            core.set_node(pos, {name = "default:chest", param2 = node.param2})

            local new_meta = core.get_meta(pos)
            new_meta:set_string("infotext", "Chest (" .. owner .. ")")
            new_meta:get_inventory():set_list("main", items)
            new_meta:get_inventory():add_item("main", teleporter)

            core.log("action", "[Expire] Replaced teleporter of " .. owner .. " at " .. core.pos_to_string(pos))
        end
    end
})

local inactivity_time = 1800 -- 2.5 m
local function check_players()
    local auth_handler = core.get_auth_handler()

    if auth_handler and auth_handler.iterate then
        for name, auth_entry in auth_handler:iterate() do
            local player = core.get_player_by_name(name)
            if player then
                local meta = player:get_meta()
                local last_login = meta:get_string("exp_last_login")
                if last_login and last_login ~= "" then
                    local ll_time = tonumber(last_login)
                    if ll_time then
                        local duration = (os.time() - ll_time) / 3600
                        if duration >= inactivity_time then
                            save_player(name, true)
                            meta:set_string("exp_last_login", "")
                            core.log("action", "[Expire] Player "..name.." has been automatically expired after " 
                                ..math.floor(duration).." hours of inactivity.")
                        end
                    end
                end
            end
        end
    end
end

local timer = 0
core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 1 then
        check_players()
        timer = 0
    end
end)