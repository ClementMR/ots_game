local storage = core.get_mod_storage()
local S = core.get_translator("ots_news")
local NEWS_VERSION_KEY = "ots_new:news_version"
local NEWS_KEY = "ots_news:seen_version"

local function get_news_version()
    local version = storage:get_int(NEWS_VERSION_KEY)
    if version == 0 then
        version = 1
        storage:set_int(NEWS_VERSION_KEY, version)
    end
    return storage:get_int(NEWS_VERSION_KEY)
end

local function mark_news_seen(player)
    player:get_meta():set_int(NEWS_KEY, get_news_version())
end

core.register_on_joinplayer(function(player, last_login)
    local meta = player:get_meta()
    local saw_news = (meta:get_int(NEWS_KEY) >= get_news_version())
    local name = player:get_player_name()
    if not saw_news then
        core.chat_send_player(name, core.colorize("#155DFC", S("There are new things on the server, go see /news")))
    end
end)

local function get_content(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return content
    end
    return ""
end

local function get_formspec()
    return {
        "formspec_version[6]",
        "size[9,10.4]",
        "position[0.5,0.5]",
        "no_prepend[]",
        "bgcolor[#00000000;false]",
        "background[0,0;9,10.4;ots_news_bg.png;true]",
        "style_type[button_exit;border=false;bgcolor=#C11007;textcolor=#FFFFFF]",
        "style_type[label;textcolor=#EEF3F8]",
        "label[0.45,0.43;" .. core.formspec_escape(S("Server News")) .. "]",
        "button_exit[8.25,0.25;0.45,0.45;btn_exit;X]",
        "hypertext[0.55,1.25;7.9,8.05;news;" .. core.formspec_escape(get_content(core.get_worldpath() .. "/news.txt")) .. "]"
    }
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "ots_news:formspec" then
        return
    end
    mark_news_seen(player)
end)

core.register_chatcommand("update_news", {
    description = S("Force everyone to see the news again"),
    privs = {server = true},
    func = function(name, param)
        local version = get_news_version() + 1
        storage:set_int(NEWS_VERSION_KEY, version)
        return true, S("News version bumped to @1", version)
    end
})

core.register_chatcommand("news", {
    description = S("See the news"),
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then
            return
        end
        core.show_formspec(name, "ots_news:formspec", table.concat(get_formspec(), ""))
    end
})