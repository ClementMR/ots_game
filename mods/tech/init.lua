function main_form(player, pos)
    local spos = pos.x .. "," .. pos.y .. "," .. pos.z
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local locators = {}

    for i = 1, 16 do
        local stack = inv:get_stack("locator", i)
        if not stack:is_empty() then
            local name = stack:get_meta():get_string("locator_name")
            if name and name ~= "" then
                table.insert(locators, name)
            else
                table.insert(locators, "Error")
            end
        else
            table.insert(locators, "Empty")
        end
    end

    local form =
        "formspec_version[4]"..
        "size[15.62,11.30]"..
        "no_prepend[]"..
        "list[nodemeta:" .. spos .. ";locator;0.35,0.125;4,4;]"..
        "list[nodemeta:" .. spos .. ";core;0.35,5.40;1,4;]"..
        "list[nodemeta:" .. spos .. ";source;14.25,5.40;1,1;]"..
        "list[current_player;main;2.74,5.40;8.0,1;]"..
        "list[current_player;main;2.74,6.75;8.0,3;8]"..
        "button[0.35,10.40;2.30,0.70;tp_settings;Settings]"..
        "button_exit[5.20,10.38;2.30,0.70;tp_exit;Exit]"..
        "button_exit[7.70,10.38;2.30,0.70;teleport;Teleport]"..
        "table[5.20,0.125;10.30,4.725;teleporter_poi;"..table.concat(locators, ",").."]"..
        "listring[nodemeta:" .. spos .. ";locator]"..
        "listring[current_player;main]"

    core.show_formspec(player:get_player_name(), "tech:teleporter_" .. core.pos_to_string(pos), form)
end

function settings_form(pos, player)
    local meta = core.get_meta(pos)
    if not default.can_interact_with_node(player, pos) or (meta:get_string("owner") == "" 
        and not core.check_player_privs(player, {protection_bypass=true})) then
        return
    end

    local core_stacks = {
        meta:get_inventory():get_stack("core", 1),
        meta:get_inventory():get_stack("core", 2),
        meta:get_inventory():get_stack("core", 3),
        meta:get_inventory():get_stack("core", 4),
    }

    local count = 0
    for _, stack in ipairs(core_stacks) do
        if not stack:is_empty() and stack:get_name() == "tech:core" then
            count = count + 1
        end
    end

    local range = {
        [0] = 2000,
        [1] = 4000,
        [2] = 8000,
        [3] = 16000,
        [4] = 20000,
    }

    local max_distance = range[count] or 2000

    local current_mode = meta:get_string("teleport_mode") or "private"
    local form = 
        "formspec_version[4]"..
        "size[8.0,4.0]"..
        "label[0.5,0.5;Select teleportation mode:]"..
        "dropdown[0.5,1.5;7.0;teleport_mode;private,protected,public;"..
        (current_mode == "private" and 1 or current_mode == "protected" and 2 or 3).."]"..
        "label[0.5,3.0;Range: " .. max_distance .. "]"..
        "button_exit[3.0,3.0;2.0,0.75;save_settings;Save]"

    core.show_formspec(player:get_player_name(), "tech:teleporter_settings_" .. core.pos_to_string(pos), form)
end

