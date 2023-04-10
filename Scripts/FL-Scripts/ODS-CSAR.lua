assert(dct and dct.theater, "Could not load ODS-CSAR: DCT not found")

-- Soon™
-- local DCT_CSAR = dct.theater:getSystem("dct.systems.CSAR")
-- assert(DCT_CSAR, "Could not load ODS-CSAR: installed DCT does not have CSAR module")

-- No apache CSAR because of non-enforceable speed limit
CSAR.AircraftType["AH-64D_BLK_II"] = 0
CSAR.AircraftType["Ka-50"] = 0
CSAR.AircraftType["Ka-50_3"] = 0

local MOOSE_CSAR = CSAR:New(coalition.side.BLUE, "Blue Pilot")
MOOSE_CSAR.countryblue = country.id.CJTF_BLUE
MOOSE_CSAR.radioSound = "beaconsilent.ogg" -- Required (empty) sound file
MOOSE_CSAR.useprefix = false -- Enable for all helis
MOOSE_CSAR.maxdownedpilots = 20 -- Many
MOOSE_CSAR.coordtype = 1 -- L/L DMS

function MOOSE_CSAR:OnAfterPilotDown(from, event, to, spawnedGroup, frequency, unitName, coordinatesText)
    -- DCT_CSAR:onPilotDown(spawnedGroup:GetDCSObject(), frequency)
end

function MOOSE_CSAR:OnAfterBoarded(from, event, to, heliName, groupName)
    -- DCT_CSAR:onPilotBoarded(Group.getByName(groupName), Unit.getByName(heliName))
end

function MOOSE_CSAR:OnAfterRescued(from, event, to, heliUnit, heliName, pilotsSaved)
    -- DCT_CSAR:onPilotRescued(heliUnit:GetDCSObject(), pilotsSaved)
    dct.theater:getTickets():reward(coalition.side.BLUE, pilotsSaved)
end

MOOSE_CSAR:Start()
