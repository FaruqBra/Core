--[[
    YourHub - Core/Remotes.lua

    Remote scan & cache system.
    Scan remote SEKALI SAJA, simpan reference.
    TIDAK FindFirstChild berulang kali.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

-- ============================================================
-- INTERNAL STATE
-- ============================================================
local _remoteCache = {}  -- { name = RemoteEvent/RemoteFunction }
local _initialized  = false

-- ============================================================
-- INIT
-- ============================================================
function Remotes.Init()
    _remoteCache = {}
    _initialized  = true
    print("[Remotes] ✓ Inisialisasi selesai.")
end

-- ============================================================
-- LOAD DARI GAME CONFIG
-- Config format: { RemoteName = RemoteInstance, ... }
-- ============================================================
function Remotes.LoadFromConfig(remotesConfig)
    assert(type(remotesConfig) == "table", "[Remotes] remotesConfig harus table")

    for name, remote in pairs(remotesConfig) do
        if remote and remote.Parent then
            _remoteCache[name] = remote
            print("[Remotes] ✓ Remote cached: " .. name)
        else
            warn("[Remotes] Remote tidak valid atau tidak ditemukan: " .. tostring(name))
        end
    end
end

-- ============================================================
-- GET REMOTE
-- ============================================================
function Remotes.Get(name)
    local remote = _remoteCache[name]
    if not remote then
        warn("[Remotes] Remote tidak ditemukan di cache: " .. tostring(name))
        return nil
    end
    return remote
end

-- ============================================================
-- FIRE REMOTE EVENT (safe)
-- ============================================================
function Remotes.Fire(name, ...)
    local remote = Remotes.Get(name)
    if remote and remote:IsA("RemoteEvent") then
        local ok, err = pcall(function()
            remote:FireServer(...)
        end)
        if not ok then
            warn("[Remotes] Gagal fire remote '" .. name .. "': " .. tostring(err))
        end
    else
        warn("[Remotes] Remote '" .. name .. "' bukan RemoteEvent atau tidak ditemukan.")
    end
end

-- ============================================================
-- INVOKE REMOTE FUNCTION (safe, dengan timeout)
-- ============================================================
function Remotes.Invoke(name, ...)
    local remote = Remotes.Get(name)
    if remote and remote:IsA("RemoteFunction") then
        local args = {...}
        local ok, result = pcall(function()
            return remote:InvokeServer(table.unpack(args))
        end)
        if ok then
            return result
        else
            warn("[Remotes] Gagal invoke remote '" .. name .. "': " .. tostring(result))
            return nil
        end
    else
        warn("[Remotes] Remote '" .. name .. "' bukan RemoteFunction atau tidak ditemukan.")
        return nil
    end
end

-- ============================================================
-- SCAN CUSTOM PATH
-- Untuk scan remote yang tidak ada di config
-- ============================================================
function Remotes.ScanPath(parent, name)
    if _remoteCache[name] then
        return _remoteCache[name]
    end

    local remote = parent:FindFirstChild(name, true)
    if remote then
        _remoteCache[name] = remote
        return remote
    end

    return nil
end

-- ============================================================
-- CLEAR
-- ============================================================
function Remotes.Clear()
    _remoteCache = {}
end

-- ============================================================
-- GET ALL (debugging)
-- ============================================================
function Remotes.GetAll()
    return _remoteCache
end

return Remotes
