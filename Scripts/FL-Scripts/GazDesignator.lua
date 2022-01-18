--GazDesignate v. 1.4 by Cake
GazDesignate = {} --never delete this!!!

--#########CONFIG SECTION START#########

GazDesignate.EnabledUnits = { "4e RHC 1-1",--Corresponds with the field "Pilot Name" in the Mission Editor. Only SA342M whose Pilots are listed here can use the designator
                              "4e RHC 1-2",
                              "4e RHC 1-3",
                              "4e RHC 1-4",                            
                            }
                               
GazDesignate.LaserPresets = { 1788, --Codes entered here can be selected from the F10-Menu option "Presets", only the first 10 entries will be selectable in game! 
                              1777,
                              1766,
                              1755,
                              1688,
                              1677,
                              1666,
                              1655,
                              1588,
                              1577 }

GazDesignate.UpdateInt = 0.1 --Seconds between each recalculation of the laser point, while laser is active, adjust to longer intervals if you run into performance issues 
                               
GazDesignate.ToleranceGaz = 30 -- (m) radius around the calculated laser point (in 3d Space), if there is a target within this radius, the laser will snap to it. Set to 0 to turn off the snapping function 

GazDesignate.MsgDispTime = 60 --Time in seconds that messages containing target point information (lat/long, range, elevation) get displayed

GazDesignate.MenuInt = 30 --Interval in seconds in which the script checks for newly spawned pilots, should always be bigger than MenuBuildDel, otherwise duplication of loading messages will happen!
GazDesignate.MenuBuildDel = 15 --Delay between detection of a newly spawned pilot by the script and the creation of his new radio menu items, use together with MenuInt to control the list position of the GazDesignate-Menu

--#########CONFIG SECTION END, VALUES BELOW ARE FOR DEBUGGING PURPOSES ONLY#########

--Maximum tolerances for movement of viviane sight and helo before a new tgt point is calculated
GazDesignate.OffHeadTolGaz = 0.025 --Heading
GazDesignate.OffVAngTolGaz = 0.05 --Vertical angle
GazDesignate.AltVarGaz = 0.5 --Altitude (m)
GazDesignate.DiagMode = false --Diagnostic mode enables feedback messages to better understand causes for tgt point recalculation, only needed for debugging

GazDesignate.MinDwnAng = -0.1 --These values are only needed for debugging
GazDesignate.MinUpAng = 0.1

GazDesignate.Range = {}
GazDesignate.ActiveLasers = {}
GazDesignate.ActiveLasers.Lsr = {}
GazDesignate.ActiveLasers.IR = {}
GazDesignate.Codes = {}
GazDesignate.MainMen = {}
GazDesignate.SubMen1 = {}
GazDesignate.SubMen2 = {}
GazDesignate.SubMen3 = {}

--some loops to prevent bozos from bricking the script by making nonsensical entries in the config section
if GazDesignate.ToleranceGaz == nil then GazDesignate.ToleranceGaz = 0 end
if GazDesignate.OffHeadTolGaz == nil then GazDesignate.OffHeadTolGaz = 0 end
if GazDesignate.OffVAngTolGaz == nil then GazDesignate.OffVAngTolGaz = 0 end
if GazDesignate.AltVarGaz == nil then GazDesignate.AltVarGaz = 0 end
if GazDesignate.UpdateInt == nil or GazDesignate.UpdateInt <= 0 then GazDesignate.UpdateInt = 0.05 end
if GazDesignate.MenuInt == nil or GazDesignate.MenuInt <= 0 then GazDesignate.MenuInt = 1 end
if GazDesignate.MenuBuildDel == nil or GazDesignate.MenuBuildDel <= 0 or GazDesignate.MenuBuildDel > GazDesignate.MenuInt then GazDesignate.MenuBuildDel = GazDesignate.MenuInt - 0.25 end


GazDesignate.OffHeadTolGaz = math.rad(GazDesignate.OffHeadTolGaz)
GazDesignate.OffVAngTolGaz = math.rad(GazDesignate.OffVAngTolGaz)



function GazDesignate.WrongButton(WBArgs) --having a menu command without a function is not possible...so this is what you get when you hit one of the placeholders in the code adjustment menu

 trigger.action.outTextForGroup(WBArgs.id, "You missed the button you wanted to press, please try again!", 10)

end

function GazDesignate.ShowRange(SRArgs)

  trigger.action.outTextForGroup(SRArgs.id, "Range currently set to " .. math.floor(GazDesignate.Range[SRArgs.name]) .. " m!", 10)

end

function GazDesignate.ShowCode(SCArgs)

  trigger.action.outTextForGroup(SCArgs.ID, "Lasercode currently set to " .. GazDesignate.Codes[SCArgs.name] .. "!", 10)

end

function GazDesignate.CalcTgtPoint(Range, Heading, Origin)
  
  local CalcPoint = {}
  
  CalcPoint.x = Range * math.cos( Heading ) + Origin.x
  CalcPoint.z  = Range * math.sin( Heading ) + Origin.z
  CalcPoint.y = land.getHeight({x = CalcPoint.x, y = CalcPoint.z})
  
  return CalcPoint

end

function GazDesignate.CalcRangeToPoint(HeloPoint, TgtPoint)

  local Range = ((HeloPoint.x - TgtPoint.x) ^ 2 + (HeloPoint.y - TgtPoint.y) ^ 2 + (HeloPoint.z - TgtPoint.z) ^ 2) ^ 0.5
  
  return Range

end

function GazDesignate.XYtoLLString(Point)

  local LatDeg = nil
  local LatMin = nil
  local LatDecSec = nil
  
  local LongDeg = nil
  local LongMin = nil
  local LongDecSec = nil
  
  LatDeg, LongDeg = coord.LOtoLL(Point)
  
  LatDeg, LatMin = math.modf(LatDeg)
  LatMin = LatMin * 60
  LatMin, LatDecSec = math.modf(LatMin)
  LatDecSec = LatDecSec * 1000
  
  LongDeg, LongMin = math.modf(LongDeg)
  LongMin = LongMin * 60
  LongMin, LongDecSec = math.modf(LongMin)
  LongDecSec = LongDecSec * 1000
  
  local LatString = string.format("%.2i %.2i.%.3d", LatDeg, LatMin, LatDecSec)
  local LongString = string.format("%.3i %.2i.%.3d", LongDeg, LongMin, LongDecSec)

  local LLString = "Lat: " .. LatString .. " Long: " .. LongString
  
  return LLString

end

function GazDesignate.XYtoMGRSString(Point)

  local Lat = nil
  local Long = nil
  
  Lat, Long = coord.LOtoLL(Point)
  
  local MGRS = coord.LLtoMGRS(Lat, Long)
  
  local MGRSString = MGRS.UTMZone .. " " .. MGRS.MGRSDigraph .. " " .. MGRS.Easting .. " " .. MGRS.Northing
  
  return MGRSString

end

function GazDesignate.BangTgtPointDwn(Heading, Origin, VertAngle)
   
  local ProvTgtPoint = {}
  local CalcTgtPoint = {}
  local ProvRange = nil
  local CalcY = nil
  local LastRange = nil
  local CalcRange = nil
  local BangCond = 0
  
  local CalcCounter = 0
  
  Origin.y = Origin.y + 1.23--lets try this, compensating for the elevation of the sight above the zero point of the helo
   
  for Range = 1000, 20000, 1000
  
    do ProvRange = Range * math.sin(VertAngle)
       
       ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
       ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
       ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
       
       CalcY = Origin.y - math.cos(VertAngle) * Range
       
       CalcCounter = CalcCounter + 1
       
       if CalcY < ProvTgtPoint.y --Hooray, we passed the ground level!
       
        then LastRange = Range
             BangCond = 1
             
             break
        
       end

  end
  
  if BangCond > 0 --only proceed if the first loop has found ground within 20000 m of range
  
    then for Range = LastRange - 1000, LastRange, 100
  
           do ProvRange = Range * math.sin(VertAngle)
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
              
              CalcY = Origin.y - math.cos(VertAngle) * Range
              
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we passed the ground level again!
       
               then LastRange = Range
    
                    break
        
              end
  
         end
         
         for Range = LastRange - 100, LastRange, 10
  
           do ProvRange = Range * math.sin(VertAngle)
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
              
              CalcY = Origin.y - math.cos(VertAngle) * Range
              
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we passed the ground level again!
       
               then LastRange = Range
                  
                    break
        
              end
  
         end
         
         for Range = LastRange - 10, LastRange, 1
  
           do ProvRange = Range * math.sin(VertAngle)
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
              
              CalcY = Origin.y - math.cos(VertAngle) * Range
              
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we passed the ground level again!
       
               then LastRange = Range

                    break
        
              end
  
         end
         
         for Range = LastRange - 1, LastRange, 0.1
  
           do ProvRange = Range * math.sin(VertAngle)
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
              
              CalcY = Origin.y - math.cos(VertAngle) * Range
              
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we passed the ground level again!
       
               then LastRange = Range

                    break
        
              end
  
         end
         
         LastRange = LastRange * 1.000043 --For some reason i always get a static difference between calculated diag ranges and ranges measured by the sight       
         if LastRange > 6000 then LastRange = LastRange * 1.000075 end
           
         CalcRange = LastRange * math.sin(VertAngle)
         
         CalcTgtPoint.x = CalcRange * math.cos( Heading ) + Origin.x
         CalcTgtPoint.z  = CalcRange * math.sin( Heading ) + Origin.z
         CalcTgtPoint.y = land.getHeight({x = CalcTgtPoint.x, y = CalcTgtPoint.z})
         CalcTgtPoint.DiagRange = LastRange
         CalcTgtPoint.CalcNum = CalcCounter 
         
         return CalcTgtPoint
    
  else return nil --if the first loop did not find ground then the angle must be really shallow, or the sight is facing against the sky. Nil is returned in that case!
  
  end
    
