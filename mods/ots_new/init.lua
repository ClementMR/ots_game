local storage = core.get_mod_storage()
local NEWS_VERSION_KEY = "news_version"
local NEWS_KEY = "news_seen_version"

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
        core.chat_send_player(name, core.colorize("#155DFC", "There are new things on the server, go see /news"))
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
        "size[6,9]",
        "no_prepend[]",
        "style_type[button_exit;noclip=true;bgcolor=#FF0000]",
        "button_exit[5.7,-0.8;0.8,1;btn_exit;X]",
        "hypertext[0.1,0.1;6.4,10.3;;" .. core.formspec_escape(get_content(core.get_worldpath() .. "/news.txt")) .. "]",
        "label[0.1,8.8;Current version : " .. get_news_version() .."]"
    }
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "ots_news:formspec" then
        return
    end
    mark_news_seen(player)
end)

core.register_chatcommand("update_news", {
    description = "Force everyone to see the news again",
    privs = {server = true},
    func = function(name, param)
        local version = get_news_version() + 1
        storage:set_int(NEWS_VERSION_KEY, version)
        return true, "News version bumped to " .. version
    end
})

core.register_chatcommand("news", {
    description = "See the news",
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then
            return
        end
        core.show_formspec(name, "ots_news:formspec", table.concat(get_formspec(), ""))
    end
})