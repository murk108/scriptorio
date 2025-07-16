local clear_and_create_env = require("core.scripting.env_creator").clear_and_create_env

local tooltip = [[
It is recommended to use a text editor like VS Code, and then paste the code in here to run.
I also made a virtual file system tool that allows for modular scripting.
Check github for any of anything!
]]

local handler = create_error_handler("Script Error: ", nil)
local function run(key, script, env)
    local outer_function, error = load(script, key, "t", env)

    if outer_function then
        xpcall(outer_function, handler)
    else
        handler(error)
    end
end

---@param frame LuaGuiElement
local function create_script_editor(frame)
    local textfield = frame.add{type = "text-box", name = "script_editor", text = storage.script, tooltip = tooltip}
    textfield.style.width = 500
    textfield.style.height = 500
end

---@param frame LuaGuiElement
local function create_script_runner(frame)
    frame.add{type = "button", name = "script_run", caption = "Run"}
end

---@param player LuaPlayer
---@param gui LuaGuiElement
local function create_terminal_gui(player, gui)
    local frame = gui.add{type = "frame", name = "terminal_gui", direction = "vertical", caption = "Script Terminal"}

    create_script_editor(frame)
    create_script_runner(frame)
end

local function sync_text_all_players(text)
    for _, player in pairs(game.players) do
        local gui = player.gui.screen.core_main_gui

        if gui then
            gui.terminal_gui.script_editor.text = text
        end
    end
end

Hooker:add_hook(Events.on_create_main_gui, create_terminal_gui)

Hooker:add_hook("on_gui_script_run", function ()
    local script = storage.script
    run("script_terminal", script, clear_and_create_env())
end)

Hooker:add_hook("on_gui_script_editor", function (player, element, event)
    if event.name == GameEvents.on_gui_text_changed then
        local text = element.text

        sync_text_all_players(text)
        storage.script = text
    end
end)

Hooker:add_hook(Events.on_load, function ()
    ---@type string
    storage.script = storage.script or ""
    run("script_terminal", storage.script, clear_and_create_env())
    return false
end)