-- Setting areas to CAP
CAPZone1 = ZONE_POLYGON:New( "CapZone1", GROUP:FindByName( "CapZone1" ) )
CAPZone2 = ZONE_POLYGON:New( "CapZone2", GROUP:FindByName( "CapZone2" ) )
CAPZone3 = ZONE_POLYGON:New( "CapZone3", GROUP:FindByName( "CapZone3" ) )
CAPZone4 = ZONE_POLYGON:New( "CapZone4", GROUP:FindByName( "CapZone4" ) )
BluCap   = ZONE_POLYGON:New( "BluCap",   GROUP:FindByName( "BluCap"   ) )
FleetCAP = ZONE_POLYGON:New( "FleetCAP", GROUP:FindByName( "FleetCAP" ) )

-- Now setting blue
EWR_Blue = SET_GROUP:New()
EWR_Blue:FilterCoalitions( "blue" )
EWR_Blue:FilterPrefixes( { "WIZARD", "DARKSTAR", "SAM" } )
EWR_Blue:FilterActive()
EWR_Blue:FilterStart()
Detection_Blue = DETECTION_AREAS:New( EWR_Blue, 10000 ) -- 10km grouping
A2ADispatcher_Blue = AI_A2A_DISPATCHER:New( Detection_Blue )
A2ADispatcher_Blue:SetEngageRadius( 75000 ) -- CAP engagement radius of 75km
A2ADispatcher_Blue:SetDefaultCapRacetrack( 10000, 20000 ) -- 10-20km racetracks
A2ADispatcher_Blue:SetDefaultFuelThreshold( 0.3 ) -- RTB early to prevent auto-AAR
A2ADispatcher_Blue:SetIntercept( 300 ) -- Calculated interception delay
A2ADispatcher_Blue:SetGciRadius( 75000 ) -- Intercept targets less than 75km away from airbases
A2ADispatcher_Blue:SetBorderZone( { BluCap, FleetCAP } )

-- Blue F-4E CAP
A2ADispatcher_Blue:SetSquadron( "Incirlik F4E", AIRBASE.Syria.Incirlik, { "F4" } )
A2ADispatcher_Blue:SetSquadronTakeoffInAir( "Incirlik F4E" )
A2ADispatcher_Blue:SetSquadronLandingNearAirbase( "Incirlik F4E" )
A2ADispatcher_Blue:SetSquadronOverhead( "Incirlik F4E", 1 )
A2ADispatcher_Blue:SetSquadronGrouping( "Incirlik F4E", 2, true )

-- Blue F-5E CAP
A2ADispatcher_Blue:SetSquadron( "Incirlik F5E", AIRBASE.Syria.Incirlik, { "F5" } )
A2ADispatcher_Blue:SetSquadronTakeoffInAir( "Incirlik F5E" )
A2ADispatcher_Blue:SetSquadronLandingNearAirbase( "Incirlik F5E" )
A2ADispatcher_Blue:SetSquadronOverhead( "Incirlik F5E", 1 )
A2ADispatcher_Blue:SetSquadronGrouping( "Incirlik F5E", 2, true )
A2ADispatcher_Blue:SetSquadronCap( "Incirlik F5E", BluCap, 4000, 6000, 460, 900, 800, 1200 )

-- Blue F-15c CAP
A2ADispatcher_Blue:SetSquadron( "Incirlik F15C", AIRBASE.Syria.Incirlik, { "F15C" } )
A2ADispatcher_Blue:SetSquadronTakeoffInAir( "Incirlik F15C" )
A2ADispatcher_Blue:SetSquadronLandingNearAirbase( "Incirlik F15C" )
A2ADispatcher_Blue:SetSquadronOverhead( "Incirlik F15C", 1 )
A2ADispatcher_Blue:SetSquadronGrouping( "Incirlik F15C", 2, true )
A2ADispatcher_Blue:SetSquadronCap( "Incirlik F15C", BluCap, 6000, 8000, 460, 900, 800, 1800 )

-- Blue Mirage CAP
A2ADispatcher_Blue:SetSquadron( "Incirlik M2000C", AIRBASE.Syria.Incirlik, { "M2000" } )
A2ADispatcher_Blue:SetSquadronTakeoffInAir( "Incirlik M2000C" )
A2ADispatcher_Blue:SetSquadronLandingNearAirbase( "Incirlik M2000C" )
A2ADispatcher_Blue:SetSquadronOverhead( "Incirlik M2000C", 1 )
A2ADispatcher_Blue:SetSquadronGrouping( "Incirlik M2000C", 2, true )
A2ADispatcher_Blue:SetSquadronCap( "Incirlik M2000C", BluCap, 6000, 8000, 460, 900, 800, 1600 )

