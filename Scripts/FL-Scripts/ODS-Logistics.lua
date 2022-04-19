local function LogisticsAssets()
	SPAWN:NewWithAlias("ARCO", "ARCO")
		:InitLimit(1, 0)
		:SpawnScheduled(10, 0)
		:InitRepeatOnLanding()

	SPAWN:NewWithAlias("Petrol", "PETROL")
		:InitLimit(1, 0)
		:SpawnScheduled(10, 0)
		:InitRepeatOnLanding()

	SPAWN:NewWithAlias("SHELL", "SHELL")
		:InitLimit(1, 0)
		:SpawnScheduled(10, 0)
		:InitRepeatOnLanding()

	SPAWN:NewWithAlias("TEXACO", "TEXACO")
		:InitLimit(1, 0)
		:SpawnScheduled(10, 0)
		:InitRepeatOnLanding()

	SPAWN:NewWithAlias("DARKSTAR", "DARKSTAR")
		:InitLimit(1, 0)
		:SpawnScheduled(10, 0)
		:InitRepeatOnLanding()

	SPAWN:NewWithAlias("WIZARD", "WIZARD")
		:InitLimit(1, 0)
		:SpawnScheduled(10, 0)
		:InitRepeatOnLanding()

	SPAWN:NewWithAlias("IMAGE", "IMAGE")
		:InitLimit(1, 0)
		:SpawnScheduled(10, 0)
		:InitRepeatOnLanding()

	SPAWN:NewWithAlias("Recovery Tanker", "Recovery Tanker")
		:InitLimit(1, 0)
		:SpawnScheduled(10, 0)
		:InitRepeatOnLanding()
end

local function EnemyAttackers()
	SPAWN:New('CASrandom1'):InitDelayOn():InitLimit(2, 0):SpawnScheduled(3600, 0.3):InitRepeatOnLanding()

	SPAWN:New('AShM'):InitDelayOn():InitLimit(2, 0):SpawnScheduled(3600, 0.3):InitRepeatOnLanding()

	SPAWN:New('CASHatay1'):InitDelayOn():InitLimit(2, 60):SpawnScheduled(2600, 0.3):InitRepeatOnLanding()

	SPAWN:New('CAS1'):InitDelayOn():InitLimit(2, 60):SpawnScheduled(3600, 0.3):InitRepeatOnLanding()

	SPAWN:New('SEAD2'):InitDelayOn():InitLimit(2, 60):SpawnScheduled(4600, 0.3):InitRepeatOnLanding()

	-- SPAWN:New('Intercept1'):InitDelayOn():InitLimit(2, 60):SpawnScheduled(2600, 0.3):InitRepeatOnLanding()

	-- SPAWN:New('HamaCAS'):InitDelayOn():InitLimit(2, 0):SpawnScheduled(2600, 0.3):InitRepeatOnLanding()

	SPAWN:NewWithAlias('TND1', '[UK] No17 Squadron Tornado'):InitLimit(2, 16):SpawnScheduled(1300, 0.3):InitRepeatOnLanding()

	SPAWN:NewWithAlias('TND2', '[Italy] Legion 15 Tornado'):InitLimit(2, 16):SpawnScheduled(1300, 0.3):InitRepeatOnLanding()
end

LogisticsAssets()
EnemyAttackers()
