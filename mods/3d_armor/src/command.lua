if not core.get_modpath("sfinv") then
    core.register_chatcommand("armor_gui", {
        description = "Open 3D Armor GUI",
        privs = {interact = true},	
        func = function(name)
            armor:show_formspec(name)
        end
    })
end