function teleporter(pos, player)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local player_meta = player:get_meta()
    local selected_dest = player_meta:get_string("selected_dest") ; if selected_dest == "" then selected_dest = nil end
    local mode = meta:get_string("teleport_mode") or "private"
    local name = player:get_player_name()

    if mode == "private" and meta:get_string("owner") ~= name then
        core.chat_send_player(name, "Unable to teleport: This teleporter is private.")
        core.log("action", name.." tried to teleport to "..core.pos_to_string(pos).." but it is private.")
        return
    elseif mode == "protected" and core.is_protected(pos, name) then
        core.chat_send_player(name, "Unable to teleport: This teleporter is protected.")
        core.log("action", name.." tried to teleport to "..core.pos_to_string(pos).." but it is protected.")
        return
    end

    if selected_dest then
        local locator_stack = inv:get_stack("locator", selected_dest)
        local source_stack = inv:get_stack("source", 1)
        local item_pos = locator_stack:get_meta():get_string("pos")
        local core_stacks = {
            inv:get_stack("core", 1), 
            inv:get_stack("core", 2), 
            inv:get_stack("core", 3),
            inv:get_stack("core", 4)
        }

        if item_pos ~= "" and not locator_stack:is_empty() and locator_stack:get_name() == "tech:locator" then
            local distance = vector.distance(vector.new(pos), core.string_to_pos(item_pos))
            if distance <= 20000 then
                local required_source = math.max(1, math.ceil(distance / 200))
                local required_core = 0

                if distance > 2000 then required_core = 1 end
                if distance > 4000 then required_core = 2 end
                if distance > 8000 then required_core = 3 end
                if distance > 16000 then required_core = 4 end

                local count = 0
                for _, stack in ipairs(core_stacks) do
                    if not stack:is_empty() and stack:get_name() == "tech:core" then
                        count = count + 1
                    end
                end

                -- Check if there are enough cores
                if count >= required_core then
                    local wielded_stack = player:get_wielded_item()
                    local has_infinite_source = (source_stack:get_name() == "tech:infinite_source" or wielded_stack:get_name() == "tech:infinite_source")
                    local has_enough_sources = (source_stack:get_name() == "tech:source" and source_stack:get_count() >= required_source)
                    local has_enough = (
                        (wielded_stack:get_name() == "tech:source" or wielded_stack:get_name() == "default:coalblock") 
                        and wielded_stack:get_count() >= required_source
                    )

                    -- Check if there are enough sources
                    if has_infinite_source or has_enough_sources or has_enough then
                        if not has_infinite_source then
                            if has_enough_sources then
                                source_stack:set_count(source_stack:get_count() - required_source)
                                inv:set_stack("source", 1, source_stack)
                            elseif has_enough then
                                wielded_stack:set_count(wielded_stack:get_count() - required_source)
                                player:set_wielded_item(wielded_stack)
                            end
                        end

                        player:set_pos(core.string_to_pos(item_pos))
                        core.chat_send_player(name, "Teleport to "..item_pos.." complete")
                        core.log("action", name.." teleported to "..item_pos)

                        core.after(0.2, function()
                            core.add_particlespawner({
                                amount = 15,
                                time = 0.5,
                                collision_removal = true,
                                texture = "tech_teleporter_particles.png",
                                glow = 10,
                                minpos = player:get_pos(),
                                maxpos = player:get_pos(),
                                minvel = {x=-3, y=0, z=-3},
                                maxvel = {x=3, y=5, z=3},
                                minacc = {x=0, y=2, z=0},
                                maxacc = {x=0, y=4, z=0},
                                minexptime = 0.5,
                                maxexptime = 1,
                                minsize = 2,
                                maxsize = 3,
                            })
                        end)
                    else
                        if required_source > 1 then
                            core.chat_send_player(name, "Unable to teleport: You need to hold "
                                ..required_source.." coal blocks or sources in your hand to teleport.")
                        else
                            core.chat_send_player(name, "Unable to teleport: You need to hold "
                                ..required_source.." coal block or source in your hand to teleport.")
                        end
                    end
                else
                    core.chat_send_player(name, "Unable to teleport: Not enough core. Missing: "..(required_core-count))
                end
            else
                core.chat_send_player(name, "Unable to teleport: Too far away.")
            end
        else
            core.chat_send_player(name, "Unable to teleport: Empty slot selected.")
        end
    else
        core.chat_send_player(name, "Unable to teleport: No destination selected.")
    end
end