end

function GazDesignate.BangTgtPointLevel(Heading, Origin)
   
  local ProvTgtPoint = {}
  local CalcTgtPoint = {}
  local ProvRange = nil
  local CalcY = Origin.y
  local LastRange = nil
  local CalcRange = nil
  local BangCond = 0
  
  local CalcCounter = 0
   
  for Range = 1000, 20000, 1000
  
    do ProvRange = Range
       
       ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
       ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
       ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
       
       CalcCounter = CalcCounter + 1
       
       if CalcY < ProvTgtPoint.y--Hooray, we found the ground level!
       
        then LastRange = Range
             BangCond = 1
             
             break
        
       end

  end
  
  if BangCond > 0 --only proceed if the first loop has found ground within 20000 m of range
  
    then for Range = LastRange - 1000, LastRange, 100
  
           do ProvRange = Range
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
       
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we found the ground level again!
       
               then LastRange = Range
                    BangCond = 1
             
                    break
        
              end

         end
         
         for Range = LastRange - 100, LastRange, 10
  
           do ProvRange = Range
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
       
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we found the ground level again!
       
               then LastRange = Range
                    BangCond = 1
             
                    break
        
              end

         end
         
         for Range = LastRange - 10, LastRange, 1
  
           do ProvRange = Range
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
       
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we found the ground level again!
       
               then LastRange = Range
                    BangCond = 1
             
                    break
        
              end

         end
         
         for Range = LastRange - 1, LastRange, 0.1
  
           do ProvRange = Range
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
       
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we found the ground level again!
       
               then LastRange = Range
                    BangCond = 1
             
                    break
        
              end

         end
  
         CalcRange = LastRange
         
         CalcTgtPoint.x = CalcRange * math.cos( Heading ) + Origin.x
         CalcTgtPoint.z  = CalcRange * math.sin( Heading ) + Origin.z
         CalcTgtPoint.y = land.getHeight({x = CalcTgtPoint.x, y = CalcTgtPoint.z})
         CalcTgtPoint.DiagRange = LastRange
         CalcTgtPoint.CalcNum = CalcCounter         
         
         return CalcTgtPoint
    
  else return nil --if the first loop did not find ground then the angle must be really shallow, or the sight is facing against the sky. Nil is returned in that case!
  
  end
    
end

function GazDesignate.BangTgtPointUp(Heading, Origin, VertAngle)
   
  local ProvTgtPoint = {}
  local CalcTgtPoint = {}
  local ProvRange = nil
  local CalcY = nil
  local LastRange = nil
  local CalcRange = nil
  local BangCond = 0
  
  local CalcCounter = 0
   
  for Range = 1000, 20000, 1000
  
    do ProvRange = Range * math.cos(VertAngle)
       
       ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
       ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
       ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
       
       CalcY = math.sin(VertAngle) * Range + Origin.y
       
       CalcCounter = CalcCounter + 1
       
       if CalcY < ProvTgtPoint.y --Hooray, we passed the ground level!
       
        then LastRange = Range
             BangCond = 1
             
             break
        
       end

  end
  
  if BangCond > 0 --only proceed if the first loop has found ground within 20000 m of range
  
    then for Range = LastRange - 1000, LastRange, 100
  
           do ProvRange = Range * math.cos(VertAngle)
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
              
              CalcY = math.sin(VertAngle) * Range + Origin.y
              
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we passed the ground level again!
       
               then LastRange = Range
        
                    break
        
              end
  
         end
         
         for Range = LastRange - 100, LastRange, 10
  
           do ProvRange = Range * math.cos(VertAngle)
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
              
              CalcY = math.sin(VertAngle) * Range + Origin.y
              
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we passed the ground level again!
       
               then LastRange = Range
        
                    break
        
              end
  
         end
         
         for Range = LastRange - 10, LastRange, 1
  
           do ProvRange = Range * math.cos(VertAngle)
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
              
              CalcY = math.sin(VertAngle) * Range + Origin.y
              
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we passed the ground level again!
       
               then LastRange = Range
        
                    break
        
              end
  
         end
         
         for Range = LastRange - 1, LastRange, 0.1
  
           do ProvRange = Range * math.cos(VertAngle)
    
              ProvTgtPoint.x = ProvRange * math.cos( Heading ) + Origin.x
              ProvTgtPoint.z  = ProvRange * math.sin( Heading ) + Origin.z
              ProvTgtPoint.y = land.getHeight({x = ProvTgtPoint.x, y = ProvTgtPoint.z})
              
              CalcY = math.sin(VertAngle) * Range + Origin.y
              
              CalcCounter = CalcCounter + 1
       
              if CalcY < ProvTgtPoint.y --Hooray, we passed the ground level again!
       
               then LastRange = Range
        
                    break
        
              end
  
         end
  
         CalcRange = LastRange * math.cos(VertAngle)
         
         CalcTgtPoint.x = CalcRange * math.cos( Heading ) + Origin.x
         CalcTgtPoint.z  = CalcRange * math.sin( Heading ) + Origin.z
         CalcTgtPoint.y = land.getHeight({x = CalcTgtPoint.x, y = CalcTgtPoint.z})
         CalcTgtPoint.DiagRange = LastRange
         CalcTgtPoint.CalcNum = CalcCounter 
         
         return CalcTgtPoint
    
  else return nil --if the first loop did not find ground then the angle must be really shallow, or the sight is facing against the sky. Nil is returned in that case!
  
  end
    
end

function GazDesignate.ResRange(RResArgs)

  if GazDesignate.ActiveLasers.Lsr[RResArgs.name] == nil and GazDesignate.ActiveLasers.IR[RResArgs.name] == nil
  
    then GazDesignate.Range[RResArgs.name] = 0
         trigger.action.outTextForGroup(RResArgs.id, "Range reset to 0 m!", 10)
         
  else trigger.action.outTextForGroup(RResArgs.id, "Your designator is active, range can't be reset!!", 10)
  
  end

end

