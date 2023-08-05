local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local MainGui = shared.PassionFruitMainGui
local IClientToggledProperty = shared.IClientToggledProperty

local Combattab = MainGui:newtab("Combat")
local BlantantTab = MainGui:newtab("Blantant")
local UtilityTab = MainGui:newtab("Utility")
local CosmeticTab = MainGui:newtab("Cosmetic")
local GetCombatTab = MainGui:findTab("Combat")
local WorldTab = MainGui:newtab("World")

--// Autoclicker Handler
do
    GetCombatTab:newmod(
    { ModName = "Autoclicker", ModDescription = "Cool way to relax your finger",Keybind= "None" },
    function(Value)
    end,
    {
        [1] = {
            DisplayText = "Left Click CPS",
            ConfigType = "Slider",
            Callback = function(Value)
            end,
            Default = 5,
            Min = 1,
            Max = (10+10),
        },
        [2] = {
            DisplayText = "Right Click CPS",
            ConfigType = "Slider",
            Callback = function(Value)
            end,
            Default = 5,
            Min = 1,
            Max = (10+10),
        },
    }
)
end



----------// Trail handler
do
	local breadcrumbtrail = nil
	local breadcrumbattachment
	local breadcrumbattachment2
    local Connection
    CosmeticTab:newmod(
        {ModName = "Walk Trail", ModDescription = "Cool way to make your walk better",Keybind= "None"},
        function(args)
            if args == true then

                Connection = RunService.Heartbeat:Connect(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then else return end
                    if breadcrumbtrail == nil then
                        breadcrumbattachment = Instance.new("Attachment")
                        breadcrumbattachment.Position = Vector3.new(0, 0.07 - 2.9, 0.5)
                        breadcrumbattachment2 = Instance.new("Attachment")
                        breadcrumbattachment2.Position = Vector3.new(0, -0.07 - 2.9, 0.5)
                        breadcrumbtrail = Instance.new("Trail")
                        breadcrumbtrail.Attachment0 = breadcrumbattachment
                        breadcrumbtrail.Attachment1 = breadcrumbattachment2
                        breadcrumbtrail.Color = ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 0, 1))
                        breadcrumbtrail.FaceCamera = true
                        breadcrumbtrail.Lifetime = (shared.IClientToggledProperty["Walk Trail"]["Life Time"] / 100)
                        breadcrumbtrail.Enabled = true
                        breadcrumbtrail.Parent = LocalPlayer.Character.HumanoidRootPart
                    else
                        breadcrumbtrail.Lifetime = (shared.IClientToggledProperty["Walk Trail"]["Life Time"] / 100)
                        breadcrumbtrail.Parent = LocalPlayer.Character.HumanoidRootPart
                        breadcrumbattachment.Parent =LocalPlayer.Character.HumanoidRootPart
                        breadcrumbattachment2.Parent = LocalPlayer.Character.HumanoidRootPart
                    end
                end)

              
            else
                if breadcrumbtrail then
                    breadcrumbtrail:Destroy()
                    breadcrumbtrail = nil
                end
                if breadcrumbattachment then
                    breadcrumbattachment:Destroy()
                end
                if breadcrumbattachment2 then
                    breadcrumbattachment2:Destroy()
                end
                if Connection then
                    Connection:Disconnect()
                end
            end
        end,
        {
            [1] = {
                DisplayText = "Life Time",
                ConfigType = "Slider",
                Callback = function()
                    
                end,
                Default = 20,
                Min = 1,
                Max = 100,
            }
        }
    )
end



