local S = core.get_translator("areas")

local old_is_protected = core.is_protected
function core.is_protected(pos, name)
	if not areas:canInteract(pos, name) then
		return true
	end
	return old_is_protected(pos, name)
end

core.register_on_protection_violation(function(pos, name)
	if not areas:canInteract(pos, name) then
		core.chat_send_player(name, core.pos_to_string(pos).." is protected")
	end
end)

core.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if not areas:canInteract(player:get_pos(), hitter:get_player_name()) then
		core.chat_send_player(hitter:get_player_name(), "You can't attack here")
		return true
	end
end)