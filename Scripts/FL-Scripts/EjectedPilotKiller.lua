-- this script eliminates ejected pilots from the map as soon as they land to
-- keep the unit count from increasing and (hopefully) improve server performance
local handler = {}

local function handleEvent(event)
    if event.id == world.event.S_EVENT_LANDING_AFTER_EJECTION then
        local pilot = event.initiator
        if pilot ~= nil then
            pilot:destroy()
        end
    end
end

function handler:onEvent(event)
    local success, err = pcall(handleEvent, event)
    if not success then
        env.error("EjectedPilotKiller.lua: "..tostring(err))
    end
end

world.addEventHandler(handler)