core.register_node("tech:teleporter", {
    description = "Teleporter",
    tiles = {"tech_teleporter.png"},
    groups = {cracky = 1, level = 3},
    paramtype2 = "facedir", 
    is_ground_content = false,
    sounds = default.node_sound_stone_defaults(),
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()

        meta:set_string("infotext", "Teleporter")
        meta:set_string("owner", "")
        inv:set_size("locator", 16)
        inv:set_size("core", 4)
        inv:set_size("source", 1)
    end,

    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = core.get_meta(pos)

        meta:set_string("owner", placer:get_player_name() or "")
        meta:set_string("infotext", "Teleporter (owned by "..meta:get_string("owner")..")")
    end,

    can_dig = function(pos, player)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()

        return inv:is_empty("locator") and inv:is_empty("core") and inv:is_empty("source") and
                default.can_interact_with_node(player, pos)
    end,

    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        local meta = core.get_meta(pos)

        if not default.can_interact_with_node(player, pos) 
            or (meta:get_string("owner") == "" and not 
            core.check_player_privs(player, {protection_bypass=true})) then
            return 0
        end
        return count
    end,

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local meta = core.get_meta(pos)

        if not default.can_interact_with_node(player, pos) 
            or (meta:get_string("owner") == "" and not 
            core.check_player_privs(player, {protection_bypass=true})) then
            return 0
        end
        return stack:get_count()
    end,

    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        local meta = core.get_meta(pos)

        if not default.can_interact_with_node(player, pos) 
            or (meta:get_string("owner") == "" and not 
            core.check_player_privs(player, {protection_bypass=true})) then
            return 0
        end
        return stack:get_count()
    end,

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        main_form(clicker, pos)
    end,

    on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        main_form(player, pos)
    end,

    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        main_form(player, pos)
    end,

    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        main_form(player, pos)
    end,

    on_blast = function() end,
})

core.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    local stack = player:get_wielded_item()
    local player_meta = player:get_meta()

    if string.sub(formname, 0, 16) == "tech:teleporter_" then
        local pos_s = string.sub(formname, 17)
        local pos = core.string_to_pos(pos_s)

        if fields.teleporter_poi then
            player_meta:set_string("selected_dest", string.match(fields.teleporter_poi, "%d+"))
        end

        if fields.teleport then
            teleporter(pos, player)
        end

        if fields.tp_settings then
            settings_form(pos, player)
        end

        if fields.quit then
            player_meta:set_string("selected_dest", "")
        end
    end

    if string.sub(formname, 0, 25) == "tech:teleporter_settings_" then
        local pos_s = string.sub(formname, 26)
        local pos = core.string_to_pos(pos_s)
        local meta = core.get_meta(pos)

        local mode = fields.teleport_mode
        if mode then
            meta:set_string("teleport_mode", mode)
        end
    end

    if formname == "tech:blank_locator" and fields.save_locator then
        if stack:get_name() == "tech:blank_locator" then
            local meta = stack:get_meta()
            local pos_str = meta:get_string("pos")
            local dest_name = '"Unknown"'

            if fields.locator_name ~= "" then dest_name = '"'..fields.locator_name..'"' end

            local new_stack = ItemStack("tech:locator")
            new_stack:get_meta():set_string("locator_name", dest_name)
            new_stack:get_meta():set_string("pos", pos_str)
            new_stack:get_meta():set_string("owner", player:get_player_name())

            player:set_wielded_item(new_stack)
            core.chat_send_player(name, "Locator saved as: "..dest_name)
            core.log("action", name.." saved locator as "..dest_name.." at "..pos_str)
        end
    end

    if formname == "tech:locator" and fields.resave_locator then
        if stack:get_name() == "tech:locator" then
            local meta = stack:get_meta()
            local pos_str = meta:get_string("pos")
            local dest_name = '"Unknown"'

            if fields.locator_name ~= "" then dest_name = '"'..fields.locator_name..'"' end

            local new_stack = ItemStack("tech:locator")
            new_stack:get_meta():set_string("locator_name", dest_name)
            new_stack:get_meta():set_string("pos", pos_str)
            new_stack:get_meta():set_string("owner", player:get_player_name())

            player:set_wielded_item(new_stack)

            core.chat_send_player(name, "Locator saved as: "..dest_name)
            core.log("action", name.." saved locator as "..dest_name.." at "..pos_str)
        end
    end

    if formname == "tech:locator" and fields.clear_locator then
        if stack:get_name() == "tech:locator" then
            local new_stack = ItemStack("tech:blank_locator")
            player:set_wielded_item(new_stack)

            core.log("action", name.." cleared a locator.")
        end
    end