----------// Cape handler
do

    local function Cape(char, texture)
        for i, v in pairs(char:GetDescendants()) do
            if v.Name == "Cape" then
                v:Remove()
            end
        end
        local hum = char:WaitForChild("Humanoid")
        local torso = nil
        if hum.RigType == Enum.HumanoidRigType.R15 then
            torso = char:WaitForChild("UpperTorso")
        else
            torso = char:WaitForChild("Torso")
        end
        local p = Instance.new("Part", torso.Parent)
        p.Name = "Cape"
        p.Anchored = false
        p.CanCollide = false
        p.TopSurface = 0
        p.BottomSurface = 0
        p.FormFactor = "Custom"
        p.Size = Vector3.new(0.2, 0.2, 0.2)
        p.Transparency = 0
        p.BrickColor = BrickColor.new("Black")
        local decal = Instance.new("Decal", p)
        decal.Texture = texture
        decal.Face = "Back"
        local msh = Instance.new("BlockMesh", p)
        msh.Scale = Vector3.new(9, 17.5, 0.5)
        local motor = Instance.new("Motor", p)
        motor.Part0 = p
        motor.Part1 = torso
        motor.MaxVelocity = 0.01
        motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(90), 0)
        motor.C1 = CFrame.new(0, 1, 0.45) * CFrame.Angles(0, math.rad(90), 0)
        local wave = false
        repeat
            wait(1 / 44)
            decal.Transparency = torso.Transparency
            local ang = 0.1
            local oldmag = torso.Velocity.magnitude
            local mv = 0.002
            if wave then
                ang = ang + ((torso.Velocity.magnitude / 10) * 0.05) + 0.05
                wave = false
            else
                wave = true
            end
            ang = ang + math.min(torso.Velocity.magnitude / 11, 0.5)
            motor.MaxVelocity = math.min((torso.Velocity.magnitude / 111), 0.04) --+ mv
            motor.DesiredAngle = -ang
            if motor.CurrentAngle < -0.2 and motor.DesiredAngle > -0.2 then
                motor.MaxVelocity = 0.04
            end
            repeat
                wait()
            until motor.CurrentAngle == motor.DesiredAngle
                or math.abs(torso.Velocity.magnitude - oldmag) >= (torso.Velocity.magnitude / 10) + 1
            if torso.Velocity.magnitude < 0.1 then
                wait(0.1)
            end
        until not p or p.Parent ~= torso.Parent
    end
    
    local function SpecialCape(char, texture)
        for i, v in pairs(char:GetDescendants()) do
            if v.Name == "Cape" then
                v:Remove()
            end
        end
        local hum = char:WaitForChild("Humanoid")
        local torso = nil
        if hum.RigType == Enum.HumanoidRigType.R15 then
            torso = char:WaitForChild("UpperTorso")
        else
            torso = char:WaitForChild("Torso")
        end
        local p = Instance.new("Part", torso.Parent)
        p.Name = "Cape"
        p.Anchored = false
        p.CanCollide = false
        p.TopSurface = 0
        p.BottomSurface = 0
        p.FormFactor = "Custom"
        p.Size = Vector3.new(0.2, 0.2, 0.2)
        p.Transparency = 0
        p.BrickColor = BrickColor.new("Black")
        local decal = Instance.new("Decal", p)
        --decal.Texture = "http://www.roblox.com/asset/?id=7596459141"
        decal.Face = "Back"
    
        spawn(function()
            local x = 0.06 -- number of seconds
    
            local CapeTexture = {
                "http://www.roblox.com/asset/?id=7596459141",
                "http://www.roblox.com/asset/?id=7596439980",
                "http://www.roblox.com/asset/?id=7596441418",
                "http://www.roblox.com/asset/?id=8574453387",
                "http://www.roblox.com/asset/?id=7596477697",
                "http://www.roblox.com/asset/?id=7596520279",
                "http://www.roblox.com/asset/?id=7596536228",
                "http://www.roblox.com/asset/?id=7604541151",
                "http://www.roblox.com/asset/?id=7604546665",
                "http://www.roblox.com/asset/?id=7604556372",
                "http://www.roblox.com/asset/?id=7604566245",
                "http://www.roblox.com/asset/?id=7604591195",
                "http://www.roblox.com/asset/?id=7604597871",
                "http://www.roblox.com/asset/?id=7604611676",
                "http://www.roblox.com/asset/?id=7604683032",
                "http://www.roblox.com/asset/?id=7604697467",
                "http://www.roblox.com/asset/?id=7604718179",
                "http://www.roblox.com/asset/?id=7604737729",
                "http://www.roblox.com/asset/?id=7604724901",
                "http://www.roblox.com/asset/?id=7604835358",
                "http://www.roblox.com/asset/?id=7604806606",
                "http://www.roblox.com/asset/?id=7604846482",
                "http://www.roblox.com/asset/?id=7604902004",
                "http://www.roblox.com/asset/?id=7604918864",
                "http://www.roblox.com/asset/?id=7604926863",
                "http://www.roblox.com/asset/?id=7604926863",
                "http://www.roblox.com/asset/?id=7604954258",
                "http://www.roblox.com/asset/?id=7604948766",
                "http://www.roblox.com/asset/?id=7605031118",
                "http://www.roblox.com/asset/?id=7605044918",
            }
    
            while true do
                for i, v in pairs(CapeTexture) do
                    decal.Texture = CapeTexture[i]
                    task.wait(x)
                end
            end
        end)
    
        local msh = Instance.new("BlockMesh", p)
        msh.Scale = Vector3.new(9, 17.5, 0.5)
        local motor = Instance.new("Motor", p)
        motor.Part0 = p
        motor.Part1 = torso
        motor.MaxVelocity = 0.01
        motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(90), 0)
        motor.C1 = CFrame.new(0, 1, 0.45) * CFrame.Angles(0, math.rad(90), 0)
        local wave = false
        repeat
            wait(1 / 44)
            decal.Transparency = torso.Transparency
            local ang = 0.1
            local oldmag = torso.Velocity.magnitude
            local mv = 0.002
            if wave then
                ang = ang + ((torso.Velocity.magnitude / 10) * 0.05) + 0.05
                wave = false
            else
                wave = true
            end
            ang = ang + math.min(torso.Velocity.magnitude / 11, 0.5)
            motor.MaxVelocity = math.min((torso.Velocity.magnitude / 111), 0.04) --+ mv
            motor.DesiredAngle = -ang
            if motor.CurrentAngle < -0.2 and motor.DesiredAngle > -0.2 then
                motor.MaxVelocity = 0.04
            end
            repeat
                wait()
            until motor.CurrentAngle == motor.DesiredAngle
                or math.abs(torso.Velocity.magnitude - oldmag) >= (torso.Velocity.magnitude / 10) + 1
            if torso.Velocity.magnitude < 0.1 then
                wait(0.1)
            end
        until not p or p.Parent ~= torso.Parent
    end

	local Capeconnection

    CosmeticTab:newmod(
        {ModName = "Cape", ModDescription = "Cool way to make your avatar messy",Keybind= "None"},
        function(args)
            if args == true then

                local GetCapeValue = shared.IClientToggledProperty["Cape"]["Cape Type"]

                Capeconnection = LocalPlayer.CharacterAdded:Connect(function(char)
					task.spawn(function()
						pcall(function()
							if GetCapeValue == "Rick Astley" then
								SpecialCape(char, "rbxassetid://880811505")
							else
								Cape(char, "rbxassetid://880811505")
							end
						end)
					end)
				end)
				if LocalPlayer.Character then
					task.spawn(function()
						pcall(function()
							if GetCapeValue == "Rick Astley" then
								SpecialCape(LocalPlayer.Character, "rbxassetid://880811505")
							else
								Cape(LocalPlayer.Character, "rbxassetid://880811505")
							end
						end)
					end)
				end
            else
                if Capeconnection then
					Capeconnection:Disconnect()
				end
				if LocalPlayer.Character then
					for i, v in pairs(LocalPlayer.Character:GetDescendants()) do
						if v.Name == "Cape" then
							v:Destroy()
						end
					end
				end
            end
        end,
        {
            [1] = {
                DisplayText = "Cape Type",
                ConfigType = "DropDown",
                Callback = function(Value)
                    if shared.IClientToggledProperty["Cape"].Toggled == true then
                        if Capeconnection then
                            Capeconnection:Disconnect()
                        end
                        if LocalPlayer.Character then
                            for i, v in pairs(LocalPlayer.Character:GetDescendants()) do
                                if v.Name == "Cape" then
                                    v:Destroy()
                                end
                            end
                        end

                        if LocalPlayer.Character then
                            task.spawn(function()
                                pcall(function()
                                    if Value == "Rick Astley" then
                                        SpecialCape(LocalPlayer.Character, "rbxassetid://880811505")
                                    else
                                        Cape(LocalPlayer.Character, "rbxassetid://880811505")
                                    end
                                end)
                            end)
                        end

                    end
                end,
                List = {"Normal","Rick Astley"},
                Value = "Normal"
            }
        }
    )
