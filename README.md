# Flashpoint Levant

## Quick Start

### Install DCT
* Download DCT [Dev build](https://nightly.link/team-limakilo/dct/workflows/dev-builds/master)
* Uncompress the archive in '_Saved Games\DCS.openbeta\_'.
  The DCT\entry.lua file should be located in '_Saved Games\DCS.openbeta\Mods\Tech\DCT_'  
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/7fbec4ce-4a63-401a-b7e1-1ab2785ee1aa)

You can find more info on DCT LK fork [here](https://team-limakilo.github.io/dct/quick-start)
or on the official DCT [repository](https://github.com/jtoppins/dct)

### Setup FL files
* Clone of download team-limakilo Flashpoint-Levant (main branch)[https://github.com/team-limakilo/Flashpoint-Levant.git]
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/e8c00b2a-fa13-4306-8c7b-13e9bb01c6e0)

* Copy or extract the content in '_C:\Users\%USERPROFILE%\Saved Games\DCS.openbeta_'. The path to ScriptLoader.lua file should be '_C:\Users\%USERPROFILE%\Saved Games\DCS.openbeta\Scripts\FL-Scripts_':
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/e2b5dce6-f136-421c-b637-c30751cb17a3)


### Configure DCT
Edit the DCT configuration file '_C:\Users\%USERPROFILE%\Saved Games\DCS.openbeta\Config\dct.cfg_', especially the values of the variable 'theaterpath'. This one should point to the folder where your theater.goals is located.
By default, this folder should be '_C:\Users\%USERPROFILE%\Saved Games\DCS.openbeta\LevantTheater_'.
An example of configuration is available [here](https://team-limakilo.github.io/dct/quick-start)


### Disable or remove Mission Scrpting Sanitizing functions
Comment the 'sanitizeModule' block in the file MissionScripting.lua.
This file is located in your DCS World install path (and not in your 'Saved Games' path). 
By default the DCS installation path should be '_C:\Program Files\Eagle Dynamics\DCS World OpenBeta_', and the MissionScripting.lua file should be located in '_{DCS World install path}\Scripts\MissionScripting.lua_'
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/799b7086-4d1d-4c71-baf4-b1e35f6684c1)

The end result should look like:
```
--Initialization script for the Mission lua Environment (SSE)

dofile('Scripts/ScriptingSystem.lua')

--Sanitize Mission Scripting environment
--This makes unavailable some unsecure functions. 
--Mission downloaded from server to client may contain potentialy harmful lua code that may use these functions.
--You can remove the code below and make availble these functions at your own risk.

local function sanitizeModule(name)
	_G[name] = nil
	package.loaded[name] = nil
end

do
	--sanitizeModule('os')
	--sanitizeModule('io')
	--sanitizeModule('lfs')
	--_G['require'] = nil
	--_G['loadlib'] = nil
	--_G['package'] = nil
end
```
## Setup your mission using DCS Mission Editor
### Create a new mission
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/6ee48743-3c2f-4459-8d02-2f56bff4582d)

### Add a new trigger to load DCT
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/f594d43a-8c56-424e-a8d5-eb1bac0647b0)

### Add a new trigger to load FL ScriptLoader
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/65a4fcd2-8d11-4d11-9735-6e9d26d48084)

### Place your units
Place the desired BLUE units in the desired positions.
Note that tankers and logistic units are spawn automatically, no need to place them on the map.
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/d291132e-1d5c-4375-b667-d92bcc0d3a3c)

### (Optional) Repack the created mission file
Download latest mission Repacker release '_dcs-miz-repacker.exe_'
Drag and drop the created .miz file to '_dcs-miz-repacker.exe_'.
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/5fd475b8-0142-4171-9173-d0dc03ea57f0)

The repacking will result in two newly created mission files:
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/b53270e0-24a4-424d-a2b3-f84436964948)

### Create a new multiplayer server
Some of the features will only be active in multiplayer mode.
Start one of the generated missions:
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/c7881d69-9c37-483c-b4dd-72ad9b625286)

## Troubleshooting

### Check DCS logs for information about errors related to DCT
DCS log file is located at '_C:\Users\%USERPROFILE%\Saved Games\DCS.openbeta\Logs\dcs.log_'

### Increase logging level
To print additional information and error details in dcs.log, you can set the variable 'debug' to 'True' in DCT configuration file '_dct.cfg_':
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/a0a20a3b-e8fe-4e96-97ad-82963381ea28)

### Errors in dcs.log when resolving filepaths to the configuration 'Can't open file' 
* Sometimes DCS struggles to resulve the %USERPROFILE% system variable. In that case use the absolute paths with your username in dct.cfg.
* In some cases, the path to the Config folder is wrongly constructed, due to some scripts appending additional 'backslash' characters.
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/6e3143c6-b15e-413a-8dd5-2c4f16a67b5a)


	These can be removed if necessary by deleting the calls to separators in the 'server.lua' script.
![image](https://github.com/amasu/Flashpoint-Levant/assets/8228208/2218936c-76c5-4748-a1db-7c8cdc48f681)

