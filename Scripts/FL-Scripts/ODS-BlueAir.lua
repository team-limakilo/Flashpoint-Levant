local scriptPath = lfs.writedir() .. "Scripts\\AirCommand"
package.path = package.path .. ";" .. scriptPath .. "\\?.lua;"
---------------------------------------------------------------------------------------------------------------------------
local AirCommand = require("AirCommand")
local defs = require("Defs")

-- parameters
local parameters = {
	["minPackageTime"] = 120,
	["maxPackageTime"] = 240,
	["tankerChance"] = 100,
	["AEWChance"] = 100,
	["CAPChance"] = 5,
 	["AMBUSHChance"] = 0
}

-- parameters for aircraft
local aircraftParameters = {
	[Unit.Category.AIRPLANE] = {
		["commitRange"] = 90000,
		["maxAltitude"] = 9144,
		["standardAltitude"] = 7620,
		["returnAltitude"] = 9144,
		["ambushAltitude"] = 183,
		["standardSpeed"] = 250,
		["ambushSpeed"] = 200,
		["KC-135"] = {
			["standardAltitude"] = 6096.1,
			["standardSpeed"] = 211.1
		},
		["KC135MPRS"] = {
			["standardAltitude"] = 6096.1,
			["standardSpeed"] = 211.1
		},
		["KC130"] = {
			["standardAltitude"] = 4572.3,
			["standardSpeed"] = 155.7
		},
		["S-3B Tanker"] = {
			["standardAltitude"] = 2438.4,
			["standardSpeed"] = 149
		},
		["E-3A"] = {
			["standardAltitude"] = 7620,
			["standardSpeed"] = 205.4
		},
		["E-2C"] = {
			["standardAltitude"] = 5791.2,
			["standardSpeed"] = 133.6
		},
		["F-5E-3"] = {
			["preferredTactic"] = defs.interceptTactic.Stern,
			["radarRange"] = 12000
		},
		["F-4E-45MC"] = {
			["preferredTactic"] = defs.interceptTactic.Beam,
			["radarRange"] = 60000
		},
		["M-2000C"] = {
			["preferredTactic"] = defs.interceptTactic.LeadHigh,
			["radarRange"] = 60000
		},
		["F-14B"] = {
			["preferredTactic"] = defs.interceptTactic.LeadHigh
		},
		["F-15C"] = {
			["preferredTactic"] = defs.interceptTactic.LeadHigh
		}
	}
}

-- table defining aircraft threat types, any not defined is assumed to be standard
local threatTypes = {
	["Su-27"] = defs.threatType.High,
	["Su-33"] = defs.threatType.High,
	["MiG-29A"] = defs.threatType.High,
	["MiG-29S"] = defs.threatType.High,
	["MiG-23MLD"] = defs.threatType.High,
	["MiG-25PD"] = defs.threatType.High,
	["MiG-25RBT"] = defs.threatType.High,
	["MiG-31"] = defs.threatType.High,
	["Su-24M"] = defs.threatType.High,
	["Su-24MR"] = defs.threatType.High
}

