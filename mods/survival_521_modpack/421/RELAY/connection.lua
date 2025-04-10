local http = core.request_http_api()
local settings = core.settings

local port = settings:get('relay.port') or 8080
local timeout = 10

relay = {}

relay.registered_on_messages = {}

function relay.register_on_message(func)
    table.insert(relay.registered_on_messages, func)
end

relay.chat_send_all = core.chat_send_all
relay.chat_send_player = core.chat_send_player

-- Allow the chat message format to be customised by other mods
function relay.format_chat_message(name, msg)
    return ('<%s@relay> %s'):format(name, msg)
end

function relay.handle_response(response)
    local data = response.data
    if data == '' or data == nil then
        return
    end
    local data = core.parse_json(response.data)
    if not data then
        return
    end
    if data.messages then
        for _, message in pairs(data.messages) do
            for _, func in pairs(relay.registered_on_messages) do
                func(message.author, message.content)
            end
            --relay.chat_send_all("<"..message.author.."> "..message.content)
            core.log("action", "[Relay] <"..message.author.."> "..message.content)
        end
    end
    if data.commands then
        local commands = core.registered_chatcommands
        for _, v in pairs(data.commands) do
            if commands[v.command] then
                if core.get_ban_description(v.name) ~= '' then
                    relay.send('You cannot run commands because you are banned.', v.context or nil)
                    return
                end
                -- Check player privileges
                local required_privs = commands[v.command].privs or {}
                local player_privs = core.get_player_privs(v.name)
                for priv, value in pairs(required_privs) do
                    if player_privs[priv] ~= value then
                        relay.send('Insufficient privileges.', v.context or nil)
                        return
                    end
                end
                local old_chat_send_player = core.chat_send_player
                core.chat_send_player = function(name, message)
                    old_chat_send_player(name, message)
                    if name == v.name then
                        relay.send(message, v.context or nil)
                    end
                end
                local success, ret_val = commands[v.command].func(v.name, v.params or '')
                if ret_val then
                    relay.send(ret_val, v.context or nil)
                end
                core.chat_send_player = old_chat_send_player
            else
                relay.send(('Command not found: `%s`'):format(v.command), v.context or nil)
            end
        end
    end
    if data.logins then
        local auth = core.get_auth_handler()
        for _, v in pairs(data.logins) do
            local authdata = auth.get_auth(v.username)
            local result = false
            if authdata then
                result = core.check_password_entry(v.username, authdata.password, v.password)
            end
            local request = {
                type = 'relay_LOGIN_RESULT',
                user_id = v.user_id,
                username = v.username,
                success = result
            }
            http.fetch({
                url = 'localhost:'..tostring(port),
                timeout = timeout,
                post_data = core.write_json(request)
            }, relay.handle_response)
        end
    end
end

function relay.send(message, id)
    local data = {
        type = 'relay-RELAY-MESSAGE',
        content = core.strip_colors(message)
    }
    if id then
        data['context'] = id
    end
    http.fetch({
        url = 'localhost:'..tostring(port),
        timeout = timeout,
        post_data = core.write_json(data)
    }, function(_) end)
end

function core.chat_send_all(message)
    relay.chat_send_all(message)
    relay.send(message)
end

-- Register the chat message callback after other mods load so that anything
-- that overrides chat will work correctly
core.after(0, core.register_on_chat_message, function(name, message)
    relay.send(core.format_chat_message(name, message))
end)

local timer = 0
core.register_globalstep(function(dtime)
    if dtime then
        timer = timer + dtime
        if timer > 0.2 then
            http.fetch({
                url = 'localhost:'..tostring(port),
                timeout = timeout,
                post_data = core.write_json({
                    type = 'relay-REQUEST-DATA'
                })
            }, relay.handle_response)
            timer = 0
        end
    end
end)

core.register_on_shutdown(function()
    relay.send(":red_circle: Server shutting down...")
end)

relay.send(":green_circle: Server started!")