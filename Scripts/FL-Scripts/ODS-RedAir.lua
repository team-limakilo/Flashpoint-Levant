local scriptPath = lfs.writedir() .. "Scripts\\AirCommand"
package.path = package.path .. ";" .. scriptPath .. "\\?.lua;"
---------------------------------------------------------------------------------------------------------------------------
local AirCommand = require("AirCommand")
local defs = require("Defs")

-- parameters
local parameters = {
	["minPackageTime"] = 600,
	["maxPackageTime"] = 2400,
	["preparationTime"] = 2400,
	["CAPChance"] = 70,
 	["AMBUSHChance"] = 75
}

-- parameters for aircraft
local aircraftParameters = {
	[Unit.Category.AIRPLANE] = {
		["commitRange"] = 90000,
		["maxAltitude"] = 10000,
		["standardAltitude"] = 7500,
		["returnAltitude"] = 9000,
		["ambushAltitude"] = 180,
		["standardSpeed"] = 250,
		["ambushSpeed"] = 250,
		["MiG-19P"] = {
			["preferredTactic"] = defs.interceptTactic.Stern,
			["radarRange"] = 12000
		},
		["MiG-21Bis"] = {
			["preferredTactic"] = defs.interceptTactic.Stern,
			["radarRange"] = 12000
		},
		["MiG-23MLD"] = {
			["preferredTactic"] = defs.interceptTactic.Beam,
			["radarRange"] = 24000
		},
		["MiG-25PD"] = {
			["preferredTactic"] = defs.interceptTactic.LeadHigh,
			["commitRange"] = 120000,
			["radarRange"] = 30000,
			["standardAltitude"] = 10000,
			["returnAltitude"] = 10000,
			["maxAltitude"] = 16000,
		},
		["MiG-29A"] = {
			["radarRange"] = 40000
		},
	}
}

-- table defining aircraft threat types, any not defined is assumed to be standard
local threatTypes = {
	["MiG-29A"] = defs.threatType.High,
	["MiG-29S"] = defs.threatType.High,
	["Su-27"] = defs.threatType.High,
	["Su-33"] = defs.threatType.High,
	["M-2000C"] = defs.threatType.High,
	["F-14A-135-GR"] = defs.threatType.High,
	["F-14B"] = defs.threatType.High,
	["FA-18C_hornet"] = defs.threatType.High,
	["F-16C_50"] = defs.threatType.High,
	["F-15ESE"] = defs.threatType.High,
	["F-15C"] = defs.threatType.High,
	["JF-17"] = defs.threatType.High,
	["Tornado GR4"] = defs.threatType.High,
	["Tornado IDS"] = defs.threatType.High,
	["OH58D"] = defs.threatType.High,
	["SA342M"] = defs.threatType.High,
	["SA342Mistral"] = defs.threatType.High,
	["Mi-24P"] = defs.threatType.High,
	["Ka-50"] = defs.threatType.High,
	["Ka-50_3"] = defs.threatType.High,
	["AH-64D_BLK_II"] = defs.threatType.High
}

-- support aircraft orbits
local orbits = {
}

local CAPZones = {
	-- Aleppo Helicopter CAP
	[1] = {
		["x"] = 125605,
		["y"] = 123184,
		["radius"] = 100000,
		["reference"] = {
			-- FARP Helena
			["x"] = 183764,
			["y"] = 114062
		},
		["airframes"] = {
			["SA342L"] = true,
		}
	},
	-- Al-Duhur
	[2] = {
		["x"] = 76303,
		["y"] = 111292,
		["radius"] = 100000,
		["reference"] = {
			["x"] = 235725,
			["y"] = 47650
		},
		["airframes"] = {
			["MiG-19P"] = true,
			["MiG-21Bis"] = true,
			["MiG-23MLD"] = true,
			["MiG-25PD"] = true,
			["MiG-29A"] = true
		}
	},
	-- Shayrat
	[3] = {
		["x"] = -61330,
		["y"] = 90350,
		["radius"] = 120000,
		["reference"] = {
			["x"] = -35862,
			["y"] = -269000
		},
		["airframes"] = {
			["MiG-19P"] = true,
			["MiG-21Bis"] = true,
			["MiG-23MLD"] = true,
			["MiG-25PD"] = true,
			["MiG-29A"] = true
		}
	},
}

