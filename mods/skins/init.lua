-- Copyright (c) 2012 cornernote, Dean Montgomery
-- Rework 2017 by bell07
-- License: GPLv3

skins = {}
skins.modpath = core.get_modpath(core.get_current_modname())
skins.default = "character"
skins.armor_loaded = false

dofile(skins.modpath .. "/skin_meta_api.lua")
dofile(skins.modpath .. "/api.lua")
dofile(skins.modpath .. "/skinlist.lua")
dofile(skins.modpath .. "/chatcommands.lua")

-- 3d_armor compatibility
if core.global_exists("armor") then
	skins.armor_loaded = true

	armor.update_player_visuals = function(self, player)
		if not player then
			return
		end
		local skin = skins.get_player_skin(player)
		skin:apply_skin_to_player(player)
		armor:run_callbacks("on_update", player)
	end
end

-- Update skin on join
core.register_on_joinplayer(function(player)
	skins.update_player_skin(player)
end)

-- Register default character.png if not part of this mod
local default_skin_obj = skins.get(skins.default)
if not default_skin_obj then
	default_skin_obj = skins.new(skins.default)
	default_skin_obj:set_texture("character.png")
	default_skin_obj:set_meta("_sort_id", 0)
	default_skin_obj:set_meta("name", "Sam")
end