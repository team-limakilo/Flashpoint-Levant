-- SRS Reminder Script
-- Displays periodic reminders to players to connect to SRS (SimpleRadio Standalone)
-- Only shows reminders to players whose aircraft are still on the ground

local SRSReminder = {}

-- Configuration
local INITIAL_DELAY_SECONDS = 120     -- First reminder after 2 minutes (120 seconds)
local REMINDER_INTERVAL_SECONDS = 600 -- Subsequent reminders every 10 minutes (600 seconds)
local MESSAGE_DURATION_SECONDS = 30   -- How long the message stays on screen (30 seconds)
local MAX_SPEED_KNOTS = 50            -- Maximum speed in knots to be considered "on ground" (filters out low-flying aircraft)

-- SRS frequencies for the mission
local SRS_FREQUENCIES = {
    { name = "ATC",             freq = "249.000 MHz AM" },
    { name = "Common/Tactical", freq = "253.000 MHz AM" },
    { name = "GCI (UHF)",       freq = "255.000 MHz AM" },
    { name = "GCI (VHF)",       freq = "136.000 MHz AM" },
    { name = "GCI (FM)",        freq = "40.000 MHz FM" },
}

-- Track which players have taken off
local playersTakenOff = {}

-- Build the reminder message
local function buildReminderMessage()
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
end

-- Check if a unit is on the ground
local function isUnitOnGround(unit)
    if not unit or not unit:isExist() then
        return false
    end

    -- Check the unit's velocity to determine if it's airborne
    local velocity = unit:getVelocity()
    if not velocity then
        return true
    end

    -- Calculate speed in knots
    local speedMS = math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y + velocity.z * velocity.z)
    local speedKnots = speedMS * 1.94384 -- Convert m/s to knots

    -- Filter out players flying low and fast (they're clearly airborne)
    if speedKnots > MAX_SPEED_KNOTS then
        return false
    end

    -- Get unit position
    local position = unit:getPoint()
    if not position then
        return true
    end

    -- Get terrain height at unit position
    local terrainHeight = land.getHeight({ x = position.x, y = position.z })
    local unitHeight = position.y

    -- If the unit is less than 5 meters above ground, consider it on the ground
    local agl = unitHeight - terrainHeight
    return agl < 5
end

-- Send reminder to grounded players
local function sendReminderToGroundedPlayers()
    local message = buildReminderMessage()
    local bluePlayersSent = 0
    local redPlayersSent = 0

    -- Check blue coalition players
    local bluePlayers = coalition.getPlayers(coalition.side.BLUE)
    for _, unit in ipairs(bluePlayers) do
        if unit and unit:isExist() then
            local unitName = unit:getName()

            -- Only send reminder if player hasn't taken off yet
            if not playersTakenOff[unitName] and isUnitOnGround(unit) then
                trigger.action.outTextForUnit(unit:getID(), message, MESSAGE_DURATION_SECONDS, false)
                bluePlayersSent = bluePlayersSent + 1
            end
        end
    end

    -- Check red coalition players
    local redPlayers = coalition.getPlayers(coalition.side.RED)
    for _, unit in ipairs(redPlayers) do
        if unit and unit:isExist() then
            local unitName = unit:getName()

            -- Only send reminder if player hasn't taken off yet
            if not playersTakenOff[unitName] and isUnitOnGround(unit) then
                trigger.action.outTextForUnit(unit:getID(), message, MESSAGE_DURATION_SECONDS, false)
                redPlayersSent = redPlayersSent + 1
            end
        end
    end

    -- Log how many reminders were sent
    local totalSent = bluePlayersSent + redPlayersSent
    if totalSent > 0 then
        env.info(string.format("SRS-Reminder: Sent reminder to %d grounded player(s)", totalSent))
    end

    -- Schedule the next reminder
    return timer.getTime() + REMINDER_INTERVAL_SECONDS
end

-- Event handler to track takeoffs
local eventHandler = {}

function eventHandler:onEvent(event)
    -- Track when players take off so we stop sending them reminders
    if event.id == world.event.S_EVENT_TAKEOFF or event.id == world.event.S_EVENT_RUNWAY_TAKEOFF then
        local unit = event.initiator
        if unit and unit:isExist() then
            local playerName = unit:getPlayerName()
            if playerName then
                local unitName = unit:getName()
                playersTakenOff[unitName] = true
                env.info(string.format("SRS-Reminder: Player %s has taken off in %s", playerName, unitName))
            end
        end
    end

    -- Clear the flag when a player enters a unit (allows reminders if they respawn)
    if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
        local unit = event.initiator
        if unit and unit:isExist() then
            local unitName = unit:getName()
            -- Don't immediately clear - only clear if they're on the ground
            -- This prevents clearing the flag for air-starts
            if isUnitOnGround(unit) then
                playersTakenOff[unitName] = nil
            end
        end
    end
end

-- Initialize the script
local function initialize()
    -- Register event handler
    world.addEventHandler(eventHandler)

    -- Schedule the first reminder
    timer.scheduleFunction(sendReminderToGroundedPlayers, nil, timer.getTime() + INITIAL_DELAY_SECONDS)

    env.info("SRS-Reminder: Script initialized. First reminder in " .. INITIAL_DELAY_SECONDS .. " seconds.")
end

-- Wrap initialization in pcall for error handling
local success, err = pcall(initialize)
if not success then
    env.error("SRS-Reminder: Initialization failed: " .. tostring(err))
end