-- Blue F-14 CAP
A2ADispatcher_Blue:SetSquadron( "Fleet F14", "CVN-75 Harry S. Truman", { "F14" } )
A2ADispatcher_Blue:SetSquadronTakeoffFromParkingHot( "Fleet F14" )
A2ADispatcher_Blue:SetSquadronLandingNearAirbase( "Fleet F14" )
A2ADispatcher_Blue:SetSquadronOverhead( "Fleet F14", 1 )
A2ADispatcher_Blue:SetSquadronGrouping( "Fleet F14", 2, true )
A2ADispatcher_Blue:SetSquadronCap( "Fleet F14", FleetCAP, 6000, 8000, 460, 900, 800, 1800 )

-- Blue F-18 CAP
A2ADispatcher_Blue:SetSquadron( "Fleet F18", "CVN-75 Harry S. Truman", { "F18" } )
A2ADispatcher_Blue:SetSquadronTakeoffFromParkingHot( "Fleet F18" )
A2ADispatcher_Blue:SetSquadronLandingNearAirbase( "Fleet F18" )
A2ADispatcher_Blue:SetSquadronOverhead( "Fleet F18", 1 )
A2ADispatcher_Blue:SetSquadronGrouping( "Fleet F18", 2, true )
A2ADispatcher_Blue:SetSquadronCap( "Fleet F18", FleetCAP, 6000, 8000, 460, 900, 800, 1400 )

-- Blue Incirlik Intercept
A2ADispatcher_Blue:SetSquadron( "Incirlik Intercept", AIRBASE.Syria.Incirlik, { "F15C", "M2000" } )
A2ADispatcher_Blue:SetSquadronTakeoffInAir( "Incirlik Intercept" )
A2ADispatcher_Blue:SetSquadronLandingNearAirbase( "Incirlik Intercept" )
A2ADispatcher_Blue:SetSquadronOverhead( "Incirlik Intercept", 1 )
A2ADispatcher_Blue:SetSquadronGrouping( "Incirlik Intercept", 2, true )
A2ADispatcher_Blue:SetSquadronGci( "Incirlik Intercept", 800, 1200, 2, 120, 240 )

-- Blue Gaziantep Intercept
A2ADispatcher_Blue:SetSquadron( "Gaziantep Intercept", AIRBASE.Syria.Gaziantep, { "F4", "F5" } )
A2ADispatcher_Blue:SetSquadronTakeoffInAir( "Gaziantep Intercept" )
A2ADispatcher_Blue:SetSquadronLandingNearAirbase( "Gaziantep Intercept" )
A2ADispatcher_Blue:SetSquadronOverhead( "Gaziantep Intercept", 1 )
A2ADispatcher_Blue:SetSquadronGrouping( "Gaziantep Intercept", 2, true )
A2ADispatcher_Blue:SetSquadronGci( "Gaziantep Intercept", 800, 1200, 2, 120, 240 )


-- Setting red dispatcher
EWR_Red = SET_GROUP:New()
EWR_Red:FilterCoalitions( "red" )
EWR_Red:FilterPrefixes( { "sa2", "sa3", "sa5", "sa6", "aaa", "SAM", "EWR" } )
EWR_Red:FilterActive()
EWR_Red:FilterStart()
Detection_Red = DETECTION_AREAS:New( EWR_Red, 10000 ) -- 10km grouping
A2ADispatcher_Red = AI_A2A_DISPATCHER:New( Detection_Red )
A2ADispatcher_Red:SetEngageRadius( 75000 ) -- CAP engament radius of 75km
A2ADispatcher_Red:SetDefaultCapRacetrack( 10000, 20000 ) -- 10-15km racetracks
A2ADispatcher_Red:SetDefaultFuelThreshold( 0.3 ) -- RTB early to prevent out of fuel ejections
A2ADispatcher_Red:SetIntercept( 300 ) -- Calculated interception delay
A2ADispatcher_Red:SetGciRadius( 150000 ) -- Intercept targets less than 150km away from airbases
A2ADispatcher_Red:SetBorderZone( { CAPZone1, CAPZone2, CAPZone3, CAPZone4 } )

