local hooker = Hooker:create_listener()
local input = InputHooker:create_listener()
local scheduler = Scheduler:create_listener(4096)
local to_clear = {hooker, input, scheduler}

local M = {}

local custom_env = {
    Hooker = hooker,
    InputHooker = input,
    Scheduler = scheduler,
}

function M.clear_and_create_env()
    local env = {}

    for i = 1, #to_clear do
        to_clear[i]:clear()
    end

    for i, v in pairs(_G) do -- copy current environemnt
        env[i] = v
    end

    for i, v in pairs(custom_env) do -- add custom environment
        env[i] = v
    end

    env._G = env
    return env
end

return M