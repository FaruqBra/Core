--[[
    YourHub - Core/Scheduler.lua

    INI JANTUNG HUB.
    SATU Heartbeat untuk semua tasks.
    TIDAK ada while true do di features.
    TIDAK ada spam task.spawn.

    Cara kerja:
    - Feature memanggil Scheduler.AddTask("nama", fn, interval)
    - Scheduler tick semua task berdasarkan interval masing-masing
    - CPU ringan, mobile optimized
]]

local RunService    = game:GetService("RunService")
local Connections   = require(script.Parent.Connections)

local Scheduler = {}

-- ============================================================
-- INTERNAL STATE
-- ============================================================
local _tasks       = {}   -- { name, fn, interval, lastRun, enabled }
local _running     = false
local _heartbeatConn = nil

-- ============================================================
-- INIT
-- ============================================================
function Scheduler.Init()
    _tasks = {}
    _running = false
    print("[Scheduler] ✓ Inisialisasi selesai.")
end

-- ============================================================
-- ADD TASK
-- Params:
--   name     : string  - unique task name
--   fn       : function(dt) - callback, dt = delta time
--   interval : number  - interval dalam detik (e.g. 0.1, 0.25, 1.0)
-- ============================================================
function Scheduler.AddTask(name, fn, interval)
    assert(type(name) == "string",    "[Scheduler] Task name harus string")
    assert(type(fn) == "function",    "[Scheduler] Task fn harus function")
    assert(type(interval) == "number","[Scheduler] Task interval harus number")
    assert(interval > 0,              "[Scheduler] Task interval harus > 0")

    -- Jika sudah ada task dengan nama sama, replace
    if _tasks[name] then
        _tasks[name].fn       = fn
        _tasks[name].interval = interval
        print("[Scheduler] ✓ Task diperbarui: " .. name)
        return
    end

    _tasks[name] = {
        name    = name,
        fn      = fn,
        interval = interval,
        lastRun = 0,
        enabled = true,
    }

    print("[Scheduler] ✓ Task ditambahkan: " .. name .. " (interval: " .. interval .. "s)")
end

-- ============================================================
-- REMOVE TASK
-- ============================================================
function Scheduler.RemoveTask(name)
    if _tasks[name] then
        _tasks[name] = nil
        print("[Scheduler] Task dihapus: " .. name)
    end
end

-- ============================================================
-- SET TASK ENABLED/DISABLED
-- ============================================================
function Scheduler.SetEnabled(name, enabled)
    if _tasks[name] then
        _tasks[name].enabled = enabled
    end
end

-- ============================================================
-- GET TASK LIST (untuk debugging)
-- ============================================================
function Scheduler.GetTasks()
    local list = {}
    for name, task in pairs(_tasks) do
        table.insert(list, {
            name     = name,
            interval = task.interval,
            enabled  = task.enabled,
        })
    end
    return list
end

-- ============================================================
-- START — satu Heartbeat untuk semua tasks
-- ============================================================
function Scheduler.Start()
    if _running then
        warn("[Scheduler] Sudah berjalan, skip Start().")
        return
    end

    _running = true
    print("[Scheduler] ✓ Scheduler dimulai.")

    -- SATU HEARTBEAT untuk semua tasks
    _heartbeatConn = RunService.Heartbeat:Connect(function(dt)
        if not _running then return end

        local now = tick()

        for name, taskData in pairs(_tasks) do
            if taskData.enabled then
                local elapsed = now - taskData.lastRun
                if elapsed >= taskData.interval then
                    taskData.lastRun = now

                    -- Protected call agar error satu task tidak crash semua
                    local ok, err = pcall(taskData.fn, dt)
                    if not ok then
                        warn("[Scheduler] Error di task '" .. name .. "': " .. tostring(err))
                        -- Opsional: disable task yang error berulang
                        -- taskData.enabled = false
                    end
                end
            end
        end
    end)

    -- Simpan connection ke manager
    Connections.Add("__Scheduler_Heartbeat", _heartbeatConn)
end

-- ============================================================
-- STOP
-- ============================================================
function Scheduler.Stop()
    _running = false

    if _heartbeatConn then
        _heartbeatConn:Disconnect()
        _heartbeatConn = nil
    end

    _tasks = {}
    print("[Scheduler] ✓ Scheduler dihentikan.")
end

-- ============================================================
-- PAUSE / RESUME
-- ============================================================
function Scheduler.Pause()
    _running = false
end

function Scheduler.Resume()
    _running = true
end

return Scheduler
