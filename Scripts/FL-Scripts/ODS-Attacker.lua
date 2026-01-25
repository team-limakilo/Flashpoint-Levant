local function EnemyAttackers()
	-- SPAWN:New('CASrandom1'):InitDelayOn():InitLimit(2, 0):SpawnScheduled(3600, 0.3):InitRepeatOnLanding()

	SPAWN:New('AShM'):InitDelayOn():InitLimit(2, 0):SpawnScheduled(3600, 0.3):InitRepeatOnLanding()

	SPAWN:New('CASHatay1'):InitDelayOn():InitLimit(2, 60):SpawnScheduled(2600, 0.3):InitRepeatOnLanding()

	SPAWN:New('CAS1'):InitDelayOn():InitLimit(2, 60):SpawnScheduled(3600, 0.3):InitRepeatOnLanding()

	SPAWN:New('SEAD2'):InitDelayOn():InitLimit(2, 60):SpawnScheduled(4600, 0.3):InitRepeatOnLanding()

	-- SPAWN:New('Intercept1'):InitDelayOn():InitLimit(2, 60):SpawnScheduled(2600, 0.3):InitRepeatOnLanding()

	-- SPAWN:New('HamaCAS'):InitDelayOn():InitLimit(2, 0):SpawnScheduled(2600, 0.3):InitRepeatOnLanding()

	SPAWN:NewWithAlias('TND1', '[UK] No17 Squadron Tornado'):InitLimit(2, 16):SpawnScheduled(1300, 0.3):InitRepeatOnLanding()

	SPAWN:NewWithAlias('TND2', '[Italy] Legion 15 Tornado'):InitLimit(2, 16):SpawnScheduled(1300, 0.3):InitRepeatOnLanding()
end

EnemyAttackers()