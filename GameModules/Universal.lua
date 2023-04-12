local HttpService = game:GetService("HttpService")


local MainGui = shared.PassionFruitMainGui
local IClientToggledProperty = shared.IClientToggledProperty
local Combattab = MainGui:newtab("Combat")
local BlantantTab = MainGui:newtab("Blantant")
local UtilityTab = MainGui:newtab("Utility")
local CosmeticTab = MainGui:newtab("Cosmetic")

task.wait(1)
print(HttpService:JSONEncode(MainGui))
local GetCombatTab = MainGui:findTab("Combat")

GetCombatTab:newmod(
    { ModName = "Autoclickr", ModDescription = "Cool way to relax your finger",Keybind= "None" },
    function(Value)
        IClientToggledProperty.Autoclickr.Toggled = Value
    end,
    {
        [1] = {
            DisplayText = "CPS",
            ConfigType = "Slider",
            Callback = function(Value)
                print("PassionFruit555")
            end,
            Default = 5,
            Min = 1,
            Max = (10+10),
        },
        [1] = {
            DisplayText = "CPS3",
            ConfigType = "Slider",
            Callback = function(Value)
                print("PassionFruit555")
            end,
            Default = 5,
            Min = 1,
            Max = (10+10),
        },
    }
)