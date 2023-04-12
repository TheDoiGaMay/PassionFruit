

local MainGui = shared.PassionFruitMainGui

local Combattab = MainGui:newtab("Combat")
local BlantantTab = MainGui:newtab("Blantant")
local UtilityTab = MainGui:newtab("Utility")
local CosmeticTab = MainGui:newtab("Cosmetic")

task.wait(1)
local GetCombatTab = MainGui:FindTab("Combat")
GetCombatTab:RemoveTab()