end



----------// Free Cam handler
do
    
end

----------// Fake Lag handler
do

    local TheConnection
    local LagToWhatTime = tick()
    local TimeToStartFakeLag = tick()
    local FirstTimeLagging = false
    local IsLagging = false
    BlantantTab:newmod(
        {ModName = "Fake Lag", ModDescription = "Uhm idk",Keybind= "None"},
        function(args)
            if args == true then
                TheConnection = RunService.Heartbeat:Connect(function()

                    if LagToWhatTime > tick() then
                            
                        game:GetService("NetworkClient"):SetOutgoingKBPSLimit((NearPlayerOnly and IsNear == false and IsStillFakeLag and 4 or 1))

                        if IsLagging == false then
                            IsLagging = true
                            print("Lagging")
                            game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.GroundHit:FireServer()
                        end


                        if FirstTimeLagging == false then
                            FirstTimeLagging = true
                            for i = 1,10 do
                                game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.GroundHit:FireServer()
                            end
                        end
                    else
                        if IsLagging == true then
                            IsLagging = false
                            print("Stopping Lagging")
                        end
                        game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
                    end


                    if LagToWhatTime < tick() and tick() > TimeToStartFakeLag then
                        LagToWhatTime = tick() +  (shared.IClientToggledProperty["Fake Lag"]["Spoof Time"]/100)
                        TimeToStartFakeLag = tick() + ((shared.IClientToggledProperty["Fake Lag"]["Spoof Each Delay"]/100)  + (shared.IClientToggledProperty["Fake Lag"]["Spoof Time"]/100))
                    end
                    
                end)

            else
                if TheConnection then
                    TheConnection:Disconnect()
                end
                game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
            end
        end,
        {
        [1] = {
            DisplayText = "This one 100 is 1 seconds 0 is 0 seconds",
            ConfigType = "Label",
        },
        [2] = {
            DisplayText = "Spoof Time",
            ConfigType = "Slider",
            Callback = function()
                
            end,
            Default = 50,
            Min = 1,
            Max = 100,
            },
        [3] = {
            DisplayText = "Spoof Each Delay",
            ConfigType = "Slider",
            Callback = function()
                    
            end,
            Default = 50,
            Min = 1,
            Max = 100,
        },
        }
    )

end


