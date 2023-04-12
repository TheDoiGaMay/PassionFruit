local HttpService = game:GetService("HttpService")


local MainGui = shared.PassionFruitMainGui
local IClientToggledProperty = shared.IClientToggledProperty
local Combattab = MainGui:newtab("Combat")
local BlantantTab = MainGui:newtab("Blantant")
local UtilityTab = MainGui:newtab("Utility")
local CosmeticTab = MainGui:newtab("Cosmetic")

print(HttpService:JSONEncode(MainGui))
local GetCombatTab = MainGui:findTab("Combat")

GetCombatTab:newmod(
    { ModName = "Autoclicker", ModDescription = "Cool way to relax your finger",Keybind= "None" },
    function(Value)
    end,
    {
        [1] = {
            DisplayText = "CPS",
            ConfigType = "Slider",
            Callback = function(Value)
            end,
            Default = 5,
            Min = 1,
            Max = (10+10),
        },
        [2] = {
            DisplayText = "CPS3",
            ConfigType = "Slider",
            Callback = function(Value)
            end,
            Default = 5,
            Min = 1,
            Max = (10+10),
        },
    }
)

task.wait(5)
GetCombatTab:RemoveMod("Autoclicker")

GetCombatTab:newmod(
    { ModName = "Autoclickr", ModDescription = "Cool way to relax your finger",Keybind= "None" },
    function(Value)
    end,
    {
        [1] = {
            DisplayText = "CPS",
            ConfigType = "Slider",
            Callback = function(Value)
            end,
            Default = 5,
            Min = 1,
            Max = (10+10),
        },
        [2] = {
            DisplayText = "CPS3",
            ConfigType = "Slider",
            Callback = function(Value)
            end,
            Default = 5,
            Min = 1,
            Max = (10+10),
        },
    }
)