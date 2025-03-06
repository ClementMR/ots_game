core.register_node("light:lamp", {
    description = "Lamp",
    drawtype = "glasslike_framed_optional",
    tiles = {"light_lamp.png"},
	paramtype = "light",
    light_source = 10,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})

core.register_craft({
    output = "light:lamp",
    recipe = {
        {"", "default:glass", ""},
        {"", "default:torch", ""},
        {"", "default:steel_ingot", ""}
    }
})

print ("[MOD] Light [521] loaded")