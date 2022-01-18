--now setting blue
local EWR_Blue = SET_GROUP:New()
EWR_Blue:FilterPrefixes( { "WIZARD", "DARKSTAR"} ) 
EWR_Blue:FilterStart()
local Detection_Blue = DETECTION_AREAS:New( EWR_Blue, 10 )
A2ADispatcher_Blue = AI_A2A_DISPATCHER:New( Detection_Blue )
A2ADispatcher_Blue:SetCommandCenter( BCC )
A2ADispatcher_Blue:SetEngageRadius( 70000 )

--setting area to cap
CAPZone1 = ZONE_POLYGON:New( "CapZone1", GROUP:FindByName( "CapZone1" ) )
CAPZone2 = ZONE_POLYGON:New( "CapZone2", GROUP:FindByName( "CapZone2" ) )
CAPZone3 = ZONE_POLYGON:New( "CapZone3", GROUP:FindByName( "CapZone3" ) )
BluCap = ZONE_POLYGON:New( "BluCap", GROUP:FindByName( "BluCap" ) )
FleetCAP = ZONE_POLYGON:New( "FleetCAP", GROUP:FindByName( "FleetCAP" ) )

--Setting Blue CAP
A2ADispatcher_Blue:SetSquadron( "Incirlik", AIRBASE.Syria.Incirlik, { "F4", "F5", "M2000", "F15C"}, 300 )
A2ADispatcher_Blue:SetSquadronTakeoffInAir( "Incirlik" )
A2ADispatcher_Blue:SetSquadronLandingNearAirbase( "Incirlik" )
A2ADispatcher_Blue:SetSquadronOverhead( "Incirlik", 1 )--w    ill engage with an overhead of 1  
A2ADispatcher_Blue:SetSquadronGrouping( "Incirlik", 2 )--aicraft in a flight
--CAP zone and parameters(name, Area, min alt, max alt, min speed patrol, max speed patrol, min speed engage, max speed engage)
A2ADispatcher_Blue:SetSquadronCap( "Incirlik", BluCap, 6000, 8000, 460, 1250, 800, 1500 )
A2ADispatcher_Blue:SetSquadronCapInterval( "Incirlik", 2, 120, 180 )--spawn aircraft at a timeframe of 120s to 180s
--CAP minumum fuel and refuel tanker

--Setting Blue CAP
A2ADispatcher_Blue:SetSquadron( "Fleet", AIRBASE.Syria.Larnaca, { "F14", "F18" }, 200 )
A2ADispatcher_Blue:SetSquadronTakeoffFromParkingHot( "Fleet" )
A2ADispatcher_Blue:SetSquadronLandingNearAirbase( "Fleet" )
A2ADispatcher_Blue:SetSquadronOverhead( "Fleet", 1 )--will engage with an overhead of 1
A2ADispatcher_Blue:SetSquadronGrouping( "Fleet", 2 )--aicraft in a flight
--CAP zone and parameters(name, Area, min alt, max alt, min speed patrol, max speed patrol, min speed engage, max speed engage)
A2ADispatcher_Blue:SetSquadronCap( "Fleet", FleetCAP, 6000, 8000, 460, 1250, 800, 1500 )
A2ADispatcher_Blue:SetSquadronCapInterval( "Fleet", 1, 120, 180 )--spawn aircraft at a timeframe of 120s to 180s
--CAP minumum fuel and refuel tanker

--setting EWR
local EWR_Red = SET_GROUP:New()
EWR_Red:FilterPrefixes( { "Awacs", "EWR" } )--prefixes on EWR groups
EWR_Red:FilterStart()--start
local Detection_Red = DETECTION_AREAS:New( EWR_Red, 6 )--grouping
A2ADispatcher_Red = AI_A2A_DISPATCHER:New( Detection_Red )--detection class to a2a AI_A2A_DISPATCHER
A2ADispatcher_Red:SetCommandCenter( CC )--set Command
A2ADispatcher_Red:SetEngageRadius( 60000 )--engament radius of 60km

--setting Red CAP group(name, base, groups, max aircraft)
A2ADispatcher_Red:SetSquadron( "Aleppo", AIRBASE.Syria.Aleppo, { "M21", "M19", "M23" }, 400 )
A2ADispatcher_Red:SetSquadronTakeoffFromParkingHot( "Aleppo" )
A2ADispatcher_Red:SetSquadronLandingNearAirbase( "Aleppo" )
A2ADispatcher_Red:SetSquadronOverhead( "Aleppo", 1 )--will engage with an overhead of 1
A2ADispatcher_Red:SetSquadronGrouping( "Aleppo", 2 )--aicraft in a flight
--CAP zone and parameters(name, Area, min alt, max alt, min speed patrol, max speed patrol, min speed engage, max speed engage)
A2ADispatcher_Red:SetSquadronCap( "Aleppo", CAPZone1, 4000, 7000, 460, 1250, 800, 1500 )
A2ADispatcher_Red:SetSquadronCapInterval( "Aleppo", 1, 350, 1400 )--spawn aircraft at a timeframe of 350s to 1400s

