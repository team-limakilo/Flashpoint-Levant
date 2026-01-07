-- SRS Reminder Script
-- Displays periodic reminders to players to connect to SRS (SimpleRadio Standalone)
-- Only shows reminders to players whose aircraft are still in the air

local SRSReminder = {}

-- Configuration
local INITIAL_DELAY_SECONDS = 120     -- First reminder after 2 minutes (120 seconds)
local REMINDER_INTERVAL_SECONDS = 600 -- Subsequent reminders every 10 minutes (600 seconds)
local MESSAGE_DURATION_SECONDS = 30   -- How long the message stays on screen (30 seconds)

-- SRS frequencies for the mission
local SRS_FREQUENCIES = {
    { name = "ATC",             freq = "249.000 MHz AM" },
    { name = "ATIS",            freq = "249.500 MHz AM" },
    { name = "Common/Tactical", freq = "253.000 MHz AM" },
    { name = "GCI (UHF)",       freq = "255.000 MHz AM" },
    { name = "GCI (VHF)",       freq = "136.000 MHz AM" },
    { name = "GCI (FM)",        freq = "40.000 MHz FM" },
}

-- Track which players have been sent reminders (cleared on respawn)
local playersReminded = {}

-- Track pending reminder timers for each player (so we can check if still valid)
local pendingReminders = {}

-- Pre-build the reminder message at module load time
local REMINDER_MESSAGE = (function()
    local message = ""
    message = message .. "SRS is available for voice communication! :)\n\n"

    message = message .. "Coordinate with other players and use SkyEye,\n"
    message = message .. "our voice-controlled AWACS bot!\n\n"

    message = message .. "IMPORTANT FREQUENCIES:\n"
    for _, freq in ipairs(SRS_FREQUENCIES) do
        message = message .. "  • " .. freq.name .. ": " .. freq.freq .. "\n"
    end
    message = message .. "\n"
    message = message .. "Download SRS: http://dcssimpleradio.com/\n"
    message = message .. "SkyEye Guide: https://github.com/dharmab/skyeye/blob/main/docs/PLAYER.md\n"

    return message
end)()

-- Send reminder to a specific player by unit name
local function sendReminderToPlayer(unitName)
    -- Clear the pending reminder tracking
    pendingReminders[unitName] = nil

    -- Find the unit
    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then
        env.info(string.format("SRS-Reminder: Unit %s no longer exists, skipping reminder", unitName))
        return nil
    end

    -- Check if this is still a player-controlled unit
    local playerName = unit:getPlayerName()
    if not playerName then
        env.info(string.format("SRS-Reminder: Unit %s is no longer player-controlled, skipping reminder", unitName))
        return nil
    end

    -- Only send reminder if player is on the ground (not in air) and hasn't been reminded
    if not unit:inAir() and not playersReminded[unitName] then
        trigger.action.outTextForUnit(unit:getID(), REMINDER_MESSAGE, MESSAGE_DURATION_SECONDS, false)
        playersReminded[unitName] = true
        env.info(string.format("SRS-Reminder: Sent reminder to player %s in %s", playerName, unitName))

        -- Schedule subsequent reminder
        pendingReminders[unitName] = true
        timer.scheduleFunction(function() return sendReminderToPlayer(unitName) end, nil, timer.getTime() + REMINDER_INTERVAL_SECONDS)
    elseif unit:inAir() then
        -- Player took off before reminder, schedule next check at the regular interval
        pendingReminders[unitName] = true
        timer.scheduleFunction(function() return sendReminderToPlayer(unitName) end, nil, timer.getTime() + REMINDER_INTERVAL_SECONDS)
    end

    return nil
end

-- Event handler to track player spawns/respawns
local eventHandler = {}

function eventHandler:onEvent(event)
    -- Handle player spawn/respawn
    -- S_EVENT_BIRTH is more reliable than S_EVENT_PLAYER_ENTER_UNIT
    if event.id == world.event.S_EVENT_BIRTH then
        local unit = event.initiator
        if unit and unit:isExist() then
            local playerName = unit:getPlayerName()
            if playerName then
                local unitName = unit:getName()
                -- Clear the flag so they can receive reminders again
                playersReminded[unitName] = nil
                pendingReminders[unitName] = nil
                env.info(string.format("SRS-Reminder: Player %s spawned in %s, scheduling reminder in %d seconds", playerName, unitName, INITIAL_DELAY_SECONDS))

                -- Schedule the initial reminder for this player after the delay
                pendingReminders[unitName] = true
                timer.scheduleFunction(function() return sendReminderToPlayer(unitName) end, nil, timer.getTime() + INITIAL_DELAY_SECONDS)
            end
        end
    end
end

-- Initialize the script
local function initialize()
    -- Register event handler
    world.addEventHandler(eventHandler)

    env.info("SRS-Reminder: Script initialized. Reminders will be sent " .. INITIAL_DELAY_SECONDS .. " seconds after each player spawns.")
end

-- Wrap initialization in pcall for error handling
local success, err = pcall(initialize)
if not success then
    env.error("SRS-Reminder: Initialization failed: " .. tostring(err))
end
