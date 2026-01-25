-- Script Loader with Error Handling
-- Loads FL-Scripts with pcall protection and logging

local scriptsDir = lfs.writedir() .. [[Scripts\FL-Scripts\]]

local scriptsToLoad = {
    "gRPC-Init.lua",
    "MOOSE-Loader.lua",
    "MOOSE-Settings.lua",
    "ODS-Logistics.lua",
    "ODS-RedAir.lua",
    "ODS-CSAR.lua",
    "GazDesignator.lua",
    "EjectedPilotKiller.lua",
}

env.info("[ScriptLoader] Beginning script load sequence")

local loadedCount = 0
local failedCount = 0

for _, scriptName in ipairs(scriptsToLoad) do
    local scriptPath = scriptsDir .. scriptName
    local success, errorMsg = pcall(dofile, scriptPath)

    if success then
        env.info("[ScriptLoader] Successfully loaded: " .. scriptName)
        loadedCount = loadedCount + 1
    else
        env.error("[ScriptLoader] Failed to load: " .. scriptName .. " - Error: " .. tostring(errorMsg))
        failedCount = failedCount + 1
    end
end

env.info("[ScriptLoader] Script load complete. Loaded: " .. loadedCount .. ", Failed: " .. failedCount)

env.setErrorMessageBoxEnabled(false)
