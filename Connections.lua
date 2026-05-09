--[[
    YourHub - Core/Connections.lua

    Connection lifecycle manager.
    Semua RBXScriptConnection WAJIB disimpan di sini.
    Auto-cleanup saat hub destroy atau re-execute.

    MENCEGAH:
    - Memory leak
    - Duplicate connections
    - Zombie connections
]]

local Connections = {}

-- ============================================================
-- INTERNAL STATE
-- ============================================================
local _connections = {}  -- { name = RBXScriptConnection }
local _initialized  = false

-- ============================================================
-- INIT
-- ============================================================
function Connections.Init()
    _connections = {}
    _initialized  = true
    print("[Connections] ✓ Inisialisasi selesai.")
end

-- ============================================================
-- ADD CONNECTION
-- name: string identifier (unik per feature/sistem)
-- conn: RBXScriptConnection
-- ============================================================
function Connections.Add(name, conn)
    assert(type(name) == "string", "[Connections] name harus string")
    assert(conn ~= nil,            "[Connections] conn tidak boleh nil")

    -- Disconnect yang lama jika ada nama yang sama
    if _connections[name] then
        local ok = pcall(function()
            _connections[name]:Disconnect()
        end)
        if not ok then
            warn("[Connections] Gagal disconnect lama: " .. name)
        end
    end

    _connections[name] = conn
end

-- ============================================================
-- REMOVE & DISCONNECT SATU CONNECTION
-- ============================================================
function Connections.Remove(name)
    if _connections[name] then
        local ok = pcall(function()
            _connections[name]:Disconnect()
        end)
        if not ok then
            warn("[Connections] Gagal disconnect: " .. name)
        end
        _connections[name] = nil
    end
end

-- ============================================================
-- CLEANUP SEMUA CONNECTIONS
-- Dipanggil saat re-execute atau cleanup
-- ============================================================
function Connections.CleanupAll()
    local count = 0
    for name, conn in pairs(_connections) do
        local ok = pcall(function()
            conn:Disconnect()
        end)
        if ok then
            count = count + 1
        else
            warn("[Connections] Gagal disconnect saat cleanup: " .. name)
        end
    end
    _connections = {}
    print("[Connections] ✓ " .. count .. " connections dibersihkan.")
end

-- ============================================================
-- CLEANUP BERDASARKAN PREFIX
-- Berguna untuk cleanup feature tertentu
-- Contoh: Connections.CleanupByPrefix("ESP_")
-- ============================================================
function Connections.CleanupByPrefix(prefix)
    for name, conn in pairs(_connections) do
        if name:sub(1, #prefix) == prefix then
            pcall(function() conn:Disconnect() end)
            _connections[name] = nil
        end
    end
end

-- ============================================================
-- IS CONNECTED?
-- ============================================================
function Connections.IsConnected(name)
    local conn = _connections[name]
    if conn == nil then return false end
    -- RBXScriptConnection memiliki property .Connected
    local ok, result = pcall(function() return conn.Connected end)
    return ok and result or false
end

-- ============================================================
-- COUNT (debugging)
-- ============================================================
function Connections.Count()
    local count = 0
    for _ in pairs(_connections) do count = count + 1 end
    return count
end

-- ============================================================
-- GET LIST (debugging)
-- ============================================================
function Connections.GetList()
    local list = {}
    for name in pairs(_connections) do
        table.insert(list, name)
    end
    return list
end

return Connections
