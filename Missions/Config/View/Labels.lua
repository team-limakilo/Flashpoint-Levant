-- Label parameters
-- Copyright (C) 2018, Eagle Dynamics.



-- labels =  0  -- NONE
-- labels =  1  -- FULL
-- labels =  2  -- ABBREVIATED
-- labels =  3  -- DOT ONLY

-- Off: No labels are used
-- Full: As we have now
-- Abbreviated: Only red or blue dot and unit type name based on side
-- Dot Only: Only red or blue dot based on unit side



local IS_DOT 		 = labels and labels ==  3
local IS_ABBREVIATED = labels and labels ==  2

AirOn			 		= true
GroundOn 		 		= false
NavyOn		 	 		= true
WeaponOn 		 		= false
labels_format_version 	= 1 -- labels format vesrion
---------------------------------
-- Label text format symbols
-- %N - name of object
-- %D - distance to object
-- %P - pilot name
-- %n - new line 
-- %% - symbol '%'
-- %x, where x is not NDPn% - symbol 'x'
-- %C - extended info for vehicle's and ship's weapon systems
------------------------------------------
-- Example
-- labelFormat[5000] = {"Name: %N%nDistance: %D%n Pilot: %P","LeftBottom",0,0}
-- up to 5km label is:
--       Name: Su-33
--       Distance: 30km
--       Pilot: Pilot1


-- alignment options 
--"RightBottom"
--"LeftTop"
--"RightTop"
--"LeftCenter"
--"RightCenter"
--"CenterBottom"
--"CenterTop"
--"CenterCenter"
--"LeftBottom"


-- labels font properties {font_file_name, font_size_in_pixels, text_shadow_offset_x, text_shadow_offset_y, text_blur_type}
-- text_blur_type = 0 - none
-- text_blur_type = 1 - 3x3 pixels
-- text_blur_type = 2 - 5x5 pixels
font_properties =  {"DejaVuLGCSans.ttf", 13, 0, 0, 0}

local aircraft_symbol_near  =  "˄" --U+02C4
local aircraft_symbol_far   =  "˄" --U+02C4

local ground_symbol_near    = "ˉ"  --U+02C9
local ground_symbol_far     = "ˉ"  --U+02C9

local navy_symbol_near      = "˜"  --U+02DC
local navy_symbol_far       = "˜"  --U+02DC

local weapon_symbol_near    = "ˈ"  --U+02C8
local weapon_symbol_far     = "ˈ"  --U+02C8

local function dot_symbol(blending,opacity)
    return {"˙","CenterBottom", blending or 1.0 , opacity  or 0.1}
end

local NAME 				   = "%N"
local NAME_PLAYER		   = "%N%n %P"
local NAME_DISTANCE_PLAYER = "%N%n %D%n %P"
local NAME_DISTANCE        = "%N%n %D"
local DISTANCE             =   "%n %D"

-- Text shadow color in {red, green, blue, alpha} format, volume from 0 up to 255
-- alpha will by multiplied by opacity value for corresponding distance
local text_shadow_color = {128, 128, 128, 255}
local text_blur_color 	= {0, 0, 255, 255}

local EMPTY = {"", "LeftBottom", 1, 1, 0, 0}


AirFormat = {
--[distance]		= {format, alignment, color_blending_k, opacity, shift_in_pixels_x, shift_in_pixels_y}
[10]	= EMPTY,
[1000]	= {aircraft_symbol_near			, "LeftBottom"	,0.75	, 0.7	, -3	, 0},
[2500]	= {aircraft_symbol_near			, "LeftBottom"	,0.50	, 0.7	, -3	, 0},
[5000]	= {aircraft_symbol_near			, "LeftBottom"	,0.25	, 0.7	, -3	, 0},
[10000]	= {aircraft_symbol_near			, "LeftBottom"	,0.00	, 0.5	, -3	, 0},
[12000]	= {aircraft_symbol_far			, "LeftBottom"	,0.00	, 0.25	, -3	, 0},
[15000]	= dot_symbol(0,0.1),
}

GroundFormat = {
--[distance]		= {format , alignment, color_blending_k, opacity, shift_in_pixels_x, shift_in_pixels_y}
[10]	= EMPTY,
[1000]	= {ground_symbol_near			,"LeftBottom"	,0.75	, 0.7	, -3	, 0},
[2500]	= {ground_symbol_near			,"LeftBottom"	,0.50	, 0.7	, -3	, 0},
[5000]	= {ground_symbol_near			,"LeftBottom"	,0.25	, 0.5	, -3	, 0},
[8000]	= {ground_symbol_far			,"LeftBottom"	,0.00	, 0.25	, -3	, 0},
[10000]	=  dot_symbol(0.0, 0.1),
}

NavyFormat = {
--[distance]		= {format, alignment, color_blending_k, opacity, shift_in_pixels_x, shift_in_pixels_y}
[10]	= EMPTY,
[5000]	= {navy_symbol_near				,"LeftBottom"	,0.75	, 0.7	, -3	, 0},
[7500]	= {navy_symbol_near				,"LeftBottom"	,0.50	, 0.7	, -3	, 0},
[10000]	= {navy_symbol_near				,"LeftBottom"	,0.25	, 0.7	, -3	, 0},
[10000]	= {navy_symbol_near				,"LeftBottom"	,0.00	, 0.5	, -3	, 0},
[20000]	= {navy_symbol_far 				,"LeftBottom"	,0.00	, 0.25	, -3	, 0},
[40000]	= dot_symbol(0.0,0.1),
}

WeaponFormat = {
--[distance]		= {format ,alignment, color_blending_k, opacity, shift_in_pixels_x, shift_in_pixels_y}
[5]	    = EMPTY,
[1000]	= {weapon_symbol_near			,"LeftBottom"	,0.75	, 0.7	, -3	, 0},
[2500]	= {weapon_symbol_near			,"LeftBottom"	,0.50	, 0.7	, -3	, 0},
[5000]	= {weapon_symbol_near			,"LeftBottom"	,0.25	, 0.7	, -3	, 0},
[10000]	= {weapon_symbol_far			,"LeftBottom"	,0.00	, 0.5	, -3	, 0},
[20000]	= {weapon_symbol_far			,"LeftBottom"	,0.00	, 0.25	, -3	, 0},
}

PointFormat = { 
[1e10]	= {"%N%n%D", "LeftBottom"},
}

-- Colors in {red, green, blue} format, volume from 0 up to 255

ColorAliesSide		= {255, 0, 0}
ColorEnemiesSide	= {0, 0,  255}
-- ColorAliesSide	= {249, 69,38}
-- ColorEnemiesSide	= {0, 82,  199}
ColorUnknown		= {50, 50, 50} -- will be blend at distance with coalition color



ShadowColorNeutralSide 	= {0,0,0,0}
ShadowColorAliesSide	= {0,0,0,0}
ShadowColorEnemiesSide 	= {0,0,0,0}
ShadowColorUnknown 		= {0,0,0,0}

BlurColorNeutralSide 	= {255,255,255,255}
BlurColorAliesSide		= {50,0  ,0  ,255}
BlurColorEnemiesSide	= {0  ,0,50  ,255}
BlurColorUnknown		= {50 ,50 ,50 ,255}