end)

core.register_craftitem("tech:advanced_combination", {
    description = "Advanced Combination",
    inventory_image = "default_obsidian_shard.png",
    stack_max = 2,
})

core.register_craftitem("tech:advanced_component", {
    description = "Advanced Component",
    inventory_image = "default_obsidian_shard.png",
    stack_max = 2,
})

core.register_craftitem("tech:basic_combination", {
    description = "Basic Combination",
    inventory_image = "default_obsidian_shard.png",
    stack_max = 4,
})

core.register_craftitem("tech:basic_component", {
    description = "Basic Component",
    inventory_image = "default_obsidian_shard.png",
    stack_max = 4,
})

core.register_craftitem("tech:blank_locator", {
    description = "Blank Locator",
    inventory_image = "default_obsidian_shard.png",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "node" then
            local pos = pointed_thing.above
            local name = user:get_player_name()
            local meta = itemstack:get_meta()

            local form = 
                "formspec_version[4]"..
                "size[8.0,4.0]"..
                "field[1.0,1.0;6.0,1.0;locator_name;Name:;]"..
                "label[1.0,2.5;Position: "..core.pos_to_string(pos).."]"..
                "button_exit[3.0,3.0;2.25,0.75;save_locator;Save]"

            core.show_formspec(name, "tech:blank_locator", form)

            meta:set_string("pos", core.pos_to_string(pos))

            return itemstack
        end
    end,
})

core.register_craftitem("tech:core", {
    description = "Core",
    inventory_image = "default_obsidian.png",
    stack_max = 1,
})

core.register_craftitem("tech:infinite_source", {
    description = "Infinite Source",
    inventory_image = "default_mese_crystal_fragment.png",
    stack_max = 1,
})

core.register_craftitem("tech:locator", {
    description = "Locator",
    inventory_image = "default_obsidian_shard.png",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        local meta = itemstack:get_meta()

        local pos = meta:get_string("pos") ; if pos == "" then pos = "???" end
        local loc_name = meta:get_string("locator_name") ; if loc_name == "" then loc_name = "???" end
        local owner = meta:get_string("owner") ; if owner == "" then owner = "???" end

        core.chat_send_player(name, "Locator: "..loc_name.." at "..pos.."\n"
            .."(owned by "..owner..")")

        return itemstack
    end,

    on_secondary_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        local meta = itemstack:get_meta()

        local form = 
            "formspec_version[4]"..
            "size[8.0,4.0]"..
            "field[1.0,1.0;6.0,1.0;locator_name;Name:;"..(meta:get_string("locator_name") or "Unknown").."]"..
            "button_exit[2.5,3.0;1.5,0.75;resave_locator;Save]"..
            "button_exit[4.4,3.0;1.5,0.75;clear_locator;Clear]"

        if meta:get_string("owner") == "" or meta:get_string("owner") == name then
            core.show_formspec(name, "tech:locator", form)
        else
            core.chat_send_player(name, "You cannot edit this locator.")
        end

        return itemstack
    end,
})

core.register_craftitem("tech:source", {
    description = "Source",
    inventory_image = "default_mese_crystal_fragment.png",
    stack_max = 8000,
})

dofile(core.get_modpath("tech").."/recipes.lua")

print ("[MOD] Tech [521] loaded")