-- Areas mod by ShadowNinja
-- Based on node_ownership
-- License: LGPLv2+

areas = {}

areas.factions_available = core.get_modpath("playerfactions") and true

areas.adminPrivs = {protection_bypass=true}
areas.startTime = os.clock()

areas.modpath = core.get_modpath("areas")
dofile(areas.modpath.."/settings.lua")
dofile(areas.modpath.."/api.lua")

local async_dofile = core.register_async_dofile or dofile
async_dofile(areas.modpath.."/async.lua")

dofile(areas.modpath.."/internal.lua")
dofile(areas.modpath.."/chatcommands.lua")
dofile(areas.modpath.."/pos.lua")
dofile(areas.modpath.."/interact.lua")
dofile(areas.modpath.."/legacy.lua")
dofile(areas.modpath.."/hud.lua")

areas:load()

print ("[MOD] Areas loaded")