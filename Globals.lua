--[[
    YourHub - Shared/Globals.lua
    Global state dan service references.
    Accessible dari semua module.
]]

local Globals = {}

-- ============================================================
-- SERVICES
-- ============================================================
Globals.Services = {
    Players           = game:GetService("Players"),
    RunService        = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    UserInputService  = game:GetService("UserInputService"),
    TweenService      = game:GetService("TweenService"),
    Workspace         = game:GetService("Workspace"),
    CoreGui           = game:GetService("CoreGui"),
    TextService       = game:GetService("TextService"),
}

-- ============================================================
-- LOCAL PLAYER (shorthand)
-- ============================================================
Globals.LocalPlayer = Globals.Services.Players.LocalPlayer

-- ============================================================
-- HUB STATE
-- ============================================================
Globals.State = {
    HubOpen    = true,
    CurrentTab = "Main",
    LastError  = nil,
    FPS        = 0,
}

-- ============================================================
-- RUNTIME INFO
-- ============================================================
Globals.Runtime = {
    StartTime  = tick(),
    Platform   = "Mobile",  -- bisa detect otomatis
    IsStudio   = game:GetService("RunService"):IsStudio(),
}

-- Detect platform
local UserInputService = game:GetService("UserInputService")
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    Globals.Runtime.Platform = "Mobile"
elseif UserInputService.KeyboardEnabled then
    Globals.Runtime.Platform = "PC"
end

return Globals
