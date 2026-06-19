local NODE_USED = "default:chest"
local S = core.get_translator("ghost_purge")

local function unlock_chests(pos, node, oldinfotext, items)
    core.set_node(pos, {name = NODE_USED, param2 = node.param2 or 0})
    core.sound_play("ghost_purge_unlock_chest", {pos = pos,max_hear_distance = 16})
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    meta:set_string("infotext", oldinfotext .. " (" .. S("Unlocked") .. ")")
    inv:set_list("main", items)
    if inv:room_for_item("main", "default:steel_ingot") then
        inv:add_item("main", "default:steel_ingot")
    end
end

local function unlock_protected_nodes(pos, node, oldnode, owner, items)
    core.set_node(pos, {name = NODE_USED, param2 = node.param2 or 0})
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    meta:set_string("infotext", meta:get_string("infotext") .. (" (%s)"):format(owner))
    if items ~= nil then
        inv:set_list("main", items)
    end
    inv:add_item("main", oldnode)
end

core.register_abm({
    label = "Unlock chests",
    nodenames = {
        "default:chest_locked",
        "pex:mailbox"
    },
    interval = 10.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= "" and core.get_auth_handler().get_auth(owner) == nil then
            unlock_chests(pos, node, meta:get_string("infotext"), meta:get_inventory():get_list("main"))
        end
    end
})

core.register_abm({
    label = "Remove protectors",
    nodenames = {
        "pex:protector",
        "pex:protector2"
    },
    interval = 10.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= "" and core.get_auth_handler().get_auth(owner) == nil then
            core.set_node(pos, {name = "air"})
        end
    end
})

core.register_abm({
    label = "Remove steel doors",
    nodenames = {
        "doors:door_steel_a",
        "doors:door_steel_b",
        "doors:door_steel_c",
        "doors:door_steel_d"
    },
    interval = 10.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= "" and core.get_auth_handler().get_auth(owner) == nil then
            unlock_protected_nodes(pos, node, "doors:door_steel", owner)
        end
    end
})

core.register_abm({
    label = "Remove xpanes steel doors",
    nodenames = {
        "xpanes:door_steel_bar_a",
        "xpanes:door_steel_bar_b",
        "xpanes:door_steel_bar_c",
        "xpanes:door_steel_bar_d"
    },
    interval = 10.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= "" and core.get_auth_handler().get_auth(owner) == nil then
            unlock_protected_nodes(pos, node, "xpanes:door_steel_bar", owner)
        end
    end
})

core.register_abm({
    label = "Remove steel trapdoors",
    nodenames = {
        "doors:trapdoor_steel",
        "doors:trapdoor_steel_open"
    },
    interval = 10.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= "" and core.get_auth_handler().get_auth(owner) == nil then
            unlock_protected_nodes(pos, node, "doors:trapdoor_steel", owner)
        end
    end
})

core.register_abm({
    label = "Remove xpanes steel trapdoors",
    nodenames = {
        "xpanes:trapdoor_steel_bar",
        "xpanes:trapdoor_steel_bar_open"
    },
    interval = 10.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= "" and core.get_auth_handler().get_auth(owner) == nil then
            unlock_protected_nodes(pos, node, "xpanes:trapdoor_steel_bar", owner)
        end
    end
})

core.register_abm({
    label = "Remove teleporters",
    nodenames = {"tech:teleporter"},
    interval = 10.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local meta = core.get_meta(pos)
        local owner = meta:get_string("owner")
        if owner ~= "" and core.get_auth_handler().get_auth(owner) == nil then
            local items = {}
            for _, list in ipairs({"locator", "core", "source"}) do
                local inv_list = meta:get_inventory():get_list(list)
                if inv_list then
                    for _, item in ipairs(inv_list) do
                        table.insert(items, item)
                    end
                end
            end
            unlock_protected_nodes(pos, node, "tech:teleporter", owner, items)
        end
    end
})
