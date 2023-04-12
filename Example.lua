local UILibrary = {}
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
UILibrary.CurrentTabSelect = nil
UILibrary.CurrentModSelect = nil

local NewUI = UILibrary:new()

for x = 1,4 do
	task.spawn(function()
		local Combattab = NewUI:newtab("Combat")

		for i = 1,15 do
			task.spawn(function()
				local NewMod = Combattab:newmod(
					{ ModName = HttpService:GenerateGUID(false), ModDescription = HttpService:GenerateGUID(false),Keybind= "None" },
					function(Value)
						print("PassionFruit2")
					end,
					{
						[1] = {
							DisplayText = "Did you know our lastest phone called IPassion?",
							ConfigType = "Label",
						},
						[2] = {
							DisplayText = HttpService:GenerateGUID(false),
							ConfigType = "Toggle",
							Callback = function(Value)
								print("PassionFruit")
							end,
							Value = false,
						},
						[3] = {
							DisplayText = HttpService:GenerateGUID(false),
							ConfigType = "Slider",
							Callback = function(Value)
								print("PassionFruit555")
							end,
							Default = 0,
							Min = 0,
							Max = 100,
						},
						[4] = {
							DisplayText = HttpService:GenerateGUID(false),
							ConfigType = "DropDown",
							Callback = function(Value)
								print("PassionFruit555")
							end,
							List = {HttpService:GenerateGUID(false), HttpService:GenerateGUID(false),HttpService:GenerateGUID(false)},
							Value = "Rick"
						}
					}
				)

			end)
			
		end
	end)
end


return UILibrary
