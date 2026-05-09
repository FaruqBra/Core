--[[
    YourHub - Core/Cache.lua

    Cache system untuk objects di workspace.
    TIDAK scan workspace setiap frame.
    Refresh berkala dengan interval yang sudah ditentukan.

    Fitur:
    - Cache mobs, drops, chests, dll
    - Auto-refresh tiap N detik
    - Lazy refresh (hanya refresh jika diminta dan sudah expired)
    - Memory efficient
]]

local RunService = game:GetService("RunService")
local Scheduler  = require(script.Parent.Scheduler)

local Cache = {}

-- ============================================================
-- CONFIG
-- ============================================================
local CACHE_REFRESH_INTERVAL = 3.0  -- refresh tiap 3 detik (mobile optimized)

-- ============================================================
-- INTERNAL STATE
-- ============================================================
local _folders    = {}   -- folder references dari game config
local _cache      = {}   -- { folderName = { objects } }
local _lastRefresh = {}  -- { folderName = lastRefreshTime }
local _initialized = false

-- ============================================================
-- INIT
-- ============================================================
function Cache.Init()
    _folders     = {}
    _cache       = {}
    _lastRefresh = {}
    _initialized  = true
    print("[Cache] ✓ Inisialisasi selesai.")
end

-- ============================================================
-- LOAD FOLDERS DARI GAME CONFIG
-- Dipanggil setelah game config di-load
-- ============================================================
function Cache.LoadFolders(folders)
    assert(type(folders) == "table", "[Cache] folders harus table")

    for name, folder in pairs(folders) do
        if folder and folder.Parent then
            _folders[name] = folder
            _cache[name]   = {}
            _lastRefresh[name] = 0
            print("[Cache] ✓ Folder terdaftar: " .. name)
        else
            warn("[Cache] Folder tidak valid: " .. tostring(name))
        end
    end

    -- Register refresh task ke Scheduler
    Scheduler.AddTask("__Cache_Refresh", function()
        Cache.RefreshAll()
    end, CACHE_REFRESH_INTERVAL)
end

-- ============================================================
-- REFRESH SATU FOLDER
-- ============================================================
function Cache.Refresh(folderName)
    local folder = _folders[folderName]
    if not folder or not folder.Parent then
        _cache[folderName] = {}
        return
    end

    -- GetChildren() lebih ringan dari GetDescendants()
    local objects = folder:GetChildren()
    _cache[folderName] = objects
    _lastRefresh[folderName] = tick()
end

-- ============================================================
-- REFRESH SEMUA FOLDERS
-- ============================================================
function Cache.RefreshAll()
    for name, _ in pairs(_folders) do
        Cache.Refresh(name)
    end
end

-- ============================================================
-- GET CACHED OBJECTS
-- Lazy refresh: jika cache sudah expired, refresh dulu
-- ============================================================
function Cache.Get(folderName)
    if not _cache[folderName] then
        warn("[Cache] Folder tidak ditemukan: " .. tostring(folderName))
        return {}
    end

    -- Lazy refresh jika sudah expired
    local lastRefresh = _lastRefresh[folderName] or 0
    if tick() - lastRefresh > CACHE_REFRESH_INTERVAL then
        Cache.Refresh(folderName)
    end

    return _cache[folderName] or {}
end

-- ============================================================
-- GET NEAREST OBJECT dari position
-- Berguna untuk AutoFarm targeting
-- ============================================================
function Cache.GetNearest(folderName, position, maxDistance)
    maxDistance = maxDistance or math.huge

    local objects  = Cache.Get(folderName)
    local nearest  = nil
    local nearestDist = maxDistance

    for _, obj in ipairs(objects) do
        -- Support model dengan PrimaryPart atau part biasa
        local part = nil
        if obj:IsA("Model") then
            part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        elseif obj:IsA("BasePart") then
            part = obj
        end

        if part then
            local dist = (part.Position - position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest     = obj
            end
        end
    end

    return nearest, nearestDist
end

-- ============================================================
-- GET ALL OBJECTS dalam radius
-- ============================================================
function Cache.GetInRadius(folderName, position, radius)
    local objects = Cache.Get(folderName)
    local result  = {}

    for _, obj in ipairs(objects) do
        local part = nil
        if obj:IsA("Model") then
            part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        elseif obj:IsA("BasePart") then
            part = obj
        end

        if part then
            local dist = (part.Position - position).Magnitude
            if dist <= radius then
                table.insert(result, obj)
            end
        end
    end

    return result
end

-- ============================================================
-- CLEAR CACHE
-- ============================================================
function Cache.Clear()
    _cache       = {}
    _lastRefresh = {}
    _folders     = {}
    print("[Cache] ✓ Cache dibersihkan.")
end

-- ============================================================
-- DEBUG INFO
-- ============================================================
function Cache.GetInfo()
    local info = {}
    for name, objects in pairs(_cache) do
        info[name] = #objects
    end
    return info
end

return Cache
