local selected_destination = {}

local MAXIMUM_DISTANCE = 20000
local C = core.colorize

local function validate_setting(setting, default)
    if setting ~= nil then
        return setting
    end
    return default
end

local recipes_enabled = validate_setting(core.settings:get_bool("tech_enable_recipes"), true)

local slots = {
    locator = {["tech:locator"] = true},
    core = {["tech:core"] = true},
    source = {["tech:source"] = true, ["tech:infinite_source"] = true},
}

local function can_use_teleporter_inventory(player, pos)
    local meta = core.get_meta(pos)
    local name = player:get_player_name()

    return default.can_interact_with_node(player, pos)
        and (meta:get_string("owner") ~= "" or core.get_player_privs(name).protection_bypass)
end

local function stack_matches_list(listname, stack)
    local allowed = slots[listname]
    if not allowed then
        return false
    end

    return allowed[stack:get_name()] == true
end

local function show_teleporter_form(player, pos)
    local spos = pos.x .. "," .. pos.y .. "," .. pos.z
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local tp_mode = meta:get_string("teleport_mode")

    local destinations = {}
    for i = 1, 16 do
        local stack = inv:get_stack("locator", i)
        if not stack:is_empty() and stack:get_name() == "tech:locator" then
            local locator_name = stack:get_meta():get_string("locator_name")
            local locator_pos = stack:get_meta():get_string("pos")

            if locator_name and locator_pos then
                local string = locator_name

                if tp_mode == "" or (tp_mode and tp_mode == "public") then
                    string = string .. " " .. locator_pos
                end

                table.insert(destinations, core.formspec_escape(string))
            else
                table.insert(destinations, "Error")
            end
        else
            table.insert(destinations, "Empty")
        end
    end

    local form =
        "formspec_version[4]" ..
        "size[15.62,11.30]" ..
        "no_prepend[]" ..
        "bgcolor[#00000000]" ..
        "background[0,0;15.62,11.30;tech_teleporter_gui.png;true]" ..
        "listcolors[#5c646999;#7f878b99;#4dd8e866;#4dd8e8aa;#ffffff]" ..
        "style_type[label;font_size=16;textcolor=#d8e4e8]" ..
        "style_type[button,button_exit;border=false;font=bold;font_size=16;textcolor=#e8f6f8;" ..
            "bgimg=tech_gui_btn.png;bgimg_hovered=tech_gui_btn_hover.png;" ..
            "bgimg_pressed=tech_gui_btn_pressed.png;bgimg_middle=6]" ..
        "style[teleport;textcolor=#fff]" ..
        "tooltip[0.75,0.25;5,5;Locator slots: tech:locator;#32333899;#fff]" ..
        "tooltip[0.75,5.45;1,5;Core slots: tech:core;#32333899;#fff]" ..
        "tooltip[14.17,5.65;1,1;Source slot: tech:source;#32333899;#fff]" ..
        "tableoptions[background=#00000000;highlight=#4dd8e866;border=false]" ..
        "tablecolumns[text]" ..
        "list[nodemeta:" .. spos .. ";locator;0.75,0.25;4,4;]" ..
        "list[nodemeta:" .. spos .. ";core;0.75,5.45;1,4;]" ..
        "list[nodemeta:" .. spos .. ";source;14.17,5.65;1,1;]" ..
        "list[current_player;main;3.27,5.40;8.0,1;]" ..
        "list[current_player;main;3.27,6.75;8.0,3;8]" ..
        "button[0.35,10.38;2.30,0.70;settings_btn;Settings]" ..
        "button_exit[5.20,10.38;2.30,0.70;exit_btn;Exit]" ..
        "button_exit[7.70,10.38;2.30,0.70;teleport;Teleport]" ..
        "table[6,0.25;9.45,4.725;destinations;" .. table.concat(destinations, ",") .. "]" ..
        "listring[nodemeta:" .. spos .. ";locator]" ..
        "listring[current_player;main]"

    core.show_formspec(player:get_player_name(), "tech:teleporter_" .. spos, form)
end

local function teleporter_range(value)
    if value >= 4 then
        return MAXIMUM_DISTANCE
    end

    -- Default range
    local range = 2000

    if value == 0 then
        return range
    end

    for i=1, value do
        range = range * 2
    end

    return range
end


