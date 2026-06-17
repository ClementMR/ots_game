local GOLDEN_APPLE_BONUS = 10
local GOLDEN_APPLE_DURATION = 120
local ACTIVE_KEY = "ots_main:golden_apple_active"
local BASE_HP_KEY = "ots_main:golden_apple_base_hp"
local EXPIRES_KEY = "ots_main:golden_apple_expires"

local function get_hp_max(player)
	return (player:get_properties() or {}).hp_max or 20
end

local function clear_golden_apple(player)
	local meta = player:get_meta()
	if meta:get_int(ACTIVE_KEY) ~= 1 then
		return
	end

	local base_hp = meta:get_int(BASE_HP_KEY)
	if base_hp <= 0 then
		base_hp = 20
	end
	player:set_properties({hp_max = base_hp})
	if player:get_hp() > base_hp then
		player:set_hp(base_hp, {type = "set_hp", cause = "ots_main:golden_apple_expire"})
	end
	meta:set_int(ACTIVE_KEY, 0)
	meta:set_int(BASE_HP_KEY, 0)
	meta:set_int(EXPIRES_KEY, 0)
end

local function apply_golden_apple(player)
	local meta = player:get_meta()
	local base_hp = meta:get_int(BASE_HP_KEY)
	if meta:get_int(ACTIVE_KEY) ~= 1 or base_hp <= 0 then
		base_hp = get_hp_max(player)
		meta:set_int(BASE_HP_KEY, base_hp)
	end

	local new_max = base_hp + GOLDEN_APPLE_BONUS
	player:set_properties({hp_max = new_max})
	player:set_hp(math.min(new_max, player:get_hp() + GOLDEN_APPLE_BONUS), {
		type = "set_hp",
		cause = "ots_main:golden_apple",
	})
	meta:set_int(ACTIVE_KEY, 1)
	meta:set_int(EXPIRES_KEY, core.get_gametime() + GOLDEN_APPLE_DURATION)
end

core.register_craftitem("ots_main:golden_apple", {
	description = "Golden Apple",
	inventory_image = "default_apple.png^[colorize:#FFD700:120",
	on_use = function(itemstack, user)
		if not user or not user:is_player() then
			return itemstack
		end
		apply_golden_apple(user)
		local name = user:get_player_name()
		if not core.is_creative_enabled(name) then
			itemstack:take_item()
		end
		return itemstack
	end,
})

core.register_craft({
	output = "ots_main:golden_apple",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
		{"default:gold_ingot", "default:apple", "default:gold_ingot"},
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
	},
})

core.register_globalstep(function()
	local now = core.get_gametime()
	for _, player in ipairs(core.get_connected_players()) do
		local meta = player:get_meta()
		local expires = meta:get_int(EXPIRES_KEY)
		if meta:get_int(ACTIVE_KEY) == 1 and expires > 0 and now >= expires then
			clear_golden_apple(player)
		end
	end
end)

core.register_on_dieplayer(function(player)
	clear_golden_apple(player)
end)

core.register_on_joinplayer(function(player)
	core.after(0, clear_golden_apple, player)
end)