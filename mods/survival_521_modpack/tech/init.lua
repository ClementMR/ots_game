function teleporter_form(player, pos)
    local spos = pos.x .. "," .. pos.y .. "," .. pos.z

    local meta = core.get_meta(pos) ; if not meta then return end

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

    local poi = table.concat(locators, ",")

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
        "table[5.20,0.125;10.30,4.725;teleporter_poi;"..poi.."]"..
        "listring[nodemeta:" .. spos .. ";locator]"..
        "listring[current_player;main]"

    core.show_formspec(player:get_player_name(),
            "tech:teleporter_" .. core.pos_to_string(pos), form)
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
        teleporter_form(clicker, pos)
    end,

    on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        teleporter_form(player, pos)
    end,

    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        teleporter_form(player, pos)
    end,

    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        teleporter_form(player, pos)
    end,

    on_blast = function() end,
})

core.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    local stack = player:get_wielded_item()

    if string.sub(formname, 0, 16) == "tech:teleporter_" then

        local pos_s = string.sub(formname, 17)
        local pos = core.string_to_pos(pos_s)

        local meta = core.get_meta(pos) ; if not meta then return end
        local inv = meta:get_inventory() ; if not inv then return end

        local player_meta = player:get_meta()
        local selected_dest = player_meta:get_string("selected_dest") ; if selected_dest == "" then selected_dest = nil end

        if fields.teleporter_poi then
            player_meta:set_string("selected_dest", string.match(fields.teleporter_poi, "%d+"))
        end

        if fields.teleport then
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
                    if distance <= 16000 then
                        local required_sources = math.max(1, math.ceil(distance / 200))
                        local required_cores = 0

                        if distance > 1000 then required_cores = 1 end
                        if distance > 2000 then required_cores = 2 end
                        if distance > 4000 then required_cores = 3 end
                        if distance > 8000 then required_cores = 4 end

                        local count = 0
                        for _, stack in ipairs(core_stacks) do
                            if not stack:is_empty() and stack:get_name() == "tech:core" then
                                count = count + 1
                            end
                        end

                        -- Check if there are enough cores
                        if count >= required_cores then

                            local wielded_stack = player:get_wielded_item()
                            local has_infinite_source = (source_stack:get_name() == "tech:infinite_source" or wielded_stack:get_name() == "tech:infinite_source")
                            local has_enough_sources = (source_stack:get_name() == "tech:source" and source_stack:get_count() >= required_sources)
                            local has_enough_in_hand = (wielded_stack:get_name() == "tech:source" and wielded_stack:get_count() >= required_sources)

                            -- Check if there are enough sources
                            if has_infinite_source or has_enough_sources or has_enough_in_hand then
                                if not has_infinite_source then
                                    if has_enough_sources then
                                        source_stack:set_count(source_stack:get_count() - required_sources)
                                        inv:set_stack("source", 1, source_stack)
                                    elseif has_enough_in_hand then
                                        wielded_stack:set_count(wielded_stack:get_count() - required_sources)
                                        player:set_wielded_item(wielded_stack)
                                    end
                                end

                                player:set_pos(core.string_to_pos(item_pos))
                                core.chat_send_player(name, "Teleport to "..item_pos.." complete")

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
                                core.chat_send_player(name, "You need to hold "
                                    ..required_sources.." sources in your hand or have them in the source slot.")
                            end
                        else
                            core.chat_send_player(name, "Unable to teleport: Not enough core. Missing: "
                            ..(required_cores-count))
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

        if fields.tp_settings then
            if not default.can_interact_with_node(player, pos) or (meta:get_string("owner") == "" 
                and not core.check_player_privs(player, {protection_bypass=true})) then
                return
            end

            core.chat_send_player(name, "Error: This feature is not implemented yet")
        end

        if fields.quit then
            player_meta:set_string("selected_dest", "")
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

            player:set_wielded_item(new_stack)
            core.chat_send_player(name, "Locator saved as: "..dest_name)
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

            player:set_wielded_item(new_stack)

            core.chat_send_player(name, "Locator saved as: "..dest_name)
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

        local pos = meta:get_string("pos") ; if pos == "" then loc_name = "???" end
        local loc_name = meta:get_string("locator_name") ; if loc_name == "" then loc_name = "???" end

        core.chat_send_player(name, "Locator: "..loc_name.." at "..pos)

        return itemstack
    end,

    on_secondary_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        local meta = itemstack:get_meta()

        local form = 
            "formspec_version[4]"..
            "size[8.0,4.0]"..
            "field[1.0,1.0;6.0,1.0;locator_name;Name:;"..(meta:get_string("locator_name") or "Unknown").."]"..
            "button_exit[3.0,3.0;2.25,0.75;resave_locator;Re-Save]"

        core.show_formspec(name, "tech:locator", form)

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