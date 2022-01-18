local function logisticAssets()

	local function ARCO()
	  ARCOSpawner = SPAWN:NewWithAlias("ARCO", "ARCO")
	  :InitLimit(1, 0)
	  :SpawnScheduled(10, 0)
	  :InitRepeatOnLanding()

	  
	end

	local function PETROL()
		PETROLSpawner = SPAWN:NewWithAlias("Petrol", "PETROL")
		:InitLimit(1, 0)
		:SpawnScheduled(10, 0)
		:InitRepeatOnLanding()
  
		
	  end
	 
	local function SHELL()
	  SHELLSpawner = SPAWN:NewWithAlias("SHELL", "SHELL")
	  :InitLimit(1, 0)
	  :SpawnScheduled(10, 0)
	  :InitRepeatOnLanding()

	end
	 
	local function TEXACO()
	  TEXACOSpawner = SPAWN:NewWithAlias("TEXACO", "TEXACO")
	  :InitLimit(1, 0)
	  :SpawnScheduled(10, 0)
	  :InitRepeatOnLanding()

	end

	local function DARKSTAR()
	  DARKSTARSpawner = SPAWN:NewWithAlias("DARKSTAR", "DARKSTAR")
	  :InitLimit(1, 0)
	  :SpawnScheduled(10, 0)
	  :InitRepeatOnLanding()
	  
	end
	
	local function WIZARD()
	  WIZARDSpawner = SPAWN:NewWithAlias("WIZARD", "WIZARD")
	  :InitLimit(1, 0)
	  :SpawnScheduled(10, 0)
	  :InitRepeatOnLanding()
	  
	end

	local function IMAGE()
		IMAGEpawner = SPAWN:NewWithAlias("IMAGE", "IMAGE")
		:InitLimit(1, 0)
		:SpawnScheduled(10, 0)
		:InitRepeatOnLanding()
		
	  end

	local function RECOVERY()
		RECOVERYSpawner = SPAWN:NewWithAlias("Recovery Tanker", "Recovery Tanker")
		:InitLimit(1, 0)
		:SpawnScheduled(10, 0)
		:InitRepeatOnLanding()
		
	  end
	 
	ARCO()
	SHELL()
	TEXACO()
	DARKSTAR()
	WIZARD()
	RECOVERY()
	PETROL()
	IMAGE()

end

logisticAssets()

local function EnemyAttackers()

	local function HeliCAS()
		HeliCAS = SPAWN:New( 'CASrandom1' ):InitDelayOn():InitLimit( 2, 0):SpawnScheduled(3600,0.3 ):InitRepeatOnLanding()
	end
	local function AShM()
		HeliCAS = SPAWN:New( 'AShM' ):InitDelayOn():InitLimit( 2, 0):SpawnScheduled(3600,0.3 ):InitRepeatOnLanding()
	end
	local function MigCAS()
		MigCAS = SPAWN:New( 'CASHatay1' ):InitDelayOn():InitLimit( 2, 60):SpawnScheduled(2600,0.3 ):InitRepeatOnLanding()	
	end
	local function CASn1()
		CAS1 = SPAWN:New( 'CAS1' ):InitDelayOn():InitLimit( 2, 60):SpawnScheduled(3600,0.3 ):InitRepeatOnLanding()
	end
	local function SEAD2()
		SEAD2 = SPAWN:New( 'SEAD2' ):InitDelayOn():InitLimit( 2, 60):SpawnScheduled(4600,0.3 ):InitRepeatOnLanding()
	end
	local function Intercept()
		Intercept = SPAWN:New( 'Intercept1' ):InitDelayOn():InitLimit( 2, 60):SpawnScheduled(2600,0.3 ):InitRepeatOnLanding()
	end
	local function CASHama()
		CASHama = SPAWN:New( 'HamaCAS' ):InitDelayOn():InitLimit( 2, 0):SpawnScheduled(2600,0.3 ):InitRepeatOnLanding()
	end
	local function TND1()
		TND1 = SPAWN:NewWithAlias( 'TND1', '[UK] No17 Squadron Tornado' ):InitLimit( 2, 16):SpawnScheduled(1300,0.3 ):InitRepeatOnLanding()
	end
	local function TND2()
		TND2 = SPAWN:NewWithAlias( 'TND2', '[Italy] Legion 15 Tornado' ):InitLimit( 2, 16):SpawnScheduled(1300,0.3 ):InitRepeatOnLanding()
	end

HeliCAS()
MigCAS()
AShM()
CASn1()
SEAD2()
TND1()
TND2()
Intercept()

end

EnemyAttackers()
