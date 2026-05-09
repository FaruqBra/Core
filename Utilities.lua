--[[
    YourHub - Core/Utilities.lua
    Helper functions yang dipakai di seluruh hub.
    Tidak ada game-specific logic di sini.
]]

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local Utilities = {}

-- ============================================================
-- INIT
-- ============================================================
function Utilities.Init()
    print("[Utilities] ✓ Inisialisasi selesai.")
end

-- ============================================================
-- PLAYER HELPERS
-- ============================================================
function Utilities.GetLocalPlayer()
    return Players.LocalPlayer
end

function Utilities.GetCharacter()
    return Players.LocalPlayer and Players.LocalPlayer.Character
end

function Utilities.GetRootPart()
    local char = Utilities.GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utilities.GetHumanoid()
    local char = Utilities.GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utilities.GetPosition()
    local root = Utilities.GetRootPart()
    return root and root.Position or Vector3.new(0, 0, 0)
end

-- ============================================================
-- TELEPORT SAFE
-- ============================================================
function Utilities.Teleport(position, yOffset)
    yOffset = yOffset or 3
    local root = Utilities.GetRootPart()
    if root then
        local target = Vector3.new(position.X, position.Y + yOffset, position.Z)
        root.CFrame = CFrame.new(target)
        return true
    end
    return false
end

function Utilities.TeleportToPart(part, yOffset)
    yOffset = yOffset or 3
    if part and part.Parent then
        return Utilities.Teleport(part.Position, yOffset)
    end
    return false
end

-- ============================================================
-- DISTANCE
-- ============================================================
function Utilities.Distance(a, b)
    if typeof(a) == "Vector3" and typeof(b) == "Vector3" then
        return (a - b).Magnitude
    end
    -- Support instances dengan Position property
    local posA = a and (a.Position or (a.PrimaryPart and a.PrimaryPart.Position))
    local posB = b and (b.Position or (b.PrimaryPart and b.PrimaryPart.Position))
    if posA and posB then
        return (posA - posB).Magnitude
    end
    return math.huge
end

-- ============================================================
-- MATH HELPERS
-- ============================================================
function Utilities.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utilities.Round(value, decimals)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    return math.floor(value * factor + 0.5) / factor
end

function Utilities.Lerp(a, b, t)
    return a + (b - a) * t
end

-- ============================================================
-- STRING HELPERS
-- ============================================================
function Utilities.Trim(s)
    return s:match("^%s*(.-)%s*$")
end

function Utilities.Contains(str, pattern)
    return str:lower():find(pattern:lower(), 1, true) ~= nil
end

-- ============================================================
-- TABLE HELPERS
-- ============================================================
function Utilities.TableHas(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

function Utilities.TableKeys(tbl)
    local keys = {}
    for k in pairs(tbl) do table.insert(keys, k) end
    return keys
end

function Utilities.TableLength(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- ============================================================
-- WAIT SAFE (tidak block scheduler)
-- ============================================================
function Utilities.SafeWait(seconds)
    -- Gunakan task.wait yang lebih efisien dari wait()
    task.wait(seconds)
end

-- ============================================================
-- PCALL WRAPPER dengan logging
-- ============================================================
function Utilities.TryCatch(fn, context)
    context = context or "Unknown"
    local ok, err = pcall(fn)
    if not ok then
        warn("[" .. context .. "] Error: " .. tostring(err))
    end
    return ok, err
end

-- ============================================================
-- IS ALIVE (character check)
-- ============================================================
function Utilities.IsAlive()
    local humanoid = Utilities.GetHumanoid()
    return humanoid and humanoid.Health > 0
end

-- ============================================================
-- GET MODEL ROOT POSITION
-- ============================================================
function Utilities.GetModelPosition(model)
    if model:IsA("Model") then
        local primary = model.PrimaryPart
        if primary then return primary.Position end
        local part = model:FindFirstChildWhichIsA("BasePart")
        if part then return part.Position end
    elseif model:IsA("BasePart") then
        return model.Position
    end
    return nil
end

return Utilities