local function show_settings_form(player, pos)
    local spos = pos.x .. "," .. pos.y .. "," .. pos.z
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local name = player:get_player_name()

    -- Check if the player can interact with the node
    if not default.can_interact_with_node(player, pos) or (meta:get_string("owner") == ""
        and not core.get_player_privs(name).protection_bypass) then
        return
    end

    local count = 0
    for i=1, inv:get_size("core") do
        local stack = inv:get_stack("core", i)
        if not stack:is_empty() and stack:get_name() == "tech:core" then
            count = count + 1
        end
    end

    local current_mode = meta:get_string("teleport_mode") or "private"
    local form =
        "formspec_version[4]" ..
        "size[8.0,4.0]" ..
        "label[0.5,0.5;Select a mode :]" ..
        "dropdown[0.5,1.5;7.0;teleport_mode;private,protected,public;" ..
        ((current_mode == "private" and 1) or (current_mode == "protected" and 2) or 3) .. "]" ..
        "label[0.5,3.0;Range : " .. teleporter_range(count) .. "]" ..
        "button_exit[3.0,3.0;2.0,0.75;save_btn;Save]"

    core.show_formspec(player:get_player_name(), "tech:teleporter_settings_" .. spos, form)
end

local function teleport_player(player, pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local mode = meta:get_string("teleport_mode") or "private"
    local name = player:get_player_name()
    local owner = meta:get_string("owner")

    if not selected_destination or not selected_destination[name] then
        core.chat_send_player(name, "Unable to teleport : No destination selected.")
        return false
    end

    if name ~= owner then
        if mode == "private" then
            core.chat_send_player(name, ("Unable to teleport : This teleporter is private (Owner : %s)"):format(owner))
            return false
        elseif mode == "protected" and core.is_protected(pos, name) then
            core.chat_send_player(name, "Unable to teleport : This teleporter is protected.")
            return false
        end
    end

    local locator_stack = inv:get_stack("locator", selected_destination[name])
    local destination = locator_stack:get_meta():get_string("pos")

    if destination == "" or locator_stack:is_empty() or locator_stack:get_name() ~= "tech:locator" then
        core.chat_send_player(name, "Unable to teleport: Empty slot selected.")
        return false
    end

    local distance = vector.distance(vector.new(pos), core.string_to_pos(destination))
    if distance > MAXIMUM_DISTANCE then
        core.chat_send_player(name, "Unable to teleport: Too far away.")
        return false
    end

    local required_core = 0
    if distance > 2000 then required_core = 1 end
    if distance > 4000 then required_core = 2 end
    if distance > 8000 then required_core = 3 end
    if distance > 16000 then required_core = 4 end

    local count = 0
    for i=1, inv:get_size("core") do
        local stack = inv:get_stack("core", i)
        if not stack:is_empty() and stack:get_name() == "tech:core" then
            count = count + 1
        end
    end

    -- Check if there are enough cores
    if count < required_core then
        core.chat_send_player(name, "Unable to teleport : Not enough core. Missing : " .. (required_core - count))
        return false
    end

    local wielded_stack = player:get_wielded_item()
    local source_stack = inv:get_stack("source", 1)
    local required_source = math.max(1, math.ceil(distance / 200))

    local has_infinite_source = source_stack:get_name() == "tech:infinite_source"
    or wielded_stack:get_name() == "tech:infinite_source"
    local has_enough_in_slot = source_stack:get_name() == "tech:source"
    and source_stack:get_count() >= required_source
    local has_enough_in_hand = (wielded_stack:get_name() == "tech:source"
    or wielded_stack:get_name() == "default:coalblock") and wielded_stack:get_count() >= required_source

    if not has_infinite_source and not has_enough_in_slot and not has_enough_in_hand then
        core.chat_send_player(name,
        ("Unable to teleport : You need to hold %d coal blocks or sources in your hand to teleport.")
        :format(required_source))
        return false
    end

    -- Consume the sources
    if not has_infinite_source then
        if has_enough_in_slot then
            source_stack:set_count(source_stack:get_count() - required_source)
            inv:set_stack("source", 1, source_stack)
        elseif has_enough_in_hand then
            wielded_stack:set_count(wielded_stack:get_count() - required_source)
            player:set_wielded_item(wielded_stack)
        end
    end

    -- Teleport the player
    player:set_pos(core.string_to_pos(destination))
    core.chat_send_player(name, "Teleport to " .. destination .. " complete")
    core.log("action", "[Teleporter] " .. name .. " teleported to " .. destination)

    -- Add particles
    core.add_particlespawner({
        amount = 20,
        time = 1,
        attached = player,
        texture = "tech_teleporter_yellow_particles.png",
        glow = 10,
        minvel = {x=-3, y=0, z=-3},
        maxvel = {x=3, y=5, z=3},
        minacc = {x=0, y=2, z=0},
        maxacc = {x=0, y=4, z=0},
        minsize = 2,
        maxsize = 3,
        minexptime = 0.5,
        maxexptime = 1,
    })

    core.add_particlespawner({
        amount = 20,
        time = 1,
        attached = player,
        texture = "tech_teleporter_blue_particles.png",
        glow = 10,
        minvel = {x=-3, y=0, z=-3},
        maxvel = {x=3, y=5, z=3},
        minacc = {x=0, y=2, z=0},
        maxacc = {x=0, y=4, z=0},
        minsize = 2,
        maxsize = 3,
        minexptime = 0.5,
        maxexptime = 1,
    })
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
        meta:set_string("infotext", "Teleporter (owned by " .. meta:get_string("owner") .. ")")
    end,
    can_dig = function(pos, player)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()

        if not default.can_interact_with_node(player, pos) then
            return false
        end

        if not inv:is_empty("source") or not inv:is_empty("core") or not inv:is_empty("locator") then
            return false
        end

        for _, list in ipairs({"locator", "core", "source"}) do
            for _, stack in pairs(inv:get_list(list)) do
                core.add_item(pos, stack)
            end
        end

        return true
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if not can_use_teleporter_inventory(player, pos) then
            return 0
        end

        local inv = core.get_meta(pos):get_inventory()
        local stack = inv:get_stack(from_list, from_index)

        if not stack_matches_list(to_list, stack) then
            return 0
        end

        return math.min(count, stack:get_count())
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if not can_use_teleporter_inventory(player, pos) or not stack_matches_list(listname, stack) then
            return 0
        end

        return stack:get_count()
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if not can_use_teleporter_inventory(player, pos) then
            return 0
        end

        return stack:get_count()
    end,
    on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        show_teleporter_form(player, pos)
    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing) show_teleporter_form(clicker, pos) end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player) show_teleporter_form(player, pos) end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player) show_teleporter_form(player, pos) end,
    on_blast = function() end,
})

