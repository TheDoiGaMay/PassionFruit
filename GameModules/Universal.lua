local HttpService = game:GetService("HttpService")


local MainGui = shared.PassionFruitMainGui

local Combattab = MainGui:newtab("Combat")
local BlantantTab = MainGui:newtab("Blantant")
local UtilityTab = MainGui:newtab("Utility")
local CosmeticTab = MainGui:newtab("Cosmetic")

task.wait(1)
print(HttpService:JSONEncode(MainGui))
local GetCombatTab = MainGui:findTab("Combat")
GetCombatTab:RemoveTab()