local MAX_INACTIVITY_DAYS = tonumber(core.settings:get("ghost_purge_max_inactivity")) or 90

local xban_exists = core.global_exists("xban")
local beds_exists = core.global_exists("beds")

local function is_targetted(targetted_name)
    if core.get_player_privs(targetted_name).server then
        return false
    end
    if xban_exists then
        for _, v in ipairs(xban.db) do
            for name, _ in pairs(v.names) do
                if name == targetted_name and v.banned == true then -- Don't delete banned players
                    return false
                end
            end
        end
    end
    return true
end

local function get_inactive_list()
    local auth_handler = core.get_auth_handler()
    local inactive_players = {}
    if auth_handler then
        for name in auth_handler.iterate() do
            if is_targetted(name) then
                local player_auth = auth_handler.get_auth(name)
                if player_auth.last_login and player_auth.last_login > 0 then
                    local duration_days = (os.time() - player_auth.last_login) / 86400
                    if duration_days > MAX_INACTIVITY_DAYS then
                        table.insert(inactive_players, name)
                    end
                end
            end
        end
    end
    return inactive_players
end

local function clear_beds(name)
    if beds_exists and beds.spawn[name] then
        beds.spawn[name] = nil
    end
end

local function remove_inactive_players()
    local inactive_players = get_inactive_list()
    for _, name in ipairs(inactive_players) do
        local output = core.remove_player(name)
        if output == 0 then
            core.remove_player_auth(name)
            clear_beds(name)
            core.log("[GHOST Purge] The player ".. name .. " was removed from the database")
        end
    end
    if beds_exists then
        beds.save_spawns()
    end
end

core.after(0, function()
    remove_inactive_players()
end)

dofile(core.get_modpath(core.get_current_modname()) .. "/block_modifier.lua")