function GazDesignate.AdjRange(RArgs)
  
  local RangeStr = nil
  local NewRangeStr = nil
  
  if GazDesignate.Range[RArgs.name] == nil
  
    then RangeStr = "00000"
    
  else RangeStr = tostring(math.floor(GazDesignate.Range[RArgs.name]))
  
  end
  
  local RangeInt = string.format("%05d", RangeStr) 
  RangeStr = tostring(RangeInt)

  local RStringLen = string.len(RangeStr)
  local DigitsStr = {}
  
  for i = RStringLen, 1, -1 --go through the rangestring from the back and store every letter(number) in a different field  
  
    do  DigitsStr[i] = string.sub(RangeStr, i, i)
    
  end
  
  DigitsStr[RArgs.digit] = RArgs.val
    
  NewRangeStr = table.concat(DigitsStr, nil, 1, #DigitsStr)
  
  GazDesignate.Range[RArgs.name] = tonumber(NewRangeStr)
  
  trigger.action.outTextForGroup(RArgs.id, "Range set to " .. NewRangeStr.. " m!", 10, true)
  
end

function GazDesignate.AdjRangeRel(RRelArgs)
  
  if GazDesignate.Range[RRelArgs.name] + RRelArgs.val > 0
  
    then GazDesignate.Range[RRelArgs.name] = GazDesignate.Range[RRelArgs.name] + RRelArgs.val
  
         trigger.action.outTextForGroup(RRelArgs.group, "Range set to " .. math.floor(GazDesignate.Range[RRelArgs.name]).. " m!", 10, true)
         
  else trigger.action.outTextForGroup(RRelArgs.group, "Requested range change invalid, can't set negative ranges!", 10, true)
  
  end

end

function GazDesignate.AdjCode(CArgs)
 
  if CArgs.preset == nil
  
    then local CodeStr = tostring(GazDesignate.Codes[CArgs.name])
         local FrontPart = nil
         local MiddlePart = nil
         local EndPart = nil
         local NewCodeStr = nil
    
         if CArgs.digit == 2
  
          then FrontPart = string.sub(CodeStr, 1,1)
               MiddlePart = tostring(CArgs.val)
               EndPart = string.sub(CodeStr, 3,4)
               NewCodeStr = string.format("%s%s%s", FrontPart, MiddlePart, EndPart)                
         
         elseif CArgs.digit == 3
  
          then FrontPart = string.sub(CodeStr, 1,2)
               MiddlePart = tostring(CArgs.val)
               EndPart = string.sub(CodeStr, 4,4)
               NewCodeStr = string.format("%s%s%s", FrontPart, MiddlePart, EndPart)
         
         elseif CArgs.digit == 4
  
          then FrontPart = string.sub(CodeStr, 1,3)
               EndPart = tostring(CArgs.val)
               NewCodeStr = string.format("%s%s", FrontPart, EndPart) 
                  
         end
         
         GazDesignate.Codes[CArgs.name] = tonumber(NewCodeStr)
         
  else GazDesignate.Codes[CArgs.name] = CArgs.preset
  
  end   
  
  trigger.action.outTextForGroup(CArgs.id, "Lasercode set to " .. GazDesignate.Codes[CArgs.name] .. "!", 10)

end

function GazDesignate.StopLaserGaz(StArgs)

  if GazDesignate.ActiveLasers.Lsr[StArgs.name] ~= nil or GazDesignate.ActiveLasers.IR[StArgs.name] ~= nil 
  
     then if GazDesignate.ActiveLasers.Lsr[StArgs.name] ~= nil
          
            then GazDesignate.ActiveLasers.Lsr[StArgs.name]:destroy()
                 GazDesignate.ActiveLasers.Lsr[StArgs.name] = nil
                 
          end
          
          if GazDesignate.ActiveLasers.IR[StArgs.name] ~= nil
          
            then GazDesignate.ActiveLasers.IR[StArgs.name]:destroy()
                 GazDesignate.ActiveLasers.IR[StArgs.name] = nil
                 
          end
          
          missionCommands.removeItemForGroup( StArgs.id, GazDesignate.SubMen1[StArgs.name].StopLsr )
          GazDesignate.SubMen1[StArgs.name].StopLsr = nil
          
          GazDesignate.SubMen1[StArgs.name].FireLsr = missionCommands.addCommandForGroup(StArgs.id, "Designate (Laser)", GazDesignate.MainMen[StArgs.name], GazDesignate.CreateLaserGazPrec, {name = StArgs.name, unit = StArgs.unit, id = StArgs.id, type = "Lsr"})
          GazDesignate.SubMen1[StArgs.name].FireIR = missionCommands.addCommandForGroup(StArgs.id, "Designate (IR)", GazDesignate.MainMen[StArgs.name], GazDesignate.CreateLaserGazPrec, {name = StArgs.name, unit = StArgs.unit, id = StArgs.id, type = "IR"})
          GazDesignate.SubMen1[StArgs.name].FireBoth = missionCommands.addCommandForGroup(StArgs.id, "Designate (Both)", GazDesignate.MainMen[StArgs.name], GazDesignate.CreateLaserGazPrec, {name = StArgs.name, unit = StArgs.unit, id = StArgs.id, type = "Both"})
          
          if StArgs.vivoff == true
          
            then trigger.action.outTextForGroup(StArgs.id, "Viviane sight has been stowed! Laser/IR-Pointer off!", 30, true)
            
          else trigger.action.outTextForGroup(StArgs.id, "Laser/IR-Pointer off!", 30, true)
          
          end
          
  end
  
end

function GazDesignate.LsrUpdaterGaz(UArgs)

  if (GazDesignate.ActiveLasers.Lsr[UArgs.name] ~= nil or GazDesignate.ActiveLasers.IR[UArgs.name] ~= nil) and UArgs.unit:isExist() == true and UArgs.unit:getDrawArgumentValue(215) < 0.6666666 --run update function only if there are actually lasers to update and the helo still exists and has its sight deployed
  
   then local CurHeloPos = UArgs.unit:getPosition()
        local CurHeloPoint = UArgs.unit:getPoint()
        local CurHeloAGL = CurHeloPoint.y - land.getHeight({x = CurHeloPoint.x, y = CurHeloPoint.z})
        local CurHeloHead = math.atan2( CurHeloPos.x.z, CurHeloPos.x.x )--current helo heading in rad
        if CurHeloHead < 0 then CurHeloHead = CurHeloHead + 2 * math.pi end
  
        local CurVivHorOffset = math.pi * UArgs.unit:getDrawArgumentValue(215)* -1 --this gets the horizontal orientation of the viviane sight relative to the helo direction in rad!!! *-1, otherwise left and right is switched
        local CurVivHeading = CurHeloHead + CurVivHorOffset --heading the viviane is facing
        local CurVivVertOffset = UArgs.unit:getDrawArgumentValue(216)--this gets the vertical orientation of the viviane sight relative to the gazelle LOS
        local CurVivCalcVOffset = nil
        
        local NewTgtPoint = nil
        local NewTgtRange = nil
        local ReCalcDiagRange = nil
        local NewScanResults = {}
        local NewScanSpace = {}
        
        local NewTgtLL = nil
        local NewTgtMGRS = nil
        local NewTgtAlt = nil
        
        local LasingCondLLim = (1/18) * GazDesignate.MinDwnAng
        local LasingCondULim = (1/13) * GazDesignate.MinUpAng
        local UpdtCond = 0
  
        if CurVivVertOffset < 0 
  
          then CurVivCalcVOffset =  math.pi/2 + CurVivVertOffset * math.rad(18)
    
        elseif CurVivVertOffset > 0
  
          then CurVivCalcVOffset =  CurVivVertOffset * math.rad(13)
    
        else CurVivCalcVOffset = 0
  
        end
          
        
        if UArgs.code ~= GazDesignate.Codes[UArgs.name] 
        
          or GazDesignate.Range[UArgs.name] ~= UArgs.range 
          
            or math.abs(CurVivHeading - UArgs.shead) > GazDesignate.OffHeadTolGaz 
            
              or (math.abs(CurVivCalcVOffset - UArgs.svang) > GazDesignate.OffVAngTolGaz and math.abs(CurHeloAGL - UArgs.agl) < GazDesignate.AltVarGaz)
          
                then if UArgs.code ~= GazDesignate.Codes[UArgs.name] and GazDesignate.ActiveLasers.Lsr[UArgs.name] ~= nil
                
                        then GazDesignate.ActiveLasers.Lsr[UArgs.name]:setCode(GazDesignate.Codes[UArgs.name])
                             
                             UpdtCond = 1
                      
                     elseif GazDesignate.Range[UArgs.name] ~= UArgs.range
                
                        then if CurVivVertOffset < LasingCondLLim
          
                              then NewTgtRange = GazDesignate.Range[UArgs.name] * math.sin(CurVivCalcVOffset)
                                   ReCalcDiagRange  = NewTgtRange / math.sin(CurVivCalcVOffset)
                                   
                                   NewTgtPoint = GazDesignate.CalcTgtPoint(NewTgtRange, CurVivHeading , CurHeloPoint)
                                   
                                   UpdtCond = 2
                
                             elseif CurVivVertOffset >= LasingCondLLim and CurVivVertOffset <= LasingCondULim
                
                              then NewTgtRange = GazDesignate.Range[UArgs.name]
                                   ReCalcDiagRange  = NewTgtRange
                                   
                                   NewTgtPoint = GazDesignate.CalcTgtPoint(NewTgtRange, CurVivHeading , CurHeloPoint)
                                   
                                   UpdtCond = 3
                        
                             elseif CurVivVertOffset > LasingCondULim
                       
                              then NewTgtRange = GazDesignate.Range[UArgs.name] * math.cos(CurVivCalcVOffset)
                                   ReCalcDiagRange  = NewTgtRange / math.cos(CurVivCalcVOffset)
                                   
                                   NewTgtPoint = GazDesignate.CalcTgtPoint(NewTgtRange, CurVivHeading , CurHeloPoint)
                                   
                                   UpdtCond = 4
                
                             end

                     elseif math.abs(CurVivHeading - UArgs.shead) > GazDesignate.OffHeadTolGaz or (math.abs(CurVivCalcVOffset - UArgs.svang) > GazDesignate.OffVAngTolGaz and math.abs(CurHeloAGL - UArgs.agl) < GazDesignate.AltVarGaz)
               
                        then if GazDesignate.DiagMode == true
                       
                              then if math.abs(CurVivHeading - UArgs.shead) > GazDesignate.OffHeadTolGaz
                        
                                    then trigger.action.outText("DEBUG: Viviane Heading has changed beyond tolerance!", 10)
                              
                                   elseif math.abs(CurVivCalcVOffset - UArgs.svang) > GazDesignate.OffVAngTolGaz
                             
                                      then trigger.action.outText("DEBUG: Viviane vertical orientation has changed beyond tolerance!", 10)
                                      
                                           if math.abs(CurHeloAGL - UArgs.agl) < GazDesignate.AltVarGaz
                                   
                                            then trigger.action.outText("DEBUG: Altitude change is within tolerance -> Laserpoint needs to be updated!", 10)
                                    
                                           else trigger.action.outText("DEBUG: Altitude change is beyond tolerance -> Laserpoint DOES NOT need to be updated!", 10)
                                           
                                           end
                                   end
                              
                             end
                             
                             UArgs.shead = CurVivHeading
                             UArgs.svang = CurVivCalcVOffset
                             UArgs.agl = CurHeloAGL
                             
                             if CurVivVertOffset < LasingCondLLim
          
                               then NewTgtPoint = GazDesignate.BangTgtPointDwn(CurVivHeading, CurHeloPoint, CurVivCalcVOffset)
                                    
                                    if NewTgtPoint ~= nil
                                    
                                      then ReCalcDiagRange = NewTgtPoint.DiagRange
                                           UpdtCond = 5
                                           
                                    else UpdtCond = -1
                                    
                                    end
                
                             elseif CurVivVertOffset <= LasingCondLLim and CurVivVertOffset >= LasingCondULim
                             
                               then NewTgtPoint = GazDesignate.BangTgtPointLevel(CurVivHeading, CurHeloPoint)
                                    
                                    if NewTgtPoint ~= nil
                                    
                                      then ReCalcDiagRange = NewTgtPoint.DiagRange
                                           UpdtCond = 6
                                           
                                    else UpdtCond = -1
                                    
                                    end
                               
                             elseif CurVivVertOffset > LasingCondULim
                             
                               then NewTgtPoint = GazDesignate.BangTgtPointUp(CurVivHeading, CurHeloPoint, CurVivCalcVOffset)
                                    
                                    if NewTgtPoint ~= nil
                                    
                                      then ReCalcDiagRange = NewTgtPoint.DiagRange
                                           UpdtCond = 7
                                           
                                    else UpdtCond = -1
                                    
                                    end
                                    
                             end
                   end
        end
               
        if UpdtCond >= 2
        
          then if GazDesignate.ToleranceGaz > 0 
  
                 then NewScanSpace = { id = world.VolumeType.SPHERE,
                                       params = { point = NewTgtPoint,
                                                  radius = GazDesignate.ToleranceGaz }
                                      }  
  
                      local function NewScanHandler(NewFoundUnit)
  
                          NewScanResults[#NewScanResults + 1] = NewFoundUnit 
  
                      end
         
                      world.searchObjects(Object.Category.UNIT, NewScanSpace, NewScanHandler)
                       
                      if NewScanResults[1] ~= nil 
                     
                        then NewTgtPoint = NewScanResults[1]:getPoint()
                             NewTgtPoint.y = land.getHeight({x = NewTgtPoint.x, y = NewTgtPoint.z}) 
                             ReCalcDiagRange = GazDesignate.CalcRangeToPoint(CurHeloPoint, NewTgtPoint)
                      end

               end
               
               GazDesignate.Range[UArgs.name] = ReCalcDiagRange
               
               NewTgtLL = GazDesignate.XYtoLLString(NewTgtPoint)
               NewTgtMGRS = GazDesignate.XYtoMGRSString(NewTgtPoint)
               NewTgtAlt = math.floor(NewTgtPoint.y * 3.28084)
                       
               if GazDesignate.DiagMode ~= true
                       
                 then if NewScanResults[1] ~= nil
                       
                        then trigger.action.outTextForGroup(UArgs.id, "Designating target!\n\n" .. NewTgtLL .. "\n\nMGRS: " .. NewTgtMGRS .. "\n\nElev.: " .. NewTgtAlt .. " ft" .. "\n\nDiag. range: " .. math.floor(GazDesignate.Range[UArgs.name]+0.5) .. " m", GazDesignate.MsgDispTime, true )
                               
                      else trigger.action.outTextForGroup(UArgs.id, "Designating ground!\n\n" .. NewTgtLL .. "\n\nMGRS: " .. NewTgtMGRS .. "\n\nElev.: " .. NewTgtAlt .. " ft" .. "\n\nDiag. range: " .. math.floor(GazDesignate.Range[UArgs.name]+0.5) .. " m", GazDesignate.MsgDispTime, true )
                                  
                      end
                                  
               end
               
               if GazDesignate.ActiveLasers.Lsr[UArgs.name] ~= nil 
               
                then GazDesignate.ActiveLasers.Lsr[UArgs.name]:setPoint(NewTgtPoint)

               end
               
               if GazDesignate.ActiveLasers.IR[UArgs.name] ~= nil
               
                then GazDesignate.ActiveLasers.IR[UArgs.name]:setPoint(NewTgtPoint)

               end
               
               UArgs.tgtpoint = NewTgtPoint
        
        elseif UpdtCond == -1
        
          then trigger.action.outTextForGroup(UArgs.id, "Max. designation range of 20 km exceeded, or sight is facing into sky!", 30, true)
        
        end
        
        timer.scheduleFunction(GazDesignate.LsrUpdaterGaz, {name = UArgs.name, 
                                                             unit = UArgs.unit, 
                                                             id = UArgs.id, 
                                                             type = UArgs.type, 
                                                             shead = UArgs.shead, 
                                                             svang = UArgs.svang, 
                                                             agl = UArgs.agl,
                                                             tgtpoint = UArgs.tgtpoint,
                                                             range = GazDesignate.Range[UArgs.name], 
                                                             code = GazDesignate.Codes[UArgs.name]}, timer.getTime() + GazDesignate.UpdateInt)
  
  elseif UArgs.unit:isExist() == false
  
    then if GazDesignate.ActiveLasers.Lsr[UArgs.name] ~= nil
    
           then GazDesignate.ActiveLasers.Lsr[UArgs.name]:destroy()--kill all active lasers and ir-pointers of that helo
                GazDesignate.ActiveLasers.Lsr[UArgs.name] = nil
               
         end
          
         if GazDesignate.ActiveLasers.Lsr[UArgs.name] ~= nil
    
           then GazDesignate.ActiveLasers.IR[UArgs.name]:destroy()
                GazDesignate.ActiveLasers.IR[UArgs.name] = nil
               
         end  
         
         missionCommands.removeItemForGroup(UArgs.id, GazDesignate.MainMen[UArgs.name])--reset the radio menu entries
         GazDesignate.MainMen[UArgs.name] = nil
         
  elseif UArgs.unit:getDrawArgumentValue(215) > 0.6666666666666--sight has been turned off
  
    then local StArgs = {name = UArgs.name, unit = UArgs.unit, id = UArgs.id, vivoff = true}
     
         GazDesignate.StopLaserGaz(StArgs)

  end

end

function GazDesignate.CreateLaserGazPrec(LArgs)
  
  local TgtRange = GazDesignate.Range[LArgs.name]
  local ReCalcDiagRange = nil
  local TgtPoint = {}
  local CalcTgtRange = nil
  local TgtLL = nil
  local TgtMGRS = nil
  local TgtAlt = nil
  
  local HeloPos = LArgs.unit:getPosition()
  local HeloPoint = LArgs.unit:getPoint()
  local HeloAGL = HeloPoint.y - land.getHeight({x = HeloPoint.x, y = HeloPoint.z})
  local HeloHead = math.atan2( HeloPos.x.z, HeloPos.x.x )--heading in rad
  local HeloBeamOri = {x = 1.85, y = 1.23, z = -0.22}--origin point for the lsr, adjusted to viviane position
  
  if HeloHead < 0 then HeloHead = HeloHead + 2 * math.pi end
  
  local VivHorOffset = math.pi * LArgs.unit:getDrawArgumentValue(215)* -1 --this gets the horizontal orientation of the viviane sight relative to the helo direction, format is rad!!! *-1, otherwise left and right is switched
  local VivHeading = HeloHead + VivHorOffset --heading the viviane is facing
  local VivVertOffset = LArgs.unit:getDrawArgumentValue(216)--this gets the vertical orientation of the viviane sight relative to the gazelle LOS
  local VivCalcVOffset = nil
  
  local LasingCond = 0
  local LasingCondLLim = (1/18) * GazDesignate.MinDwnAng
  local LasingCondULim = (1/13) * GazDesignate.MinUpAng

  
  if VivVertOffset < 0 
  
    then VivCalcVOffset =  math.pi/2 + VivVertOffset * math.rad(18)
    
  elseif VivVertOffset > 0
  
    then VivCalcVOffset =  VivVertOffset * math.rad(13)
    
  else VivCalcVOffset = 0
  
  end
  
  if VivHorOffset > math.pi * -0.666 --only proceed if the viviane sight is in deployed position 
  
    then if VivVertOffset < LasingCondLLim
  
          then if TgtRange > 0 --range has been set by player, if not different calculation methods are used to roughly determine the point the sight is facing
    
                then CalcTgtRange = TgtRange * math.sin(VivCalcVOffset)--oh the hours wasted...lua expects rads for math.sin
                     ReCalcDiagRange = CalcTgtRange / math.sin(VivCalcVOffset)
                     
                     TgtPoint = GazDesignate.CalcTgtPoint(CalcTgtRange, VivHeading, HeloPoint)
                     
                     LasingCond = 1
         
               else TgtPoint = GazDesignate.BangTgtPointDwn(VivHeading, HeloPoint, VivCalcVOffset)
                    
                    LasingCond = 2
              
               end
               
         elseif VivVertOffset >= LasingCondLLim and VivVertOffset <= LasingCondULim
         
          then if TgtRange > 0 
          
                then CalcTgtRange = TgtRange
                     ReCalcDiagRange = TgtRange
                     
                     TgtPoint = GazDesignate.CalcTgtPoint(TgtRange, VivHeading, HeloPoint)
                  
                     LasingCond = 3
               
               else TgtPoint = GazDesignate.BangTgtPointLevel(VivHeading, HeloPoint)
               
                    LasingCond = 4
                     
               end
  
         elseif VivVertOffset > LasingCondULim --Viviane is facing upwards
  
          then if TgtRange > 0 --range has been set by player
          
                then CalcTgtRange = TgtRange * math.cos(VivCalcVOffset)
                     ReCalcDiagRange = CalcTgtRange / math.cos(VivCalcVOffset)
                     
                     TgtPoint = GazDesignate.CalcTgtPoint(CalcTgtRange, VivHeading, HeloPoint)
                     
                     LasingCond = 5
               
               else TgtPoint = GazDesignate.BangTgtPointUp(VivHeading, HeloPoint, VivCalcVOffset)

                    LasingCond = 6
                    
               end
         
         end
         
         if TgtPoint ~= nil 
         
          then if ReCalcDiagRange == nil then ReCalcDiagRange = TgtPoint.DiagRange end
               GazDesignate.Range[LArgs.name] = ReCalcDiagRange
               
               local ScanResults = {}
  
               if GazDesignate.ToleranceGaz > 0 
  
                then local ScanSpace = { id = world.VolumeType.SPHERE,
                                         params = { point = TgtPoint,
                                         radius = GazDesignate.ToleranceGaz }
                                        }  
  
                     local function ScanHandler(FoundUnit)
  
                     ScanResults[#ScanResults + 1] = FoundUnit 
  
                     end
         
                     world.searchObjects(Object.Category.UNIT, ScanSpace, ScanHandler)
         
                     if ScanResults[1] ~= nil 
                     
                      then TgtPoint = ScanResults[1]:getPoint()
                           TgtPoint.y = land.getHeight({x = TgtPoint.x, y = TgtPoint.z}) 
                      
                     end
           
               end
               
               TgtLL = GazDesignate.XYtoLLString(TgtPoint)
               TgtAlt = math.floor(TgtPoint.y * 3.28084)
               TgtMGRS = GazDesignate.XYtoMGRSString(TgtPoint)
               
               if ScanResults[1] ~=nil 
               
                then trigger.action.outTextForGroup( LArgs.id, "Designating target!\n\n" .. TgtLL .. "\n\nMGRS: " .. TgtMGRS .. "\n\nElev.: " .. TgtAlt .. " ft" .. "\n\nDiag. range: " .. math.floor(GazDesignate.Range[LArgs.name]+0.5) .. " m", GazDesignate.MsgDispTime, true )
                
               else trigger.action.outTextForGroup( LArgs.id, "Designating ground!\n\n" .. TgtLL .. "\n\nMGRS: " .. TgtMGRS .. "\n\nElev.: " .. TgtAlt .. " ft" .. "\n\nDiag. range: " .. math.floor(GazDesignate.Range[LArgs.name]+0.5) .. " m", GazDesignate.MsgDispTime, true )
               
               end
               
               if LArgs.type == "Lsr"
  
                then GazDesignate.ActiveLasers.Lsr[LArgs.name] = Spot.createLaser(LArgs.unit, HeloBeamOri, TgtPoint, GazDesignate.Codes[LArgs.name])
                           
  
               elseif LArgs.type == "IR"
  
                then GazDesignate.ActiveLasers.IR[LArgs.name] = Spot.createInfraRed(LArgs.unit, HeloBeamOri, TgtPoint)
         
               elseif LArgs.type == "Both"
  
                then GazDesignate.ActiveLasers.Lsr[LArgs.name] = Spot.createLaser(LArgs.unit, HeloBeamOri, TgtPoint, GazDesignate.Codes[LArgs.name])
                     GazDesignate.ActiveLasers.IR[LArgs.name] = Spot.createInfraRed(LArgs.unit, HeloBeamOri, TgtPoint)
         
               end
  
               missionCommands.removeItemForGroup( LArgs.id, GazDesignate.SubMen1[LArgs.name].FireLsr )
               missionCommands.removeItemForGroup( LArgs.id, GazDesignate.SubMen1[LArgs.name].FireIR )
               missionCommands.removeItemForGroup( LArgs.id, GazDesignate.SubMen1[LArgs.name].FireBoth )
  
               GazDesignate.SubMen1[LArgs.name].FireLsr = nil --i don't even know if this is really necessary...
               GazDesignate.SubMen1[LArgs.name].FireIR = nil
               GazDesignate.SubMen1[LArgs.name].FireBoth = nil
         
               GazDesignate.SubMen1[LArgs.name].StopLsr = missionCommands.addCommandForGroup(LArgs.id, "Stop designation", GazDesignate.MainMen[LArgs.name], GazDesignate.StopLaserGaz, {name = LArgs.name, unit = LArgs.unit, id = LArgs.id})
  
               timer.scheduleFunction(GazDesignate.LsrUpdaterGaz, {name = LArgs.name, 
                                                                    unit = LArgs.unit, 
                                                                    id = LArgs.id, 
                                                                    type = LArgs.type, 
                                                                    shead = VivHeading, 
                                                                    svang = VivCalcVOffset, 
                                                                    agl = HeloAGL,
                                                                    range = GazDesignate.Range[LArgs.name], 
                                                                    code = GazDesignate.Codes[LArgs.name]}, timer.getTime() + GazDesignate.UpdateInt)
  
         else trigger.action.outTextForGroup( LArgs.id, "Max. designation range of 20 km exceeded, or sight is facing into sky!", 10, true )    
         
         end
         
  else trigger.action.outTextForGroup( LArgs.id, "Viviane sight not deployed!", 10, true )
  
  end
  
end

function GazDesignate.DeathDespawnChecker(DDArgs) --Cant hook into event dead because it sometimes does not trigger for the gazelle, hence this function to catch players dying or despawning

 if Unit.getByName(DDArgs.name) == nil
 
   then if GazDesignate.MainMen[DDArgs.name] ~= nil
   
          then missionCommands.removeItemForGroup(DDArgs.id, GazDesignate.MainMen[DDArgs.name])--reset the radio menu entries
               GazDesignate.MainMen[DDArgs.name] = nil
               
        end
 
 else timer.scheduleFunction(GazDesignate.DeathDespawnChecker, {id = DDArgs.id, name = DDArgs.name},timer.getTime() + 10)
 
 end
  
end

function GazDesignate.SetupMenuGaz(MenArgs)

  if Unit.getByName(MenArgs.name)--to prevent errors if a player has left the slot before the menu has been built
  
    then GazDesignate.Range[MenArgs.name] = 0
         GazDesignate.Codes[MenArgs.name] = GazDesignate.LaserPresets[1]                     
              
         GazDesignate.MainMen[MenArgs.name] = missionCommands.addSubMenuForGroup(MenArgs.id, "Laser designator" , nil)
              
          GazDesignate.SubMen1[MenArgs.name] = { Range = missionCommands.addSubMenuForGroup(MenArgs.id, "Adjust range", GazDesignate.MainMen[MenArgs.name]),
                                                  Code = missionCommands.addSubMenuForGroup(MenArgs.id, "Change lasercode", GazDesignate.MainMen[MenArgs.name]),
                                                                   
                                                  ShowRange = missionCommands.addCommandForGroup(MenArgs.id, "Show range", GazDesignate.MainMen[MenArgs.name], GazDesignate.ShowRange, {name = MenArgs.name, id = MenArgs.id}),
                                                  ShowCode = missionCommands.addCommandForGroup(MenArgs.id, "Show current lasercode", GazDesignate.MainMen[MenArgs.name], GazDesignate.ShowCode, {name = MenArgs.name, ID = MenArgs.id}),
                              
                                                  FireLsr = missionCommands.addCommandForGroup(MenArgs.id, "Designate (Laser)", GazDesignate.MainMen[MenArgs.name], GazDesignate.CreateLaserGazPrec, {name = MenArgs.name, unit = MenArgs.unit, id = MenArgs.id, type = "Lsr"}),
                                                  FireIR = missionCommands.addCommandForGroup(MenArgs.id, "Designate (IR)", GazDesignate.MainMen[MenArgs.name], GazDesignate.CreateLaserGazPrec, {name = MenArgs.name, unit = MenArgs.unit, id = MenArgs.id, type = "IR"}),
                                                  FireBoth = missionCommands.addCommandForGroup(MenArgs.id, "Designate (Both)", GazDesignate.MainMen[MenArgs.name], GazDesignate.CreateLaserGazPrec, {name = MenArgs.name, unit = MenArgs.unit, id = MenArgs.id, type = "Both"})}             
                              
           GazDesignate.SubMen2[MenArgs.name] = { R1stDgt = missionCommands.addSubMenuForGroup(MenArgs.id, "1st digit", GazDesignate.SubMen1[MenArgs.name].Range),
                                                   R2ndDgt = missionCommands.addSubMenuForGroup(MenArgs.id, "2nd digit", GazDesignate.SubMen1[MenArgs.name].Range),
                                                   R3rdDgt = missionCommands.addSubMenuForGroup(MenArgs.id, "3rd digit", GazDesignate.SubMen1[MenArgs.name].Range),
                                                   R4thDgt = missionCommands.addSubMenuForGroup(MenArgs.id, "4th digit", GazDesignate.SubMen1[MenArgs.name].Range),
                                                   R5thDgt = missionCommands.addSubMenuForGroup(MenArgs.id, "5th digit", GazDesignate.SubMen1[MenArgs.name].Range),
                                                   Relative = missionCommands.addSubMenuForGroup(MenArgs.id, "Relative change", GazDesignate.SubMen1[MenArgs.name].Range),
                                                   Reset = missionCommands.addCommandForGroup(MenArgs.id, "Reset to 0",  GazDesignate.SubMen1[MenArgs.name].Range, GazDesignate.ResRange, {name = MenArgs.name, id = MenArgs.id }),
                                                               
                                                   CdPresets = missionCommands.addSubMenuForGroup(MenArgs.id, "Presets", GazDesignate.SubMen1[MenArgs.name].Code),
                                                   Cd2ndDgt = missionCommands.addSubMenuForGroup(MenArgs.id, "2nd digit", GazDesignate.SubMen1[MenArgs.name].Code),
                                                   Cd3rdDgt = missionCommands.addSubMenuForGroup(MenArgs.id, "3rd digit", GazDesignate.SubMen1[MenArgs.name].Code),
                                                   Cd4thDgt = missionCommands.addSubMenuForGroup(MenArgs.id, "4th digit", GazDesignate.SubMen1[MenArgs.name].Code) }
                                                    
            GazDesignate.SubMen3[MenArgs.name] = { R11 = missionCommands.addCommandForGroup(MenArgs.id, "1",  GazDesignate.SubMen2[MenArgs.name].R1stDgt, GazDesignate.AdjRange, {digit = 1, val = 1, name = MenArgs.name, id = MenArgs.id }),
                                                    R12 = missionCommands.addCommandForGroup(MenArgs.id, "2",  GazDesignate.SubMen2[MenArgs.name].R1stDgt, GazDesignate.AdjRange, {digit = 1, val = 2, name = MenArgs.name, id = MenArgs.id }),
                                                    R13 = missionCommands.addCommandForGroup(MenArgs.id, "3",  GazDesignate.SubMen2[MenArgs.name].R1stDgt, GazDesignate.AdjRange, {digit = 1, val = 3, name = MenArgs.name, id = MenArgs.id }),
                                                    R14 = missionCommands.addCommandForGroup(MenArgs.id, "4",  GazDesignate.SubMen2[MenArgs.name].R1stDgt, GazDesignate.AdjRange, {digit = 1, val = 4, name = MenArgs.name, id = MenArgs.id }),
                                                    R15 = missionCommands.addCommandForGroup(MenArgs.id, "5",  GazDesignate.SubMen2[MenArgs.name].R1stDgt, GazDesignate.AdjRange, {digit = 1, val = 5, name = MenArgs.name, id = MenArgs.id }),
                                                    R16 = missionCommands.addCommandForGroup(MenArgs.id, "6",  GazDesignate.SubMen2[MenArgs.name].R1stDgt, GazDesignate.AdjRange, {digit = 1, val = 6, name = MenArgs.name, id = MenArgs.id }),
                                                    R17 = missionCommands.addCommandForGroup(MenArgs.id, "7",  GazDesignate.SubMen2[MenArgs.name].R1stDgt, GazDesignate.AdjRange, {digit = 1, val = 7, name = MenArgs.name, id = MenArgs.id }),
                                                    R18 = missionCommands.addCommandForGroup(MenArgs.id, "8",  GazDesignate.SubMen2[MenArgs.name].R1stDgt, GazDesignate.AdjRange, {digit = 1, val = 8, name = MenArgs.name, id = MenArgs.id }),
                                                    R19 = missionCommands.addCommandForGroup(MenArgs.id, "9",  GazDesignate.SubMen2[MenArgs.name].R1stDgt, GazDesignate.AdjRange, {digit = 1, val = 9, name = MenArgs.name, id = MenArgs.id }),
                                                    R10 = missionCommands.addCommandForGroup(MenArgs.id, "0",  GazDesignate.SubMen2[MenArgs.name].R1stDgt, GazDesignate.AdjRange, {digit = 1, val = 0, name = MenArgs.name, id = MenArgs.id }),
                                                     
                                                    R21 = missionCommands.addCommandForGroup(MenArgs.id, "1",  GazDesignate.SubMen2[MenArgs.name].R2ndDgt, GazDesignate.AdjRange, {digit = 2, val = 1, name = MenArgs.name, id = MenArgs.id }),
                                                    R22 = missionCommands.addCommandForGroup(MenArgs.id, "2",  GazDesignate.SubMen2[MenArgs.name].R2ndDgt, GazDesignate.AdjRange, {digit = 2, val = 2, name = MenArgs.name, id = MenArgs.id }),
                                                    R23 = missionCommands.addCommandForGroup(MenArgs.id, "3",  GazDesignate.SubMen2[MenArgs.name].R2ndDgt, GazDesignate.AdjRange, {digit = 2, val = 3, name = MenArgs.name, id = MenArgs.id }),
                                                    R24 = missionCommands.addCommandForGroup(MenArgs.id, "4",  GazDesignate.SubMen2[MenArgs.name].R2ndDgt, GazDesignate.AdjRange, {digit = 2, val = 4, name = MenArgs.name, id = MenArgs.id }),
                                                    R25 = missionCommands.addCommandForGroup(MenArgs.id, "5",  GazDesignate.SubMen2[MenArgs.name].R2ndDgt, GazDesignate.AdjRange, {digit = 2, val = 5, name = MenArgs.name, id = MenArgs.id }),
                                                    R26 = missionCommands.addCommandForGroup(MenArgs.id, "6",  GazDesignate.SubMen2[MenArgs.name].R2ndDgt, GazDesignate.AdjRange, {digit = 2, val = 6, name = MenArgs.name, id = MenArgs.id }),
                                                    R27 = missionCommands.addCommandForGroup(MenArgs.id, "7",  GazDesignate.SubMen2[MenArgs.name].R2ndDgt, GazDesignate.AdjRange, {digit = 2, val = 7, name = MenArgs.name, id = MenArgs.id }),
                                                    R28 = missionCommands.addCommandForGroup(MenArgs.id, "8",  GazDesignate.SubMen2[MenArgs.name].R2ndDgt, GazDesignate.AdjRange, {digit = 2, val = 8, name = MenArgs.name, id = MenArgs.id }),
                                                    R29 = missionCommands.addCommandForGroup(MenArgs.id, "9",  GazDesignate.SubMen2[MenArgs.name].R2ndDgt, GazDesignate.AdjRange, {digit = 2, val = 9, name = MenArgs.name, id = MenArgs.id }),
                                                    R20 = missionCommands.addCommandForGroup(MenArgs.id, "0",  GazDesignate.SubMen2[MenArgs.name].R2ndDgt, GazDesignate.AdjRange, {digit = 2, val = 0, name = MenArgs.name, id = MenArgs.id }),
                                                           
                                                    R31 = missionCommands.addCommandForGroup(MenArgs.id, "1",  GazDesignate.SubMen2[MenArgs.name].R3rdDgt, GazDesignate.AdjRange, {digit = 3, val = 1, name = MenArgs.name, id = MenArgs.id }),
                                                    R32 = missionCommands.addCommandForGroup(MenArgs.id, "2",  GazDesignate.SubMen2[MenArgs.name].R3rdDgt, GazDesignate.AdjRange, {digit = 3, val = 2, name = MenArgs.name, id = MenArgs.id }),
                                                    R33 = missionCommands.addCommandForGroup(MenArgs.id, "3",  GazDesignate.SubMen2[MenArgs.name].R3rdDgt, GazDesignate.AdjRange, {digit = 3, val = 3, name = MenArgs.name, id = MenArgs.id }),
                                                    R34 = missionCommands.addCommandForGroup(MenArgs.id, "4",  GazDesignate.SubMen2[MenArgs.name].R3rdDgt, GazDesignate.AdjRange, {digit = 3, val = 4, name = MenArgs.name, id = MenArgs.id }),
                                                    R35 = missionCommands.addCommandForGroup(MenArgs.id, "5",  GazDesignate.SubMen2[MenArgs.name].R3rdDgt, GazDesignate.AdjRange, {digit = 3, val = 5, name = MenArgs.name, id = MenArgs.id }),
                                                    R36 = missionCommands.addCommandForGroup(MenArgs.id, "6",  GazDesignate.SubMen2[MenArgs.name].R3rdDgt, GazDesignate.AdjRange, {digit = 3, val = 6, name = MenArgs.name, id = MenArgs.id }),
                                                    R37 = missionCommands.addCommandForGroup(MenArgs.id, "7",  GazDesignate.SubMen2[MenArgs.name].R3rdDgt, GazDesignate.AdjRange, {digit = 3, val = 7, name = MenArgs.name, id = MenArgs.id }),
                                                    R38 = missionCommands.addCommandForGroup(MenArgs.id, "8",  GazDesignate.SubMen2[MenArgs.name].R3rdDgt, GazDesignate.AdjRange, {digit = 3, val = 8, name = MenArgs.name, id = MenArgs.id }),
                                                    R39 = missionCommands.addCommandForGroup(MenArgs.id, "9",  GazDesignate.SubMen2[MenArgs.name].R3rdDgt, GazDesignate.AdjRange, {digit = 3, val = 9, name = MenArgs.name, id = MenArgs.id }),
                                                    R30 = missionCommands.addCommandForGroup(MenArgs.id, "0",  GazDesignate.SubMen2[MenArgs.name].R3rdDgt, GazDesignate.AdjRange, {digit = 3, val = 0, name = MenArgs.name, id = MenArgs.id }),
                                                     
                                                    R41 = missionCommands.addCommandForGroup(MenArgs.id, "1",  GazDesignate.SubMen2[MenArgs.name].R4thDgt, GazDesignate.AdjRange, {digit = 4, val = 1, name = MenArgs.name, id = MenArgs.id }),
                                                    R42 = missionCommands.addCommandForGroup(MenArgs.id, "2",  GazDesignate.SubMen2[MenArgs.name].R4thDgt, GazDesignate.AdjRange, {digit = 4, val = 2, name = MenArgs.name, id = MenArgs.id }),
                                                    R43 = missionCommands.addCommandForGroup(MenArgs.id, "3",  GazDesignate.SubMen2[MenArgs.name].R4thDgt, GazDesignate.AdjRange, {digit = 4, val = 3, name = MenArgs.name, id = MenArgs.id }),
                                                    R44 = missionCommands.addCommandForGroup(MenArgs.id, "4",  GazDesignate.SubMen2[MenArgs.name].R4thDgt, GazDesignate.AdjRange, {digit = 4, val = 4, name = MenArgs.name, id = MenArgs.id }),
                                                    R45 = missionCommands.addCommandForGroup(MenArgs.id, "5",  GazDesignate.SubMen2[MenArgs.name].R4thDgt, GazDesignate.AdjRange, {digit = 4, val = 5, name = MenArgs.name, id = MenArgs.id }),
                                                    R46 = missionCommands.addCommandForGroup(MenArgs.id, "6",  GazDesignate.SubMen2[MenArgs.name].R4thDgt, GazDesignate.AdjRange, {digit = 4, val = 6, name = MenArgs.name, id = MenArgs.id }),
                                                    R47 = missionCommands.addCommandForGroup(MenArgs.id, "7",  GazDesignate.SubMen2[MenArgs.name].R4thDgt, GazDesignate.AdjRange, {digit = 4, val = 7, name = MenArgs.name, id = MenArgs.id }),
                                                    R48 = missionCommands.addCommandForGroup(MenArgs.id, "8",  GazDesignate.SubMen2[MenArgs.name].R4thDgt, GazDesignate.AdjRange, {digit = 4, val = 8, name = MenArgs.name, id = MenArgs.id }),
                                                    R49 = missionCommands.addCommandForGroup(MenArgs.id, "9",  GazDesignate.SubMen2[MenArgs.name].R4thDgt, GazDesignate.AdjRange, {digit = 4, val = 9, name = MenArgs.name, id = MenArgs.id }),
                                                    R40 = missionCommands.addCommandForGroup(MenArgs.id, "0",  GazDesignate.SubMen2[MenArgs.name].R4thDgt, GazDesignate.AdjRange, {digit = 4, val = 0, name = MenArgs.name, id = MenArgs.id }),
                                                    
                                                    R51 = missionCommands.addCommandForGroup(MenArgs.id, "1",  GazDesignate.SubMen2[MenArgs.name].R5thDgt, GazDesignate.AdjRange, {digit = 5, val = 1, name = MenArgs.name, id = MenArgs.id }),
                                                    R52 = missionCommands.addCommandForGroup(MenArgs.id, "2",  GazDesignate.SubMen2[MenArgs.name].R5thDgt, GazDesignate.AdjRange, {digit = 5, val = 2, name = MenArgs.name, id = MenArgs.id }),
                                                    R53 = missionCommands.addCommandForGroup(MenArgs.id, "3",  GazDesignate.SubMen2[MenArgs.name].R5thDgt, GazDesignate.AdjRange, {digit = 5, val = 3, name = MenArgs.name, id = MenArgs.id }),
                                                    R54 = missionCommands.addCommandForGroup(MenArgs.id, "4",  GazDesignate.SubMen2[MenArgs.name].R5thDgt, GazDesignate.AdjRange, {digit = 5, val = 4, name = MenArgs.name, id = MenArgs.id }),
                                                    R55 = missionCommands.addCommandForGroup(MenArgs.id, "5",  GazDesignate.SubMen2[MenArgs.name].R5thDgt, GazDesignate.AdjRange, {digit = 5, val = 5, name = MenArgs.name, id = MenArgs.id }),
                                                    R56 = missionCommands.addCommandForGroup(MenArgs.id, "6",  GazDesignate.SubMen2[MenArgs.name].R5thDgt, GazDesignate.AdjRange, {digit = 5, val = 6, name = MenArgs.name, id = MenArgs.id }),
                                                    R57 = missionCommands.addCommandForGroup(MenArgs.id, "7",  GazDesignate.SubMen2[MenArgs.name].R5thDgt, GazDesignate.AdjRange, {digit = 5, val = 7, name = MenArgs.name, id = MenArgs.id }),
                                                    R58 = missionCommands.addCommandForGroup(MenArgs.id, "8",  GazDesignate.SubMen2[MenArgs.name].R5thDgt, GazDesignate.AdjRange, {digit = 5, val = 8, name = MenArgs.name, id = MenArgs.id }),
                                                    R59 = missionCommands.addCommandForGroup(MenArgs.id, "9",  GazDesignate.SubMen2[MenArgs.name].R5thDgt, GazDesignate.AdjRange, {digit = 5, val = 9, name = MenArgs.name, id = MenArgs.id }),
                                                    R50 = missionCommands.addCommandForGroup(MenArgs.id, "0",  GazDesignate.SubMen2[MenArgs.name].R5thDgt, GazDesignate.AdjRange, {digit = 5, val = 0, name = MenArgs.name, id = MenArgs.id }),
                                                                      
                                                    RelAddTsd = missionCommands.addCommandForGroup(MenArgs.id, "+1000",  GazDesignate.SubMen2[MenArgs.name].Relative, GazDesignate.AdjRangeRel, {val = 1000, name = MenArgs.name, group = MenArgs.id }),
                                                    RelSubTsd = missionCommands.addCommandForGroup(MenArgs.id, "-1000",  GazDesignate.SubMen2[MenArgs.name].Relative, GazDesignate.AdjRangeRel, {val = -1000, name = MenArgs.name, group = MenArgs.id }),
                                                    RelAddHun = missionCommands.addCommandForGroup(MenArgs.id, "+100",  GazDesignate.SubMen2[MenArgs.name].Relative, GazDesignate.AdjRangeRel, {val = 100, name = MenArgs.name, group = MenArgs.id }),
                                                    RelSubHun = missionCommands.addCommandForGroup(MenArgs.id, "-100",  GazDesignate.SubMen2[MenArgs.name].Relative, GazDesignate.AdjRangeRel, {val = -100, name = MenArgs.name, group = MenArgs.id }),
                                                    RelAddTen = missionCommands.addCommandForGroup(MenArgs.id, "+10",  GazDesignate.SubMen2[MenArgs.name].Relative, GazDesignate.AdjRangeRel, {val = 10, name = MenArgs.name, group = MenArgs.id }),
                                                    RelSubTen = missionCommands.addCommandForGroup(MenArgs.id, "-10",  GazDesignate.SubMen2[MenArgs.name].Relative, GazDesignate.AdjRangeRel, {val = -10, name = MenArgs.name, group = MenArgs.id }),
                                                    RelAddOne = missionCommands.addCommandForGroup(MenArgs.id, "+1",  GazDesignate.SubMen2[MenArgs.name].Relative, GazDesignate.AdjRangeRel, {val = 1, name = MenArgs.name, group = MenArgs.id }),
                                                    RelSubOne = missionCommands.addCommandForGroup(MenArgs.id, "-1",  GazDesignate.SubMen2[MenArgs.name].Relative, GazDesignate.AdjRangeRel, {val = -1, name = MenArgs.name, group = MenArgs.id }),
                                                                      
                                                    C2Space1 = missionCommands.addCommandForGroup(MenArgs.id, "XXXXXXXXXXXXXXXXXXXXXXXX",  GazDesignate.SubMen2[MenArgs.name].Cd2ndDgt, GazDesignate.WrongButton, {id = MenArgs.id}),
                                                    C2Space2 = missionCommands.addCommandForGroup(MenArgs.id, "XXXXXXXXXXXXXXXXXXXXXXXX",  GazDesignate.SubMen2[MenArgs.name].Cd2ndDgt, GazDesignate.WrongButton, {id = MenArgs.id}),
                                                    C2Space3 = missionCommands.addCommandForGroup(MenArgs.id, "XXXXXXXXXXXXXXXXXXXXXXXX",  GazDesignate.SubMen2[MenArgs.name].Cd2ndDgt, GazDesignate.WrongButton, {id = MenArgs.id}),
                                                    C2Space4 = missionCommands.addCommandForGroup(MenArgs.id, "XXXXXXXXXXXXXXXXXXXXXXXX",  GazDesignate.SubMen2[MenArgs.name].Cd2ndDgt, GazDesignate.WrongButton, {id = MenArgs.id}),
                                                                      
                                                    C25 = missionCommands.addCommandForGroup(MenArgs.id, "5",  GazDesignate.SubMen2[MenArgs.name].Cd2ndDgt, GazDesignate.AdjCode, {digit = 2, val = 5, name = MenArgs.name, id = MenArgs.id }),
                                                    C26 = missionCommands.addCommandForGroup(MenArgs.id, "6",  GazDesignate.SubMen2[MenArgs.name].Cd2ndDgt, GazDesignate.AdjCode, {digit = 2, val = 6, name = MenArgs.name, id = MenArgs.id }),
                                                    C27 = missionCommands.addCommandForGroup(MenArgs.id, "7",  GazDesignate.SubMen2[MenArgs.name].Cd2ndDgt, GazDesignate.AdjCode, {digit = 2, val = 7, name = MenArgs.name, id = MenArgs.id }),
                                                      
                                                    C31 = missionCommands.addCommandForGroup(MenArgs.id, "1",  GazDesignate.SubMen2[MenArgs.name].Cd3rdDgt, GazDesignate.AdjCode, {digit = 3, val = 1, name = MenArgs.name, id = MenArgs.id }),
                                                    C32 = missionCommands.addCommandForGroup(MenArgs.id, "2",  GazDesignate.SubMen2[MenArgs.name].Cd3rdDgt, GazDesignate.AdjCode, {digit = 3, val = 2, name = MenArgs.name, id = MenArgs.id }),
                                                    C33 = missionCommands.addCommandForGroup(MenArgs.id, "3",  GazDesignate.SubMen2[MenArgs.name].Cd3rdDgt, GazDesignate.AdjCode, {digit = 3, val = 3, name = MenArgs.name, id = MenArgs.id }),
                                                    C34 = missionCommands.addCommandForGroup(MenArgs.id, "4",  GazDesignate.SubMen2[MenArgs.name].Cd3rdDgt, GazDesignate.AdjCode, {digit = 3, val = 4, name = MenArgs.name, id = MenArgs.id }),
                                                    C35 = missionCommands.addCommandForGroup(MenArgs.id, "5",  GazDesignate.SubMen2[MenArgs.name].Cd3rdDgt, GazDesignate.AdjCode, {digit = 3, val = 5, name = MenArgs.name, id = MenArgs.id }),
                                                    C36 = missionCommands.addCommandForGroup(MenArgs.id, "6",  GazDesignate.SubMen2[MenArgs.name].Cd3rdDgt, GazDesignate.AdjCode, {digit = 3, val = 6, name = MenArgs.name, id = MenArgs.id }),
                                                    C37 = missionCommands.addCommandForGroup(MenArgs.id, "7",  GazDesignate.SubMen2[MenArgs.name].Cd3rdDgt, GazDesignate.AdjCode, {digit = 3, val = 7, name = MenArgs.name, id = MenArgs.id }),
                                                    C38 = missionCommands.addCommandForGroup(MenArgs.id, "8",  GazDesignate.SubMen2[MenArgs.name].Cd3rdDgt, GazDesignate.AdjCode, {digit = 3, val = 8, name = MenArgs.name, id = MenArgs.id }),
                                                     
                                                    C41 = missionCommands.addCommandForGroup(MenArgs.id, "1",  GazDesignate.SubMen2[MenArgs.name].Cd4thDgt, GazDesignate.AdjCode, {digit = 4, val = 1, name = MenArgs.name, id = MenArgs.id }),
                                                    C42 = missionCommands.addCommandForGroup(MenArgs.id, "2",  GazDesignate.SubMen2[MenArgs.name].Cd4thDgt, GazDesignate.AdjCode, {digit = 4, val = 2, name = MenArgs.name, id = MenArgs.id }),
                                                    C43 = missionCommands.addCommandForGroup(MenArgs.id, "3",  GazDesignate.SubMen2[MenArgs.name].Cd4thDgt, GazDesignate.AdjCode, {digit = 4, val = 3, name = MenArgs.name, id = MenArgs.id }),
                                                    C44 = missionCommands.addCommandForGroup(MenArgs.id, "4",  GazDesignate.SubMen2[MenArgs.name].Cd4thDgt, GazDesignate.AdjCode, {digit = 4, val = 4, name = MenArgs.name, id = MenArgs.id }),
                                                    C45 = missionCommands.addCommandForGroup(MenArgs.id, "5",  GazDesignate.SubMen2[MenArgs.name].Cd4thDgt, GazDesignate.AdjCode, {digit = 4, val = 5, name = MenArgs.name, id = MenArgs.id }),
                                                    C46 = missionCommands.addCommandForGroup(MenArgs.id, "6",  GazDesignate.SubMen2[MenArgs.name].Cd4thDgt, GazDesignate.AdjCode, {digit = 4, val = 6, name = MenArgs.name, id = MenArgs.id }),
                                                    C47 = missionCommands.addCommandForGroup(MenArgs.id, "7",  GazDesignate.SubMen2[MenArgs.name].Cd4thDgt, GazDesignate.AdjCode, {digit = 4, val = 7, name = MenArgs.name, id = MenArgs.id }),
                                                    C48 = missionCommands.addCommandForGroup(MenArgs.id, "8",  GazDesignate.SubMen2[MenArgs.name].Cd4thDgt, GazDesignate.AdjCode, {digit = 4, val = 8, name = MenArgs.name, id = MenArgs.id })}                                                                  
                                 
                                                    for i, Preset in pairs (GazDesignate.LaserPresets)
                                 
                                                      do GazDesignate.SubMen3[MenArgs.name][Preset] = missionCommands.addCommandForGroup(MenArgs.id, tostring(Preset), GazDesignate.SubMen2[MenArgs.name].CdPresets, GazDesignate.AdjCode, {preset = Preset, name = MenArgs.name, id = MenArgs.id})
                                 
                                                    end
                                                    
         trigger.action.outTextForGroup(MenArgs.id, "GazDesignate script is loaded and ready for use!", 30)                                                  
  
  end                                                  

end

function GazDesignate.SetupMenuTimer()

  for i, PilotName in pairs(GazDesignate.EnabledUnits)

    do if Unit.getByName(PilotName)
  
          then if GazDesignate.MainMen[PilotName] == nil
                
                  then local DesDesc = Unit.getByName(PilotName):getDesc()
                     
                       if DesDesc.typeName == "SA342M" --or DesDesc.typeName == "Ka-50" --only the GazelleM and the Ka-50 get menu options
                     
                        then local DesUnit = Unit.getByName(PilotName)
                             local DesID = DesUnit:getGroup():getID()
                             
                             timer.scheduleFunction(GazDesignate.SetupMenuGaz, {unit = DesUnit, id = DesID, name = PilotName}, timer.getTime() + GazDesignate.MenuBuildDel)
                             
                             timer.scheduleFunction(GazDesignate.DeathDespawnChecker, {id = DesID, name = PilotName}, timer.getTime() + 10)
                             --[[if DesDesc.typeName == "SA342M"
                             
                              then timer.scheduleFunction(GazDesignate.SetupMenuGaz, {unit = DesUnit, id = DesID, name = PilotName}, timer.getTime() + 25)
                             
                             else timer.scheduleFunction(GazDesignate.SetupMenuKa, {unit = DesUnit, id = DesID, name = PilotName}, timer.getTime() + 25)
                              
                             end]]
                             
                             trigger.action.outTextForGroup(DesID, "Welcome aboard! GazDesignate script is loading!", GazDesignate.MenuBuildDel - 0.1)
                             
                       end
                       
               end         
       
       end
  
  end
  
  timer.scheduleFunction(GazDesignate.SetupMenuTimer, nil, timer.getTime() + GazDesignate.MenuInt)
               
end

GazDesignate.SetupMenuTimer()

trigger.action.outText("GazDesignate script active!", 10)