A2ADispatcher_Red:SetSquadron( "39th", "Airspawn 1", { "M21", "M19" }, 400 )
A2ADispatcher_Red:SetSquadronTakeoffInAir( "39th" )
A2ADispatcher_Red:SetSquadronLandingNearAirbase( "39th" )
A2ADispatcher_Red:SetSquadronOverhead( "39th", 1 )--will engage with an overhead of 1
A2ADispatcher_Red:SetSquadronGrouping( "39th", 2 )--aicraft in a flight
--CAP zone and parameters(name, Area, min alt, max alt, min speed patrol, max speed patrol, min speed engage, max speed engage)
A2ADispatcher_Red:SetSquadronCap( "39th", CAPZone1, 4000, 7000, 460, 1250, 800, 1500 )
A2ADispatcher_Red:SetSquadronCapInterval( "39th", 1, 350, 1400 )--spawn aircraft at a timeframe of 350s to 900s

--setting Red CAP group(name, base, groups, max aircraft)
A2ADispatcher_Red:SetSquadron( "Kuweires", AIRBASE.Syria.Kuweires, { "M21", "M19" }, 400 )
A2ADispatcher_Red:SetSquadronTakeoffFromParkingHot( "Kuweires" )
A2ADispatcher_Red:SetSquadronLandingNearAirbase( "Kuweires" )
A2ADispatcher_Red:SetSquadronOverhead( "Kuweires", 1 )--will engage with an overhead of 1
A2ADispatcher_Red:SetSquadronGrouping( "Kuweires", 2 )--aicraft in a flight
--CAP zone and parameters(name, Area, min alt, max alt, min speed patrol, max speed patrol, min speed engage, max speed engage)
A2ADispatcher_Red:SetSquadronCap( "Kuweires", CAPZone1, 4000, 7000, 460, 1250, 800, 1500 )
A2ADispatcher_Red:SetSquadronCapInterval( "Kuweires", 1, 350, 1400 )--spawn aircraft at a timeframe of 100s to 300s

--CAP Zone 2

--setting CAP group
A2ADispatcher_Red:SetSquadron( "Bassel", AIRBASE.Syria.Bassel_Al_Assad, { "M21", "M23" }, 400 )
A2ADispatcher_Red:SetSquadronTakeoffFromParkingHot( "Bassel" )
A2ADispatcher_Red:SetSquadronLandingNearAirbase( "Bassel" )
A2ADispatcher_Red:SetSquadronOverhead( "Bassel", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "Bassel", 2 )
--CAP zone and parameters
A2ADispatcher_Red:SetSquadronCap( "Bassel", CAPZone2, 4000, 7000, 500, 1200, 600, 1500 )
A2ADispatcher_Red:SetSquadronCapInterval( "Bassel", 2, 350, 1400 )

--setting CAP group
A2ADispatcher_Red:SetSquadron( "77th", "Airspawn 2", { "M25", "M21", "M23" }, 400 )
A2ADispatcher_Red:SetSquadronTakeoffInAir( "77th" )
A2ADispatcher_Red:SetSquadronLandingNearAirbase( "77th" )
A2ADispatcher_Red:SetSquadronOverhead( "77th", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "77th", 2 )
--CAP zone and parameters
A2ADispatcher_Red:SetSquadronCap( "77th", CAPZone2, 4000, 7000, 500, 1200, 600, 1500 )
A2ADispatcher_Red:SetSquadronCapInterval( "77th", 1, 350, 1400 )

--setting CAP group
A2ADispatcher_Red:SetSquadron( "Palmyra", AIRBASE.Syria.Palmyra, { "M23", "M21" }, 400 )
A2ADispatcher_Red:SetSquadronTakeoffFromParkingHot( "Palmyra" )
A2ADispatcher_Red:SetSquadronLandingNearAirbase( "Palmyra" )
A2ADispatcher_Red:SetSquadronOverhead( "Palmyra", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "Palmyra", 2 )
--CAP zone and parameters
A2ADispatcher_Red:SetSquadronCap( "Palmyra", CAPZone4, 4000, 7000, 500, 1200, 600, 1500 )
A2ADispatcher_Red:SetSquadronCapInterval( "Palmyra", 1, 350, 1400 )

--CapZone 3

--setting CAP group
A2ADispatcher_Red:SetSquadron( "38th", "Airspawn 3", { "M25", "M23", "M29" }, 400 )
A2ADispatcher_Red:SetSquadronTakeoffInAir( "38th" )
A2ADispatcher_Red:SetSquadronLandingNearAirbase( "38th" )
A2ADispatcher_Red:SetSquadronOverhead( "38th", 1 )
A2ADispatcher_Red:SetSquadronGrouping( "38th", 2 )
--CAP zone and parameters
A2ADispatcher_Red:SetSquadronCap( "38th", CAPZone3, 4000, 7000, 500, 1200, 600, 1500 )
A2ADispatcher_Red:SetSquadronCapInterval( "38th", 1, 350, 900 )

A2ADispatcher_Red:Start()
A2ADispatcher_Blue:Start()