-- Aleppo CAP + intercept
A2ADispatcher_Red:SetSquadron( "Aleppo", AIRBASE.Syria.Aleppo, { "M21", "M19", "M23" } )
A2ADispatcher_Red:SetSquadronTakeoffFromParkingHot( "Aleppo" )
A2ADispatcher_Red:SetSquadronLandingAtRunway( "Aleppo" )
A2ADispatcher_Red:SetSquadronOverhead( "Aleppo", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "Aleppo", 2, true )
-- CAP zone and parameters: area, min alt, max alt, min speed patrol, max speed patrol, min speed engage, max speed engage)
A2ADispatcher_Red:SetSquadronCap( "Aleppo", CAPZone1, 4000, 7000, 460, 900, 600, 1200 )
-- CAP interval parameters: max groups, min regen interval, max regen interval
A2ADispatcher_Red:SetSquadronCapInterval( "Aleppo", 1, 350, 1400 )
-- GCI intercept parameters: min engage speed, max engage speed, max airborne aircraft, min regen interval, max regen interval
A2ADispatcher_Red:SetSquadronGci( "Aleppo", 800, 1200, 4, 350, 1400 )

-- Airspawn 1 CAP
A2ADispatcher_Red:SetSquadron( "39th", "Airspawn 1", { "M21", "M19" } )
A2ADispatcher_Red:SetSquadronTakeoffInAir( "39th" )
A2ADispatcher_Red:SetSquadronLandingNearAirbase( "39th" )
A2ADispatcher_Red:SetSquadronOverhead( "39th", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "39th", 2, true )
A2ADispatcher_Red:SetSquadronCap( "39th", CAPZone1, 4000, 7000, 500, 900, 600, 1200 )
A2ADispatcher_Red:SetSquadronCapInterval( "39th", 0, 350, 1400 )

-- Kuweires intercept
A2ADispatcher_Red:SetSquadron( "Kuweires", AIRBASE.Syria.Kuweires, { "M21", "M19" } )
A2ADispatcher_Red:SetSquadronTakeoffFromParkingHot( "Kuweires" )
A2ADispatcher_Red:SetSquadronLandingAtRunway( "Kuweires" )
A2ADispatcher_Red:SetSquadronOverhead( "Kuweires", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "Kuweires", 2, true )
A2ADispatcher_Red:SetSquadronGci( "Kuweires", 800, 1200, 4, 350, 1400 )

-- Bassel CAP + intercept
A2ADispatcher_Red:SetSquadron( "Bassel", AIRBASE.Syria.Bassel_Al_Assad, { "M21", "M23" } )
A2ADispatcher_Red:SetSquadronTakeoffFromParkingHot( "Bassel" )
A2ADispatcher_Red:SetSquadronLandingAtRunway( "Bassel" )
A2ADispatcher_Red:SetSquadronOverhead( "Bassel", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "Bassel", 2, true )
A2ADispatcher_Red:SetSquadronCap( "Bassel", CAPZone2, 4000, 7000, 500, 900, 600, 1200 )
A2ADispatcher_Red:SetSquadronCapInterval( "Bassel", 1, 350, 1400 )
A2ADispatcher_Red:SetSquadronGci( "Bassel", 800, 1500, 6, 250, 700 )

-- Hama intercept
A2ADispatcher_Red:SetSquadron( "Hama", AIRBASE.Syria.Hama, { "M21" } )
A2ADispatcher_Red:SetSquadronTakeoffFromParkingHot( "Hama" )
A2ADispatcher_Red:SetSquadronLandingAtRunway( "Hama" )
A2ADispatcher_Red:SetSquadronOverhead( "Hama", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "Hama", 2, true )
A2ADispatcher_Red:SetSquadronGci( "Hama", 1000, 1500, 4, 250, 700 )

-- Airspawn 2 CAP
A2ADispatcher_Red:SetSquadron( "77th", "Airspawn 2", { "M21", "M23", "M25" } )
A2ADispatcher_Red:SetSquadronTakeoffInAir( "77th" )
A2ADispatcher_Red:SetSquadronLandingNearAirbase( "77th" )
A2ADispatcher_Red:SetSquadronOverhead( "77th", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "77th", 2, true )
A2ADispatcher_Red:SetSquadronCap( "77th", CAPZone2, 4000, 7000, 500, 900, 900, 1500 )
A2ADispatcher_Red:SetSquadronCapInterval( "77th", 0, 350, 1400 )