-- support aircraft orbits
local orbits = {
	["Shell"] = {
		[1] = {
			["x"] = 196994,
			["y"] = 96131
		},
		[2] = {
			["x"] = 189548,
			["y"] = 186799
		},
		["speed"] = 150.06,
		["alt"] = 3048.3,
		["comm"] = {
			["frequency"] = 237000000,
			["modulation"] = 0
		},
		["beacon"] = {
			["channel"] = 39,
			["band"] = "X",
			["frequency"] = 1000000000,
			["bearing"] = true,
			["callsign"] = "SHL"
		},
		["callsigns"] = {
			["Shell"] = 3
		},
		["airframes"] = {
			["KC-135"] = true
		},
		["HAVCAP"] = true
	},
	["Arco"] = {
		[1] = {
			["x"] = 102823,
			["y"] = -124184
		},
		[2] = {
			["x"] = -15671,
			["y"] = -151516
		},
		["speed"] = 211.72,
		["alt"] = 6096.3,
		["comm"] = {
			["frequency"] = 238000000,
			["modulation"] = 0
		},
		["beacon"] = {
			["channel"] = 38,
			["band"] = "X",
			["frequency"] = 999000000,
			["bearing"] = true,
			["callsign"] = "ARC"
		},
		["callsigns"] = {
			["Arco"] = 2
		},
		["airframes"] = {
			["KC-135"] = true
		},
		["HAVCAP"] = true
	},
	["Texaco"] = {
		[1] = {
			["x"] = 149834,
			["y"] = -111257
		},
		[2] = {
			["x"] = 77074,
			["y"] = -158948
		},
		["speed"] = 201.4,
		["alt"] = 5181.9,
		["comm"] = {
			["frequency"] = 334500000,
			["modulation"] = 0
		},
		["beacon"] = {
			["channel"] = 34,
			["band"] = "X",
			["frequency"] = 995000000,
			["bearing"] = true,
			["callsign"] = "TEX"
		},
		["callsigns"] = {
			["Texaco"] = 1
		},
		["airframes"] = {
			["KC135MPRS"] = true
		},
		["HAVCAP"] = true
	},
	["Petrol"] = {
		[1] = {
			["x"] = -53992,
			["y"] = -176383
		},
		[2] = {
			["x"] = 5934,
			["y"] = -156408
		},
		["speed"] = 155.7,
		["alt"] = 4572.3,
		["comm"] = {
			["frequency"] = 355000000,
			["modulation"] = 0
		},
		["beacon"] = {
			["channel"] = 33,
			["band"] = "X",
			["frequency"] = 994000000,
			["bearing"] = true,
			["callsign"] = "PET"
		},
		["callsigns"] = {
			["Petrol"] = 3
		},
		["airframes"] = {
			["KC130"] = true
		},
		["HAVCAP"] = true
	},
	["Recovery"] = {
		["recoveryGroup"] = "CVN-73 George Washington",
		[1] = {
			["x"] = 94970,
			["y"] = -261229
		},
		[2] = {
			["x"] = 109652,
			["y"] = -162621
		},
		["speed"] = 149,
		["alt"] = 2438.4,
		["comm"] = {
			["frequency"] = 355500000,
			["modulation"] = 0
		},
		["beacon"] = {
			["channel"] = 28,
			["band"] = "X",
			["frequency"] = 989000000,
			["bearing"] = true,
			["callsign"] = "TEX"
		},
		["callsigns"] = {
			["Texaco"] = 1
		},
		["airframes"] = {
			["S-3B Tanker"] = true
		}
	},
	["Darkstar"] = {
		[1] = {
			["x"] = 221861,
			["y"] = -82379
		},
		[2] = {
			["x"] = 146776,
			["y"] = -122835
		},
		["speed"] = 202.5,
		["alt"] = 9144,
		["comm"] = {
			["frequency"] = 233500000,
			["modulation"] = 0
		},
		["callsigns"] = {
			["Darkstar"] = 5
		},
		["airframes"] = {
			["E-3A"] = true
		}
	},
	["Image"] = {
		[1] = {
			["x"] = 29110,
			["y"] = -276774
		},
		[2] = {
			["x"] = -22129,
			["y"] = -304010
		},
		["speed"] = 203.5,
		["alt"] = 10668,
		["comm"] = {
			["frequency"] = 233700000,
			["modulation"] = 0
		},
		["callsigns"] = {
			["Image"] = 2
		},
		["airframes"] = {
			["E-3A"] = true
		}
	},
	["Wizard"] = {
		[1] = {
			["x"] = 131786,
			["y"] = -174433
		},
		[2] = {
			["x"] = 162676,
			["y"] = -132478
		},
		["speed"] = 133.6,
		["alt"] = 5791.2,
		["comm"] = {
			["frequency"] = 133000000,
			["modulation"] = 0
		},
		["callsigns"] = {
			["Wizard"] = 3
		},
		["airframes"] = {
			["E-2C"] = true
		}
	},
}

