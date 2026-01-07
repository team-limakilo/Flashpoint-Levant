-- ODS-Logistics.lua
-- Spawns logistics assets (tankers, AWACS) and scheduled aircraft with template validation

--------------------------------------------------------------------------------
-- Configuration Tables
--------------------------------------------------------------------------------

-- Logistics assets configuration
-- Each entry: { template = "TemplateName", alias = "Alias" (optional), limit = number, delay = seconds }
local LOGISTICS_ASSETS = {
    { template = "ARCO",            alias = "ARCO",            limit = 1, delay = 10 },
    { template = "Petrol",          alias = "PETROL",          limit = 1, delay = 10 },
    { template = "SHELL",           alias = "SHELL",           limit = 1, delay = 10 },
    { template = "TEXACO",          alias = "TEXACO",          limit = 1, delay = 10 },
    { template = "DARKSTAR",        alias = "DARKSTAR",        limit = 1, delay = 10 },
    { template = "WIZARD",          alias = "WIZARD",          limit = 1, delay = 10 },
    { template = "IMAGE",           alias = "IMAGE",           limit = 1, delay = 10 },
    { template = "Recovery Tanker", alias = "Recovery Tanker", limit = 1, delay = 10 },
}

-- Scheduled aircraft configuration
-- Each entry: { template, alias (optional), limit, poolSize, delay, randomization, delayOn }
local SCHEDULED_AIRCRAFT = {
    { template = "AShM",      alias = nil,                          limit = 2, poolSize = 0,  delay = 3600, randomization = 0.3, delayOn = true },
    { template = "CASHatay1", alias = nil,                          limit = 2, poolSize = 60, delay = 2600, randomization = 0.3, delayOn = true },
    { template = "CAS1",      alias = nil,                          limit = 2, poolSize = 60, delay = 3600, randomization = 0.3, delayOn = true },
    { template = "SEAD2",     alias = nil,                          limit = 2, poolSize = 60, delay = 4600, randomization = 0.3, delayOn = true },
    { template = "TND1",      alias = "[UK] No17 Squadron Tornado", limit = 2, poolSize = 16, delay = 1300, randomization = 0.3, delayOn = false },
    { template = "TND2",      alias = "[Italy] Legion 15 Tornado",  limit = 2, poolSize = 16, delay = 1300, randomization = 0.3, delayOn = false },
}

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

--- Validates that a template group exists in the mission
-- @param template string The template group name to check
-- @return boolean True if template exists, false otherwise
local function templateExists(template)
    local group = GROUP:FindByName(template)
    if group == nil then
        env.warning(string.format("[ODS-Logistics] Template group '%s' not found in mission", template))
        return false
    end
    return true
end

--- Schedules a logistics asset (tanker, AWACS, etc.) to spawn and respawn after landing
-- @param config table Configuration with template, alias, limit, delay
-- @return SPAWN|nil The SPAWN object or nil if template doesn't exist
local function createLogisticsSpawn(config)
    if not templateExists(config.template) then
        return nil
    end

    local alias = config.alias or config.template
    local spawn = SPAWN:NewWithAlias(config.template, alias)
        :InitLimit(config.limit, 0)
        :SpawnScheduled(config.delay, 0)
        :InitRepeatOnLanding()

    env.info(string.format("[ODS-Logistics] Created logistics spawn for '%s'", alias))
    return spawn
end

--- Schedules an aircraft to spawn periodically throughout the mission
-- @param config table Configuration with template, alias, limit, poolSize, delay, randomization, delayOn
-- @return SPAWN|nil The SPAWN object or nil if template doesn't exist
local function createScheduledSpawn(config)
    if not templateExists(config.template) then
        return nil
    end

    local spawn
    if config.alias then
        spawn = SPAWN:NewWithAlias(config.template, config.alias)
    else
        spawn = SPAWN:New(config.template)
    end

    if config.delayOn then
        spawn:InitDelayOn()
    end

    spawn:InitLimit(config.limit, config.poolSize)
        :SpawnScheduled(config.delay, config.randomization)
        :InitRepeatOnLanding()

    local displayName = config.alias or config.template
    env.info(string.format("[ODS-Logistics] Created scheduled spawn for '%s'", displayName))
    return spawn
end

--------------------------------------------------------------------------------
-- Initialization Functions
--------------------------------------------------------------------------------

--- Spawns all logistics assets (tankers, AWACS, etc.)
local function initLogisticsAssets()
    env.info("[ODS-Logistics] Initializing logistics assets...")
    local count = 0

    for _, config in ipairs(LOGISTICS_ASSETS) do
        if createLogisticsSpawn(config) then
            count = count + 1
        end
    end

    env.info(string.format("[ODS-Logistics] Initialized %d/%d logistics assets", count, #LOGISTICS_ASSETS))
end

--- Spawns all scheduled aircraft
local function initScheduledAircraft()
    env.info("[ODS-Logistics] Initializing scheduled aircraft...")
    local count = 0

    for _, config in ipairs(SCHEDULED_AIRCRAFT) do
        if createScheduledSpawn(config) then
            count = count + 1
        end
    end

    env.info(string.format("[ODS-Logistics] Initialized %d/%d scheduled aircraft", count, #SCHEDULED_AIRCRAFT))
end

--------------------------------------------------------------------------------
-- Main Execution
--------------------------------------------------------------------------------

initLogisticsAssets()
initScheduledAircraft()

env.info("[ODS-Logistics] Logistics script loaded successfully")