-- Palmyra CAP + intercept
A2ADispatcher_Red:SetSquadron( "Palmyra", AIRBASE.Syria.Palmyra, { "M21", "M23", "M25" } )
A2ADispatcher_Red:SetSquadronTakeoffFromParkingHot( "Palmyra" )
A2ADispatcher_Red:SetSquadronLandingAtRunway( "Palmyra" )
A2ADispatcher_Red:SetSquadronOverhead( "Palmyra", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "Palmyra", 2, true )
A2ADispatcher_Red:SetSquadronCap( "Palmyra", CAPZone4, 7000, 10000, 500, 900, 900, 1800 )
A2ADispatcher_Red:SetSquadronCapInterval( "Palmyra", 1, 350, 1400 )
A2ADispatcher_Red:SetSquadronGci( "Palmyra", 1000, 1500, 4, 250, 700 )

-- Airspawn 3 CAP
A2ADispatcher_Red:SetSquadron( "38th", "Airspawn 3", { "M23", "M25", "M29" } )
A2ADispatcher_Red:SetSquadronTakeoffInAir( "38th" )
A2ADispatcher_Red:SetSquadronLandingNearAirbase( "38th" )
A2ADispatcher_Red:SetSquadronOverhead( "38th", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "38th", 2, true )
A2ADispatcher_Red:SetSquadronCap( "38th", CAPZone3, 4000, 7000, 500, 900, 900, 1500 )
A2ADispatcher_Red:SetSquadronCapInterval( "38th", 0, 350, 1400 )

-- Damascus intercept
A2ADispatcher_Red:SetSquadron( "Damascus", AIRBASE.Syria.Mezzeh, { "M23", "M29" } )
A2ADispatcher_Red:SetSquadronTakeoffInAir( "Damascus" )
A2ADispatcher_Red:SetSquadronLandingAtRunway( "Damascus" )
A2ADispatcher_Red:SetSquadronOverhead( "Damascus", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "Damascus", 2, true )
A2ADispatcher_Red:SetSquadronGci( "Damascus", 800, 1500, 6, 250, 700 )

-- Damascus Mig-29 CAP
A2ADispatcher_Red:SetSquadron( "Damascus M29", AIRBASE.Syria.Mezzeh, { "M29" } )
A2ADispatcher_Red:SetSquadronTakeoffInAir( "Damascus M29" )
A2ADispatcher_Red:SetSquadronLandingAtRunway( "Damascus M29" )
A2ADispatcher_Red:SetSquadronOverhead( "Damascus M29", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "Damascus M29", 2, true )
A2ADispatcher_Red:SetSquadronCap( "Damascus M29", CAPZone3, 4000, 7000, 500, 900, 900, 1500 )
A2ADispatcher_Red:SetSquadronCapInterval( "Damascus M29", 1, 350, 900 )

-- Debug messages
-- A2ADispatcher_Red:SetTacticalDisplay(true)
-- A2ADispatcher_Blue:SetTacticalDisplay(true)

A2ADispatcher_Red:Start()
A2ADispatcher_Blue:Start()

local CAP_Level = 0

-- Dynamically adjust blue CAP according to player count
-- Note: the CAP amounts are *groups*, so 1x CAP = 2 planes
-- Note: existing aircraft are not removed from CAP duty until they RTB
local PlayerCheck = TIMER:New(function()
    local numPlayers = #coalition.getPlayers(coalition.side.BLUE)
    if numPlayers < 5 then
        -- 0-4 players
        if CAP_Level ~= 4 then
            CAP_Level = 4
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F4E", 0, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F5E", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F15C", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik M2000C", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Fleet F18", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Fleet F14", 1, 120, 180 )
            env.info("Setting blue CAP level to 4 (maximum)")
        end
    elseif numPlayers < 10 then
        -- 5-9 players
        if CAP_Level ~= 3 then
            CAP_Level = 3
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F4E", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F5E", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F15C", 0, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik M2000C", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Fleet F18", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Fleet F14", 1, 120, 180 )
            env.info("Setting blue CAP level to 3 (strong)")
        end
    elseif numPlayers < 15 then
        -- 10-14 players
        if CAP_Level ~= 2 then
            CAP_Level = 2
            -- 10-14 players
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F4E", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F5E", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F15C", 0, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik M2000C", 0, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Fleet F18", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Fleet F14", 0, 120, 180 )
            env.info("Setting blue CAP level to 2 (medium)")
        end
    else
        -- 15+ players
        if CAP_Level ~= 1 then
            CAP_Level = 1
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F4E", 0, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F5E", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik F15C", 0, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik M2000C", 0, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Fleet F18", 1, 120, 180 )
            A2ADispatcher_Blue:SetSquadronCapInterval( "Fleet F14", 0, 120, 180 )
            env.info("Setting blue CAP level to 1 (weak)")
        end
    end
end)

PlayerCheck:Start(nil, 60)