local CAPZones = {
	[1] = {
		["x"] = 212217,
		["y"] = 76845,
		["radius"] = 120000,
		["reference"] = { -- Aleppo
			["x"] = 125616,
			["y"] = 123191
		}
	},
	[2] = {
		["x"] = 103600,
		["y"] = -90726,
		["radius"] = 120000,
		["reference"] = { -- Hama
			["x"] = 8700,
			["y"] = 74388
		}
	},
	[3] = {
		["x"] = -81500,
		["y"] = -144101,
		["radius"] = 120000,
		["reference"] = { -- Sayqal
			["x"] = -151713,
			["y"] = 117655
		}
	},
}


-- any zones where interception will not be launched even if in range of a squadron
local ADZExclusion = {
}

-- airbases and squadrons
local OOB = {
	["Incirlik"] = {
		name = "Incirlik", -- DCS name
		takeoffHeading = 0.960, -- in radians
		squadrons = {
			["58TFS"] = {
				["name"] = "58th TFS",
				["country"] = country.USA,
				["type"] = "F-15C",
				["skill"] = "High",
				["livery"] = "58th Fighter SQN (EG)",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 100000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.Escort] = true,
					[defs.missionType.HAVCAP] = true
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
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
								[2] =
								{
									["CLSID"] = "{E1F29B21-F291-4589-9FD8-3272EEC69506}",
								},
								[3] =
								{
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
								[4] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[5] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[7] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[8] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[9] =
								{
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
								[10] =
								{
									["CLSID"] = "{E1F29B21-F291-4589-9FD8-3272EEC69506}",
								},
								[11] =
								{
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
							},
							["fuel"] = 6103,
							["flare"] = 60,
							["chaff"] = 120,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
								[3] =
								{
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
								[4] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[5] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[7] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[8] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[9] =
								{
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
								[11] =
								{
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
							},
							["fuel"] = 6103,
							["flare"] = 60,
							["chaff"] = 120,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Enfield"] = 1,
					["Springfield"] = 2,
					["Uzi"] = 3,
					["Colt"] = 4,
				}
			},
			["2eEdC"] = {
				["name"] = "2e EdC",
				["country"] = country.FRANCE,
				["type"] = "M-2000C",
				["skill"] = "High",
				["livery"] = "ada alsace lf-2",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 100000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.Escort] = true,
					[defs.missionType.HAVCAP] = true
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
									["CLSID"] = "{MMagicII}",
								},
								[2] =
								{
									["CLSID"] = "{Matra_S530D}",
								},
								[8] =
								{
									["CLSID"] = "{Matra_S530D}",
								},
								[10] =
								{
									["CLSID"] = "{EclairM_24}",
								},
								[9] =
								{
									["CLSID"] = "{MMagicII}",
								},
								[5] =
								{
									["CLSID"] = "{M2KC_RPL_522}",
								},
							},
							["fuel"] = 3165,
							["flare"] = 64,
							["ammo_type"] = 1,
							["chaff"] = 234,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{MMagicII}",
								},
								[2] =
								{
									["CLSID"] = "{Matra_S530D}",
								},
								[8] =
								{
									["CLSID"] = "{Matra_S530D}",
								},
								[10] =
								{
									["CLSID"] = "{EclairM_24}",
								},
								[9] =
								{
									["CLSID"] = "{MMagicII}",
								},
							},
							["fuel"] = 3165,
							["flare"] = 64,
							["ammo_type"] = 1,
							["chaff"] = 234,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Dodge"] = 5,
					["Ford"] = 6,
					["Chevy"] = 7,
					["Pontiac"] = 8,
				}
			},
			["807ARS"] = {
				["name"] = "807th ARS",
				["country"] = country.USA,
				["type"] = "KC-135",
				["skill"] = "High",
				["livery"] = "USAF KC-135",
				["baseFlightSize"] = 1,
				["missions"] = {
					[defs.missionType.Tanker] = true
				},
				["loadouts"] = {
					[defs.roleCategory.Support] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
							},
							["fuel"] = 90700,
							["flare"] = 0,
							["chaff"] = 0,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Arco"] = 2,
					["Shell"] = 3
				}
			},
			["7ACCS"] = {
				["name"] = "7th ACCS",
				["country"] = country.USA,
				["type"] = "E-3A",
				["skill"] = "High",
				["livery"] = "nato",
				["baseFlightSize"] = 1,
				["missions"] = {
					[defs.missionType.AEW] = true
				},
				["loadouts"] = {
					[defs.roleCategory.Support] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
							},
							["fuel"] = 65000,
							["flare"] = 60,
							["chaff"] = 120,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Darkstar"] = 5,
					["Image"] = 2
				}
			}
		}
	},
	["Adana"] = {
		name = "Adana Sakirpasa", -- DCS name
		takeoffHeading = 0.977, -- in radians
		squadrons = {
			["111F"] = {
				["name"] = "111. Filo",
				["country"] = country.TURKEY,
				["type"] = "F-4E-45MC",
				["skill"] = "High",
				["livery"] = "tuaf-68-0342-h2",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 100000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
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
									["CLSID"] = "{F4_SARGENT_TANK_370_GAL}",
								},
								[2] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[4] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[5] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[6] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[8] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[9] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[10] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[12] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[13] =
								{
									["CLSID"] = "{F4_SARGENT_TANK_370_GAL_R}",
								},
								[14] =
								{
									["CLSID"] = "{HB_ALE_40_30_60}",
								},
							},
							["fuel"] = 5510.5,
							["flare"] = 30,
							["ammo_type"] = 1,
							["chaff"] = 120,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[2] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[4] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[5] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[6] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[8] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[9] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[10] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[12] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[14] =
								{
									["CLSID"] = "{HB_ALE_40_30_60}",
								},
							},
							["fuel"] = 5510.5,
							["flare"] = 30,
							["ammo_type"] = 1,
							["chaff"] = 120,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Enfield"] = 1,
					["Springfield"] = 2,
					["Uzi"] = 3,
					["Colt"] = 4,
				}
			},
		},
		["152F"] = {
			["name"] = "152. Filo",
			["country"] = country.TURKEY,
			["type"] = "F-5E-3",
			["skill"] = "High",
			["livery"] = "3rd main jet base group command, turkey",
			["allWeatherAA"] = defs.capability.Limited,
			["allWeatherAG"] = defs.capability.None,
			["interceptRadius"] = 60000, -- radius of action around the airbase for interceptors from this squadron in meters
			["baseFlightSize"] = 2,
			["maxFlightSize"] = 4,
			["missions"] = {
				[defs.missionType.Intercept] = true,
				[defs.missionType.QRA] = true,
				[defs.missionType.CAP] = true,
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
								["CLSID"] = "{AIM-9P5}",
							},
							[7] =
							{
								["CLSID"] = "{AIM-9P5}",
							},
							[4] =
							{
								["CLSID"] = "{PTB-150GAL}",
							},
						},
						["fuel"] = 2046,
						["flare"] = 15,
						["ammo_type"] = 2,
						["chaff"] = 30,
						["gun"] = 100,
					},
					[defs.missionType.QRA] = {
						["pylons"] =
						{
							[1] =
							{
								["CLSID"] = "{AIM-9P5}",
							},
							[7] =
							{
								["CLSID"] = "{AIM-9P5}",
							},
						},
						["fuel"] = 2046,
						["flare"] = 15,
						["ammo_type"] = 2,
						["chaff"] = 30,
						["gun"] = 100,
					}
				}
			},
			["callsigns"] = {
				["Dodge"] = 5,
				["Ford"] = 6,
				["Chevy"] = 7,
				["Pontiac"] = 8,
			}
		},
	},
	["Akrotiri"] = {
		name = "Akrotiri", -- DCS name
		takeoffHeading = 1.937, -- in radians
		squadrons = {
			["337M"] = {
				["name"] = "337 Mira",
				["country"] = country.GREECE,
				["type"] = "F-4E-45MC",
				["skill"] = "High",
				["livery"] = "haf-01520_ab",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 100000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
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
									["CLSID"] = "{F4_SARGENT_TANK_370_GAL}",
								},
								[2] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[4] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[5] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[6] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[8] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[9] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[10] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[12] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[13] =
								{
									["CLSID"] = "{F4_SARGENT_TANK_370_GAL_R}",
								},
								[14] =
								{
									["CLSID"] = "{HB_ALE_40_30_60}",
								},
							},
							["fuel"] = 5510.5,
							["flare"] = 30,
							["ammo_type"] = 1,
							["chaff"] = 120,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[2] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[4] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[5] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[6] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[8] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[9] =
								{
									["CLSID"] = "{HB_F4E_AIM-7F}",
								},
								[10] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[12] =
								{
									["CLSID"] = "{AIM-9L}",
								},
								[14] =
								{
									["CLSID"] = "{HB_ALE_40_30_60}",
								},
							},
							["fuel"] = 5510.5,
							["flare"] = 30,
							["ammo_type"] = 1,
							["chaff"] = 120,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Enfield"] = 1,
					["Springfield"] = 2,
					["Uzi"] = 3,
					["Colt"] = 4,
				}
			},
			["331M"] = {
				["name"] = "331 Mira",
				["country"] = country.GREECE,
				["type"] = "M-2000C",
				["skill"] = "High",
				["livery"] = "greek air force",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 100000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.Escort] = true,
					[defs.missionType.HAVCAP] = true
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
									["CLSID"] = "{MMagicII}",
								},
								[2] =
								{
									["CLSID"] = "{Matra_S530D}",
								},
								[8] =
								{
									["CLSID"] = "{Matra_S530D}",
								},
								[10] =
								{
									["CLSID"] = "{EclairM_24}",
								},
								[9] =
								{
									["CLSID"] = "{MMagicII}",
								},
								[5] =
								{
									["CLSID"] = "{M2KC_RPL_522}",
								},
							},
							["fuel"] = 3165,
							["flare"] = 64,
							["ammo_type"] = 1,
							["chaff"] = 234,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{MMagicII}",
								},
								[2] =
								{
									["CLSID"] = "{Matra_S530D}",
								},
								[8] =
								{
									["CLSID"] = "{Matra_S530D}",
								},
								[10] =
								{
									["CLSID"] = "{EclairM_24}",
								},
								[9] =
								{
									["CLSID"] = "{MMagicII}",
								},
							},
							["fuel"] = 3165,
							["flare"] = 64,
							["ammo_type"] = 1,
							["chaff"] = 234,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Dodge"] = 5,
					["Ford"] = 6,
					["Chevy"] = 7,
					["Pontiac"] = 8,
				}
			},
			["810ARS"] = {
				["name"] = "810th ARS",
				["country"] = country.USA,
				["type"] = "KC135MPRS",
				["skill"] = "High",
				["livery"] = "22nd arw",
				["baseFlightSize"] = 1,
				["missions"] = {
					[defs.missionType.Tanker] = true
				},
				["loadouts"] = {
					[defs.roleCategory.Support] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
							},
							["fuel"] = 90700,
							["flare"] = 60,
							["chaff"] = 120,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Texaco"] = 1
				}
			},
			["VMGR352"] = {
				["name"] = "VMGR-352",
				["country"] = country.USA,
				["type"] = "KC130",
				["skill"] = "High",
				["livery"] = "default",
				["baseFlightSize"] = 1,
				["missions"] = {
					[defs.missionType.Tanker] = true
				},
				["loadouts"] = {
					[defs.roleCategory.Support] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
							},
							["fuel"] = 30000,
							["flare"] = 60,
							["chaff"] = 120,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Shell"] = 3
				}
			},
		},
	},
	["Truman"] = {
		name = "CVN-75 Harry S. Truman", -- DCS name
		takeoffHeading = 1.379, -- in radians
		squadrons = {
			["VF103"] = {
				["name"] = "VF-103",
				["country"] = country.USA,
				["type"] = "F-14B",
				["skill"] = "High",
				["livery"] = "vf-103 jolly rogers hi viz",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 100000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.Escort] = true,
					[defs.missionType.HAVCAP] = true
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
									["CLSID"] = "{LAU-138 wtip - AIM-9M}",
								},
								[2] =
								{
									["CLSID"] = "{SHOULDER AIM-7M}",
								},
								[3] =
								{
									["CLSID"] = "{F14-300gal}",
								},
								[4] =
								{
									["CLSID"] = "{AIM_54A_Mk60}",
								},
								[5] =
								{
									["CLSID"] = "{BELLY AIM-7M}",
								},
								[7] =
								{
									["CLSID"] = "{AIM_54A_Mk60}",
								},
								[8] =
								{
									["CLSID"] = "{F14-300gal}",
								},
								[9] =
								{
									["CLSID"] = "{SHOULDER AIM-7M}",
								},
								[10] =
								{
									["CLSID"] = "{LAU-138 wtip - AIM-9M}",
								},
							},
							["fuel"] = 7348,
							["flare"] = 60,
							["chaff"] = 140,
							["gun"] = 100,
							["ammo_type"] = 1,
						}
					}
				},
				["callsigns"] = {
					["Squid"] = 10,
					["Devil"] = 18,
					["Snake"] = 20
				}
			},
			["VFA131"] = {
				["name"] = "VFA-131",
				["country"] = country.USA,
				["type"] = "FA-18C_hornet",
				["skill"] = "High",
				["livery"] = "vfa-131",
				["allWeatherAA"] = defs.capability.Full,
				["allWeatherAG"] = defs.capability.None,
				["interceptRadius"] = 100000, -- radius of action around the airbase for interceptors from this squadron in meters
				["baseFlightSize"] = 2,
				["maxFlightSize"] = 4,
				["missions"] = {
					[defs.missionType.Intercept] = true,
					[defs.missionType.QRA] = true,
					[defs.missionType.CAP] = true,
					[defs.missionType.Escort] = true,
					[defs.missionType.HAVCAP] = true
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
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
								[2] =
								{
									["CLSID"] = "{LAU-115 - AIM-7M}",
								},
								[3] =
								{
									["CLSID"] = "{FPU_8A_FUEL_TANK}",
								},
								[4] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[5] =
								{
									["CLSID"] = "{FPU_8A_FUEL_TANK}",
								},
								[6] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[7] =
								{
									["CLSID"] = "{FPU_8A_FUEL_TANK}",
								},
								[8] =
								{
									["CLSID"] = "{LAU-115 - AIM-7M}",
								},
								[9] =
								{
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
							},
							["fuel"] = 4900,
							["flare"] = 60,
							["ammo_type"] = 1,
							["chaff"] = 60,
							["gun"] = 100,
						},
						[defs.missionType.QRA] = {
							["pylons"] =
							{
								[1] =
								{
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
								[4] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[6] =
								{
									["CLSID"] = "{8D399DDA-FF81-4F14-904D-099B34FE7918}",
								},
								[9] =
								{
									["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
								},
							},
							["fuel"] = 4900,
							["flare"] = 60,
							["ammo_type"] = 1,
							["chaff"] = 60,
							["gun"] = 100,
						},
					}
				},
				["callsigns"] = {
					["Squid"] = 10,
					["Devil"] = 18,
					["Snake"] = 20
				}
			},
			["VS22"] = {
				["name"] = "VS-22",
				["country"] = country.USA,
				["type"] = "S-3B Tanker",
				["skill"] = "High",
				["livery"] = "default",
				["baseFlightSize"] = 1,
				["missions"] = {
					[defs.missionType.Tanker] = true
				},
				["loadouts"] = {
					[defs.roleCategory.Support] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
							},
							["fuel"] = 7813,
							["flare"] = 30,
							["chaff"] = 30,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Texaco"] = 1
				}
			},
			["VAW125"] = {
				["name"] = "VAW-125",
				["country"] = country.USA,
				["type"] = "E-2C",
				["skill"] = "High",
				["livery"] = "VAW-125 Tigertails",
				["baseFlightSize"] = 1,
				["missions"] = {
					[defs.missionType.AEW] = true
				},
				["loadouts"] = {
					[defs.roleCategory.Support] = {
						[defs.missionType.General] = {
							["pylons"] =
							{
							},
							["fuel"] = 5624,
							["flare"] = 60,
							["chaff"] = 120,
							["gun"] = 100,
						}
					}
				},
				["callsigns"] = {
					["Wizard"] = 3
				}
			}
		}
	}
}

local ODSBlue = AirCommand:new(coalition.side.BLUE, "NATO")
ODSBlue:setParameters(parameters)
ODSBlue:setAircraftParameters(aircraftParameters)
ODSBlue:setThreatTypes(threatTypes)
ODSBlue:activate(OOB, orbits, CAPZones, ADZExclusion, true)
ODSBlue:enableDebug()