local function set_string(string)
    if string ~= "" then
        return string
    end

    return "???"
end

core.register_craftitem("tech:locator", {
    description = "Locator",
    inventory_image = "tech_locator.png",
    stack_max = 1,
    groups = {not_in_creative_inventory=1},
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        local meta = itemstack:get_meta()
        local destination = set_string(meta:get_string("locator_name"))
        local owner = meta:get_string("owner")

        if owner and owner ~= name then
            core.chat_send_player(name, C("red", ("You cannot edit this locator. Owner : %s"):format(owner)))
            return
        end

        local form =
            "formspec_version[4]" ..
            "size[8.0,4.0]" ..
            "field[1.0,1.0;6.0,1.0;locator_name;Name :;" .. destination .. "]" ..
            "button_exit[2.5,3.0;1.5,0.75;resave_locator;Save]" ..
            "button_exit[4.4,3.0;1.5,0.75;clear_locator;Clear]"

        core.show_formspec(name, "tech:locator", form)

        return itemstack
    end,
    on_secondary_use = function(itemstack, user, pointed_thing)
        local meta = itemstack:get_meta()
        local destination = set_string(meta:get_string("locator_name"))
        local pos = set_string(meta:get_string("pos"))
        local owner = set_string(meta:get_string("owner"))

        core.chat_send_player(user:get_player_name(),
            ("Destination : %s %s | Owner : %s"):format(C("cyan", destination), pos, C("cyan", owner)))
    end
})

core.register_craftitem("tech:blank_locator", {
    description = "Blank Locator",
    inventory_image = "tech_blank_locator.png",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "node" then
            local pos = pointed_thing.above
            local meta = itemstack:get_meta()

            local form =
                "formspec_version[4]" ..
                "size[8.0,4.0]" ..
                "field[1.0,1.0;6.0,1.0;locator_name;Name :;]" ..
                "label[1.0,2.5;Position : " .. core.pos_to_string(pos) .. "]" ..
                "button_exit[3.0,3.0;2.25,0.75;save_locator;Save]"

            core.show_formspec(user:get_player_name(), "tech:blank_locator", form)

            -- Save the position as a metadata
            meta:set_string("pos", core.pos_to_string(pos))

            return itemstack
        end
    end,
})