-- any zones where interception will not be launched even if in range of a squadron
local ADZExclusion = {
	-- Shell tanker area
	[1] = {
		["x"] = 202344,
		["y"] = 117806,
		["radius"] = 40000
	},
	[2] = {
		["x"] = 197791,
		["y"] = 168145,
		["radius"] = 40000
	},
}

-- airbases and squadrons
local OOB = {
	["Aleppo"] = {
		name = "Aleppo", -- DCS name
		takeoffHeading = 4.852, -- in radians
		squadrons = {
			["AleppoMiG21"] = {
				["name"] = "Aleppo MiG-21",
				["country"] = country.SYRIA,
				["type"] = "MiG-21Bis",
				["skill"] = "High",
				["livery"] = "syria (2)",
				["allWeatherAA"] = defs.capability.Limited,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 80000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[3] =
								{
									["CLSID"] = "{PTB_800_MIG21}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			},
			["AleppoSA342"] = {
				["name"] = "Aleppo SA 342",
				["country"] = country.SYRIA,
				["type"] = "SA342L",
				["skill"] = "High",
				["livery"] = "syr airforce st",
				["allWeatherAA"] = defs.capability.None,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 40000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 1,
				["maxFlightSize"] = 2,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
				},
				["targetCategories"] = {
					[Unit.Category.HELICOPTER] = true
				},
				["threatTypes"] = {
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{SA342_Mistral_R1}",
								},
								[2] =
								{
									["CLSID"] = "{SA342_Mistral_L1}",
								},
								[3] =
								{
									["CLSID"] = "{FAS}",
								},
								[4] =
								{
									["CLSID"] = "{IR_Deflector}",
								},
							},
							["fuel"] = 416.33,
							["flare"] = 32,
							["chaff"] = 0,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	},
	["Kuweires"] = {
		name = "Kuweires", -- DCS name
		takeoffHeading = 4.904, -- in radians
		squadrons = {
			["KuweiresMiG21"] = {
				["name"] = "Aleppo MiG-21",
				["country"] = country.SYRIA,
				["type"] = "MiG-21Bis",
				["skill"] = "High",
				["livery"] = "syria (2)",
				["allWeatherAA"] = defs.capability.Limited,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 80000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[3] =
								{
									["CLSID"] = "{PTB_800_MIG21}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	},
	["Taftanaz"] = {
		name = "Taftanaz", -- DCS name
		takeoffHeading = 0.085, -- in radians
		squadrons = {
			["TaftanazSA342"] = {
				["name"] = "Taftanaz SA 342",
				["country"] = country.SYRIA,
				["type"] = "SA342L",
				["skill"] = "High",
				["livery"] = "syr airforce st",
				["allWeatherAA"] = defs.capability.None,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 40000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 1,
				["maxFlightSize"] = 2,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
				},
				["targetCategories"] = {
					[Unit.Category.HELICOPTER] = true
				},
				["threatTypes"] = {
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{SA342_Mistral_R1}",
								},
								[2] =
								{
									["CLSID"] = "{SA342_Mistral_L1}",
								},
								[3] =
								{
									["CLSID"] = "{FAS}",
								},
								[4] =
								{
									["CLSID"] = "{IR_Deflector}",
								},
							},
							["fuel"] = 416.33,
							["flare"] = 32,
							["chaff"] = 0,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	},
	["Jirah"] = {
		name = "Jirah", -- DCS name
		takeoffHeading = 4.887, -- in radians
		squadrons = {
			["JirahMiG19"] = {
				["name"] = "Jirah MiG-19",
				["country"] = country.SYRIA,
				["type"] = "MiG-19P",
				["skill"] = "High",
				["livery"] = "default",
				["allWeatherAA"] = defs.capability.Limited,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 40000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = false
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{K-13A}",
								},
								[6] =
								{
									["CLSID"] = "{K-13A}",
								},
							},
							["fuel"] = 1800,
							["flare"] = 0,
							["ammo_type"] = 1,
							["chaff"] = 0,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			},
			["JirahMiG21"] = {
				["name"] = "Jirah MiG-21",
				["country"] = country.SYRIA,
				["type"] = "MiG-21Bis",
				["skill"] = "High",
				["livery"] = "syria (2)",
				["allWeatherAA"] = defs.capability.Limited,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 80000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[3] =
								{
									["CLSID"] = "{PTB_800_MIG21}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	},
	["Duhur"] = {
		name = "Abu al-Duhur", -- DCS name
		takeoffHeading = 6.262, -- in radians
		squadrons = {
			["DuhurMiG23"] = {
				["name"] = "Al-Duhur MiG-23",
				["country"] = country.SYRIA,
				["type"] = "MiG-23MLD",
				["skill"] = "High",
				["livery"] = "default",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 100000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[2] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
								[3] =
								{
									["CLSID"] = "{B0DBC591-0F52-4F7D-AD7B-51E67725FB81}",
								},
								[4] =
								{
									["CLSID"] = "{A5BAEAB7-6FAF-4236-AF72-0FD900F493F9}",
								},
								[5] =
								{
									["CLSID"] = "{275A2855-4A79-4B2D-B082-91EA2ADF4691}",
								},
								[6] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
							},
							["fuel"] = 3800,
							["flare"] = 60,
							["chaff"] = 60,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[2] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
								[3] =
								{
									["CLSID"] = "{B0DBC591-0F52-4F7D-AD7B-51E67725FB81}",
								},
								[5] =
								{
									["CLSID"] = "{275A2855-4A79-4B2D-B082-91EA2ADF4691}",
								},
								[6] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
							},
							["fuel"] = 3800,
							["flare"] = 60,
							["chaff"] = 60,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	},
	["Tabqa"] = {
		name = "Tabqa", -- DCS name
		takeoffHeading = 4.765, -- in radians
		squadrons = {
			["TabqaMiG25"] = {
				["name"] = "Tabqa MiG-25",
				["country"] = country.SYRIA,
				["type"] = "MiG-25PD",
				["skill"] = "Excellent",
				["livery"] = "default",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 160000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 1,
				["maxFlightSize"] = 2,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{5F26DBC2-FB43-4153-92DE-6BBCE26CB0FF}",
								},
								[2] =
								{
									["CLSID"] = "{4EDBA993-2E34-444C-95FB-549300BF7CAF}",
								},
								[3] =
								{
									["CLSID"] = "{4EDBA993-2E34-444C-95FB-549300BF7CAF}",
								},
								[4] =
								{
									["CLSID"] = "{5F26DBC2-FB43-4153-92DE-6BBCE26CB0FF}",
								},
							},
							["fuel"] = "15245",
							["flare"] = 64,
							["chaff"] = 64,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			},
			["TabqaMiG23"] = {
				["name"] = "Tabqa MiG-23",
				["country"] = country.SYRIA,
				["type"] = "MiG-23MLD",
				["skill"] = "High",
				["livery"] = "default",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 100000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[2] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
								[3] =
								{
									["CLSID"] = "{B0DBC591-0F52-4F7D-AD7B-51E67725FB81}",
								},
								[4] =
								{
									["CLSID"] = "{A5BAEAB7-6FAF-4236-AF72-0FD900F493F9}",
								},
								[5] =
								{
									["CLSID"] = "{275A2855-4A79-4B2D-B082-91EA2ADF4691}",
								},
								[6] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
							},
							["fuel"] = 3800,
							["flare"] = 60,
							["chaff"] = 60,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[2] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
								[3] =
								{
									["CLSID"] = "{B0DBC591-0F52-4F7D-AD7B-51E67725FB81}",
								},
								[5] =
								{
									["CLSID"] = "{275A2855-4A79-4B2D-B082-91EA2ADF4691}",
								},
								[6] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
							},
							["fuel"] = 3800,
							["flare"] = 60,
							["chaff"] = 60,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	},
	["Bassel"] = {
		name = "Bassel Al-Assad", -- DCS name
		takeoffHeading = 6.262, -- in radians
		squadrons = {
			["BasselMiG21"] = {
				["name"] = "Bassel MiG-21",
				["country"] = country.SYRIA,
				["type"] = "MiG-21Bis",
				["skill"] = "High",
				["livery"] = "syria (2)",
				["allWeatherAA"] = defs.capability.Limited,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 80000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[3] =
								{
									["CLSID"] = "{PTB_800_MIG21}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			},
			["BasselMiG23"] = {
				["name"] = "Bassel MiG-23",
				["country"] = country.SYRIA,
				["type"] = "MiG-23MLD",
				["skill"] = "High",
				["livery"] = "default",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 80000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[2] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
								[3] =
								{
									["CLSID"] = "{B0DBC591-0F52-4F7D-AD7B-51E67725FB81}",
								},
								[4] =
								{
									["CLSID"] = "{A5BAEAB7-6FAF-4236-AF72-0FD900F493F9}",
								},
								[5] =
								{
									["CLSID"] = "{275A2855-4A79-4B2D-B082-91EA2ADF4691}",
								},
								[6] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
							},
							["fuel"] = 3800,
							["flare"] = 60,
							["chaff"] = 60,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[2] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
								[3] =
								{
									["CLSID"] = "{B0DBC591-0F52-4F7D-AD7B-51E67725FB81}",
								},
								[5] =
								{
									["CLSID"] = "{275A2855-4A79-4B2D-B082-91EA2ADF4691}",
								},
								[6] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
							},
							["fuel"] = 3800,
							["flare"] = 60,
							["chaff"] = 60,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	},
	["Hama"] = {
		name = "Hama", -- DCS name
		takeoffHeading = 4.887, -- in radians
		squadrons = {
			["HamaMiG29"] = {
				["name"] = "Hama MiG-29",
				["country"] = country.SYRIA,
				["type"] = "MiG-29A",
				["skill"] = "High",
				["livery"] = "SyAAF",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 120000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{682A481F-0CB5-4693-A382-D00DD4A156D7}",
								},
								[2] =
								{
									["CLSID"] = "{682A481F-0CB5-4693-A382-D00DD4A156D7}",
								},
								[3] =
								{
									["CLSID"] = "{9B25D316-0434-4954-868F-D51DB1A38DF0}",
								},
								[5] =
								{
									["CLSID"] = "{9B25D316-0434-4954-868F-D51DB1A38DF0}",
								},
								[6] =
								{
									["CLSID"] = "{682A481F-0CB5-4693-A382-D00DD4A156D7}",
								},
								[7] =
								{
									["CLSID"] = "{682A481F-0CB5-4693-A382-D00DD4A156D7}",
								},
							},
							["fuel"] = "3376",
							["flare"] = 30,
							["chaff"] = 30,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			},
			["HamaMiG21"] = {
				["name"] = "Hama MiG-21",
				["country"] = country.SYRIA,
				["type"] = "MiG-21Bis",
				["skill"] = "High",
				["livery"] = "syria (2)",
				["allWeatherAA"] = defs.capability.Limited,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 80000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[3] =
								{
									["CLSID"] = "{PTB_800_MIG21}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			},
		}
	},
	["Shayrat"] = {
		name = "Shayrat", -- DCS name
		takeoffHeading = 5.096, -- in radians
		squadrons = {
			["ShayratMiG19"] = {
				["name"] = "Shayrat MiG-19",
				["country"] = country.SYRIA,
				["type"] = "MiG-19P",
				["skill"] = "High",
				["livery"] = "default",
				["allWeatherAA"] = defs.capability.Limited,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 40000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = false
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{K-13A}",
								},
								[6] =
								{
									["CLSID"] = "{K-13A}",
								},
							},
							["fuel"] = 1800,
							["flare"] = 0,
							["ammo_type"] = 1,
							["chaff"] = 0,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	},
	["Tiyas"] = {
		name = "Tiyas", -- DCS name
		takeoffHeading = 4.712, -- in radians
		squadrons = {
			["TiyasMiG25"] = {
				["name"] = "Tiyas MiG-25",
				["country"] = country.SYRIA,
				["type"] = "MiG-25PD",
				["skill"] = "Excellent",
				["livery"] = "default",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 200000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 1,
				["maxFlightSize"] = 2,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{5F26DBC2-FB43-4153-92DE-6BBCE26CB0FF}",
								},
								[2] =
								{
									["CLSID"] = "{4EDBA993-2E34-444C-95FB-549300BF7CAF}",
								},
								[3] =
								{
									["CLSID"] = "{4EDBA993-2E34-444C-95FB-549300BF7CAF}",
								},
								[4] =
								{
									["CLSID"] = "{5F26DBC2-FB43-4153-92DE-6BBCE26CB0FF}",
								},
							},
							["fuel"] = "15245",
							["flare"] = 64,
							["chaff"] = 64,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	},
	["Palmyra"] = {
		name = "Palmyra", -- DCS name
		takeoffHeading = 4.625, -- in radians
		squadrons = {
			["PalmyraMiG21"] = {
				["name"] = "Palmyra MiG-21",
				["country"] = country.SYRIA,
				["type"] = "MiG-21Bis",
				["skill"] = "High",
				["livery"] = "syria (2)",
				["allWeatherAA"] = defs.capability.Limited,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 80000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[3] =
								{
									["CLSID"] = "{PTB_800_MIG21}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{R-60M}",
								},
								[2] =
								{
									["CLSID"] = "{R-3R}",
								},
								[4] =
								{
									["CLSID"] = "{R-3R}",
								},
								[5] =
								{
									["CLSID"] = "{R-60M}",
								},
								[6] =
								{
									["CLSID"] = "{ASO-2}",
								},
							},
							["fuel"] = 2280,
							["flare"] = 40,
							["ammo_type"] = 1,
							["chaff"] = 18,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	},
	["Dumayr"] = {
		name = "Al-Dumayr", -- DCS name
		takeoffHeading = 6.262, -- in radians
		squadrons = {
			["DumayrMiG23"] = {
				["name"] = "Al-Dumayr MiG-23",
				["country"] = country.SYRIA,
				["type"] = "MiG-23MLD",
				["skill"] = "High",
				["livery"] = "default",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 100000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.AMBUSHCAP] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[2] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
								[3] =
								{
									["CLSID"] = "{B0DBC591-0F52-4F7D-AD7B-51E67725FB81}",
								},
								[4] =
								{
									["CLSID"] = "{A5BAEAB7-6FAF-4236-AF72-0FD900F493F9}",
								},
								[5] =
								{
									["CLSID"] = "{275A2855-4A79-4B2D-B082-91EA2ADF4691}",
								},
								[6] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
							},
							["fuel"] = 3800,
							["flare"] = 60,
							["chaff"] = 60,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[2] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
								[3] =
								{
									["CLSID"] = "{B0DBC591-0F52-4F7D-AD7B-51E67725FB81}",
								},
								[5] =
								{
									["CLSID"] = "{275A2855-4A79-4B2D-B082-91EA2ADF4691}",
								},
								[6] =
								{
									["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}",
								},
							},
							["fuel"] = 3800,
							["flare"] = 60,
							["chaff"] = 60,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	},
	["Sayqal"] = {
		name = "Sayqal", -- DCS name
		takeoffHeading = 4.712, -- in radians
		squadrons = {
			["SayqalMiG29"] = {
				["name"] = "Sayqal MiG-29",
				["country"] = country.SYRIA,
				["type"] = "MiG-29A",
				["skill"] = "Excellent",
				["livery"] = "SyAAF",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 140000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.Escort] = true,
				},
				["targetCategories"] = {
					[Unit.Category.AIRPLANE] = true
				},
				["threatTypes"] = {
					[defs.threatType.Standard] = true,
					[defs.threatType.High] = true
				},
				["loadouts"] = {
					[defs.roleCategory.AA] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{682A481F-0CB5-4693-A382-D00DD4A156D7}",
								},
								[2] =
								{
									["CLSID"] = "{FBC29BFE-3D24-4C64-B81D-941239D12249}",
								},
								[3] =
								{
									["CLSID"] = "{9B25D316-0434-4954-868F-D51DB1A38DF0}",
								},
								[5] =
								{
									["CLSID"] = "{9B25D316-0434-4954-868F-D51DB1A38DF0}",
								},
								[6] =
								{
									["CLSID"] = "{FBC29BFE-3D24-4C64-B81D-941239D12249}",
								},
								[7] =
								{
									["CLSID"] = "{682A481F-0CB5-4693-A382-D00DD4A156D7}",
								},
							},
							["fuel"] = "3376",
							["flare"] = 30,
							["chaff"] = 30,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Crimson"] = 0,
					["Amber"] = 0,
					["Indigo"] = 0,
					["Emerald"] = 0,
					["Azure"] = 0
				}
			}
		}
	}
}

local ODSRed = AirCommand:new(coalition.side.RED, "SAAF")
ODSRed:setParameters(parameters)
ODSRed:setAircraftParameters(aircraftParameters)
ODSRed:setThreatTypes(threatTypes)
ODSRed:activate(OOB, orbits, CAPZones, ADZExclusion, false)
ODSRed:enableDebug()