-- Addon/mod detection patterns
-- Use these at the top of macros to check for available APIs

-- SuperWoW DLL mod (GUID access, enhanced UnitBuff/UnitDebuff, file I/O)
local hasSuperWoW = SUPERWOW_VERSION ~= nil

-- Nampower DLL mod (spell queuing, cast info, cooldown functions)
local hasNampower = QueueSpellByName ~= nil

-- UnitXP_SP3 addon (distance, LoS, facing, position)
local hasUnitXP = UnitXP and UnitXP("nop", "nop")

-- SuperCleveRoidMacros addon (conditional macro system)
local hasCleveroid = IsAddOnLoaded("SuperCleveRoidMacros")

-- SuperMacro addon (removes 255-char limit, macro book storage)
local hasSuperMacro = IsAddOnLoaded("SuperMacro")

-- Combined capability flags
local hasFullStack = hasSuperWoW and hasNampower and hasUnitXP and hasCleveroid