local function save_locator(player, destination)
    local wielded_stack = player:get_wielded_item()
    local name = player:get_player_name()

    -- Check if the player is holding a locator
    if wielded_stack:get_name() == "tech:blank_locator"
    or wielded_stack:get_name() == "tech:locator" then
        local meta = wielded_stack:get_meta()
        local pos = meta:get_string("pos") or player:get_pos()

        local new_stack = ItemStack("tech:locator")
        new_stack:get_meta():set_string("locator_name", destination)
        new_stack:get_meta():set_string("pos", pos)
        new_stack:get_meta():set_string("owner", player:get_player_name())

        player:set_wielded_item(new_stack)
        core.chat_send_player(name, ("Locator saved as : %s"):format(C("cyan", destination)))
        core.log("action", "[Teleporter] " .. name .. " saved locator as " .. destination .. " at " .. pos)
    end
end

core.register_on_leaveplayer(function(player)
    if selected_destination[player:get_player_name()] then
        selected_destination[player:get_player_name()] = nil
    end
end)

core.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    local stack = player:get_wielded_item()

    if formname:sub(0, 16) == "tech:teleporter_" then
        local pos = core.string_to_pos(formname:sub(17))

        if fields.destinations then
            selected_destination[name] = core.explode_table_event(fields.destinations).row
        elseif fields.teleport then
            teleport_player(player, pos)
        elseif fields.settings_btn then
            show_settings_form(player, pos)
        end

        if fields.quit then
            selected_destination[name] = nil
        end
    end

    if formname:sub(0, 25) == "tech:teleporter_settings_" then
        local pos = core.string_to_pos(formname:sub(26))

        if fields.teleport_mode then
            core.get_meta(pos):set_string("teleport_mode", fields.teleport_mode)
        end

        if fields.save_btn then
            show_teleporter_form(player, pos)
        end
    end

    if formname == "tech:blank_locator" then
        if fields.save_locator and fields.locator_name ~= "" then
            save_locator(player, fields.locator_name)
        elseif fields.key_enter == "true" and fields.key_enter_field == "locator_name"
        and fields.locator_name ~= "" then
            save_locator(player, fields.locator_name)
        end
    end

    if formname == "tech:locator" then
        if fields.resave_locator and fields.locator_name ~= "" then
            save_locator(player, fields.locator_name)
        elseif fields.key_enter == "true" and fields.key_enter_field == "locator_name"
        and fields.locator_name ~= "" then
            save_locator(player, fields.locator_name)
        elseif fields.clear_locator then
            if stack:get_name() == "tech:locator" then
                local new_stack = ItemStack("tech:blank_locator")
                player:set_wielded_item(new_stack)
            end
        end
    end
end)

core.register_craftitem("tech:core", {
    description = "Core",
    inventory_image = "tech_core.png",
    stack_max = 1,
})

core.register_craftitem("tech:infinite_source", {
    description = "Infinite Source",
    inventory_image = "tech_infinite_source.png",
    stack_max = 1,
})

core.register_craftitem("tech:advanced_combination", {
    description = "Advanced Combination",
    inventory_image = "tech_advanced_combination.png",
    stack_max = 2,
})

core.register_craftitem("tech:advanced_component", {
    description = "Advanced Component",
    inventory_image = "tech_advanced_component.png",
    stack_max = 2,
})

core.register_craftitem("tech:basic_combination", {
    description = "Basic Combination",
    inventory_image = "tech_basic_combination.png",
    stack_max = 4,
})

core.register_craftitem("tech:basic_component", {
    description = "Basic Component",
    inventory_image = "tech_basic_component.png",
    stack_max = 4,
})

core.register_craftitem("tech:source", {
    description = "Source",
    inventory_image = "tech_source.png",
    stack_max = 8000,
})

if recipes_enabled then
    dofile(core.get_modpath(core.get_current_modname()) .. "/recipes.lua")
end

print ("[MOD] Tech loaded")