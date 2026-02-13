local path = core.get_modpath("mobs")

dofile(path .. "/api.lua") -- mob API

-- Monsters

dofile(path .. "/monsters/dirt_monster.lua")
dofile(path .. "/monsters/dungeon_master.lua")
dofile(path .. "/monsters/lava_flan.lua")
dofile(path .. "/monsters/oerkki.lua")
dofile(path .. "/monsters/sand_monster.lua")
--dofile(path .. "/monsters/spider.lua")
dofile(path .. "/monsters/stone_monster.lua")
dofile(path .. "/monsters/tree_monster.lua")

print ("[MOD] Mobs API loaded")