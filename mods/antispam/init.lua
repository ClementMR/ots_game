local PLAYERS_MSG = {}
local PLAYERS_FREQ = {}
local S = minetest.get_translator("antispam")
local SPAM_SPEED = 5
local SPAM_SPEED_MSECS = SPAM_SPEED * 1e6
local SPAM_WARN = 5
-- In seconds
local SPAM_KICK = SPAM_WARN + 5
local RESET_TIME = 30
-- Convert to microsecs
local RESET_TIME_MSECS = RESET_TIME * 1e6
local WARNING_COLOR = minetest.get_color_escape_sequence"#FFBB33"
minetest.register_on_leaveplayer(function(player)
	PLAYERS_MSG[player:get_player_name()] = nil
	PLAYERS_FREQ[player:get_player_name()] = nil
end)
minetest.register_on_joinplayer(function(player)
	PLAYERS_MSG[player:get_player_name()] = {}
end)
minetest.register_on_chat_message(function(name, message)
	for msg, info in pairs(PLAYERS_MSG[name]) do
		if minetest.get_us_time() - info[2] >= RESET_TIME_MSECS then PLAYERS_MSG[name][msg] = nil end
	end
	if PLAYERS_MSG[name][message] then
		local amount = PLAYERS_MSG[name][message][1] + 1
		PLAYERS_MSG[name][message][1] = amount
		PLAYERS_MSG[name][message][2] = minetest.get_us_time()
		if amount >= SPAM_KICK then minetest.kick_player(name, S("Kicked for spamming."))
		elseif amount >= SPAM_WARN then
			minetest.chat_send_player(name, WARNING_COLOR ..
				S("Warning! You've sent the message '@1' too often. Wait at least @2 seconds before sending it again.", message, RESET_TIME))
		end
	else PLAYERS_MSG[name][message] = { 1, minetest.get_us_time() } end
	if not PLAYERS_FREQ[name] then
        PLAYERS_FREQ[name] = {
			0,
			0,
			minetest.get_us_time(),
			0
		}
        return
    end
    local warns = PLAYERS_FREQ[name][4]
    local amount = PLAYERS_FREQ[name][2]
    local speed = PLAYERS_FREQ[name][1]
    local delay = minetest.get_us_time() - PLAYERS_FREQ[name][3]
    speed = (speed * amount + delay) / (amount + 1)
    if amount >= SPAM_WARN then
        if warns + 1 == SPAM_KICK - SPAM_WARN then minetest.kick_player(name, S("Kicked for spamming."))
        elseif speed <= SPAM_SPEED_MSECS then
            minetest.chat_send_player(name, WARNING_COLOR ..
				S("Warning! You are sending messages too fast. Wait at least @1 seconds before sending another message.", SPAM_SPEED))
            warns = warns + 1
            speed = SPAM_SPEED_MSECS
            amount = SPAM_WARN
        else
            speed = 0
            amount = 0
            warns = 0
        end
    end
    PLAYERS_FREQ[name] = {
        speed,
        amount + 1,
        minetest.get_us_time(),
        warns
    }
end)
