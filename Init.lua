--[[
    YourHub - Core/Init.lua
    Bootstrap semua core systems.
    TIDAK mengandung game-specific logic.
]]

local Init = {}

-- Track apakah sudah di-init (re-execute safety)
local _initialized = false

function Init.Init()
    if _initialized then
        warn("[Core/Init] Sudah di-init sebelumnya, skip.")
        return
    end

    -- Init Connections manager
    local Connections = require(script.Parent.Connections)
    Connections.Init()

    -- Init Remotes manager
    local Remotes = require(script.Parent.Remotes)
    Remotes.Init()

    -- Init Cache
    local Cache = require(script.Parent.Cache)
    Cache.Init()

    -- Init Scheduler (belum start, hanya setup)
    local Scheduler = require(script.Parent.Scheduler)
    Scheduler.Init()

    -- Init Utilities
    local Utilities = require(script.Parent.Utilities)
    Utilities.Init()

    _initialized = true
    print("[Core/Init] ✓ Semua core systems siap.")
end

function Init.IsInitialized()
    return _initialized
end

function Init.Reset()
    _initialized = false
end

return Init
