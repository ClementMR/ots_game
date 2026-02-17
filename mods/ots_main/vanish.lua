local STR = "ots_main:vanished"

-- Check if armor module is available
local armor_available = core.global_exists("armor")

local function get_vanish(player)
    return player:get_meta():get_string(STR) == "true"
end

local function set_vanish(player, value)
    player:get_meta():set_string(STR, value)
end

local function unvanish_player(player)
    player:set_properties({
        pointable = true,
        visual_size = {x = 1, y = 1},
        is_visible = true,
        makes_footstep_sound = true,
        show_on_minimap = true
    })
    player:set_nametag_attributes({text = player:get_player_name(), color = {a=255, r=255, g=255, b=255}})
    set_vanish(player, "false")
    core.chat_send_player(player:get_player_name(), "You are now unvanished!")
end

local function clear_properties(player)
    player:set_properties({
        pointable = false,
        visual_size = {x = 0, y = 0},
        is_visible = false,
        makes_footstep_sound = false,
        show_on_minimap = false
    })
    player:set_nametag_attributes({text = " ", color = {a=0, r=0, g=0, b=0}})
end

local function vanish_player(player)
    if get_vanish(player) then
        unvanish_player(player)
        return
    end
    clear_properties(player)
    set_vanish(player, "true")
    core.chat_send_player(player:get_player_name(), "You are now vanished!")
end

if armor_available then
    armor:register_on_update(function(player)
        local status = get_vanish(player)
        if status == true then
            clear_properties(player)
        end
    end)
end

core.register_chatcommand("vanish", {
    description = "Toggle the vanish state for a player or yourself",
    privs = {server=true},
    func = function(name, param)
        if param ~= "" then
            local targetted_player = core.get_player_by_name(param)
            if targetted_player then
                vanish_player(targetted_player)
                return true
            else
                return false, ("The player %s doesn't exists or is not online..."):format(param)
            end
        end
        local player = core.get_player_by_name(name)
        vanish_player(player)
    end
})

core.register_on_respawnplayer(function(player)
    local status = get_vanish(player)
    if status == true then
        clear_properties(player)
    end
end)

core.register_on_leaveplayer(function(player)
    if get_vanish(player) then
        set_vanish(player, "false")
    end
end)