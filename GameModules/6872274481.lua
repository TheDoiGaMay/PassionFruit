
local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")


--// UI TAB
local MainGui = shared.PassionFruitMainGui
local Combattab = MainGui:findTab("Combat")
local BlantantTab = MainGui:findTab("Blantant")
local UtilityTab = MainGui:findTab("Utility")
local CosmeticTab = MainGui:findTab("Cosmetic")


--// Remove Older Mod
Combattab:RemoveMod("Autoclicker")
BlantantTab:RemoveTab()

---// Varibles
local BedwarLibrary = {}
local LocalPlayer = Players.LocalPlayer


--// Bindable
local updateitem = Instance.new("BindableEvent")

--// Synapse Functions
local getcustomasset = getsynasset or getcustomasset or function(location) return "rbxasset://"..location end
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end

--// Functions 
local function isAlive(plr)
	local plr = plr or LocalPlayer
	if
		plr
		and plr.Character
		and (
			(plr.Character:FindFirstChild("Humanoid"))
			and (plr.Character:FindFirstChild("Humanoid").Health > 0)
			and (plr.Character:FindFirstChild("HumanoidRootPart"))
			and (plr.Character:FindFirstChild("Head"))
		)
	then
		return true
	end
end

local function isNotHoveringOverGui()
	local mousepos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
	for i, v in pairs(LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
		if v.Active then
			return false
		end
	end
	for i, v in pairs(game:GetService("CoreGui"):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
		if v.Active then
			return false
		end
	end
	return true
end

local function GetRemote(t)
	for i, v in next, t do
		if v == "Client" then
			return t[i + 1]
		end
	end
end

local function GetPlayerNearBy(max)
	if not isAlive() then
		return {}
	end
	local t = {}
	for i, v in next, Players:GetPlayers() do
		if isAlive(v) and v ~= LocalPlayer then

			local Position1 = LocalPlayer.Character.HumanoidRootPart.Position
			local Position2 = Vector3.new(v.Character.HumanoidRootPart.Position.X,Position1.Y,v.Character.HumanoidRootPart.Position.Z)

			if
				v.Character.HumanoidRootPart
				and (Position1 - Position2).Magnitude
					<= max
			then
				table.insert(t, v)
			end
		end
	end
	return t
end

local function hashvector(vec)
	return {
		value = vec,
	}
end

local function getEquipped()
	local typetext = ""
	local obj = BedwarLibrary["getInventory"](LocalPlayer).hand
	if obj then
		if BedwarLibrary["ItemTable"][obj.itemType]["sword"] then
			typetext = "sword"
		end
		if obj.itemType:find("wool") or BedwarLibrary["ItemTable"][obj.itemType]["block"] then
			typetext = "block"
		end
		if obj.itemType:find("bow") then
			typetext = "bow"
		end
	end
	return { ["Object"] = obj and obj.tool, ["Type"] = typetext }
end

local function getHotbarSlot(itemName)
	for i5, v5 in pairs(BedwarLibrary["ClientStoreHandler"]:getState().Inventory.observedInventory.hotbar) do
		if v5["item"] and v5["item"].itemType == itemName then
			return i5 - 1
		end
	end
	return nil
end

local function switchItem(tool, legit)
	if legit then
		BedwarLibrary["ClientStoreHandler"]:dispatch({
			type = "InventorySelectHotbarSlot",
			slot = getHotbarSlot(tool.Name),
		})
	end
	pcall(function()
		LocalPlayer.Character.HandInvItem.Value = tool
	end)
	BedwarLibrary["ClientHandler"]:Get(BedwarLibrary["EquipItemRemote"]):CallServerAsync({
		hand = tool,
	})
end

local function getBestTool(block)
	local tool = nil
	local toolnum = 0
	local blockmeta = BedwarLibrary["getItemMetadata"](block)
	local blockType = ""
	if blockmeta["block"] and blockmeta["block"]["breakType"] then
		blockType = blockmeta["block"]["breakType"]
	end
	for i, v in pairs(BedwarLibrary["getInventory"](LocalPlayer)["items"]) do
		local meta = BedwarLibrary["getItemMetadata"](v.itemType)
		if meta["breakBlock"] and meta["breakBlock"][blockType] then
			tool = v
			break
		end
	end
	return tool
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if
		tool
		and (
			isAlive()
			and LocalPlayer.Character:FindFirstChild("HandInvItem")
			and LocalPlayer.Character.HandInvItem.Value ~= tool["tool"]
		)
	then
		if legit then
			if getHotbarSlot(tool.itemType) then
				BedwarLibrary["ClientStoreHandler"]:dispatch({
					type = "InventorySelectHotbarSlot",
					slot = getHotbarSlot(tool.itemType),
				})
				task.wait(0.1)
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool["tool"])
		task.wait(0.1)
	end
end


--// Framework
local KnitGotten, KnitClient
repeat
    KnitGotten, KnitClient = pcall(function()
        return debug.getupvalue(require(LocalPlayer.PlayerScripts.TS.knit).setup, 6)
    end)
    if KnitGotten then break end
    task.wait()
until KnitGotten
repeat task.wait() until debug.getupvalue(KnitClient.Start, 1)
local Flamework = require(ReplicatedStorage["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
local Client = require(ReplicatedStorage.TS.remotes).default.Client
local InventoryUtil = require(ReplicatedStorage.TS.inventory["inventory-util"]).InventoryUtil
local oldRemoteGet = getmetatable(Client).Get

BedwarLibrary = {
	KillEffectMeta = require(game.ReplicatedStorage.TS.locker["kill-effect"]["kill-effect-meta"]).KillEffectMeta,
	KillEffectController = KnitClient.Controllers.KillEffectController,
	DefaultKillEffect = require(LocalPlayer.PlayerScripts.TS.controllers.game.locker["kill-effect"].effects["default-kill-effect"]),
	["AnimationUtil"] = require(
		game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["animation-util"]
	).AnimationUtil,
	["AppController"] = require(
		game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]
	).AppController,
	["BlockController"] = require(
		game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out
	).BlockEngine,
	["BlockEngine"] = require(LocalPlayer.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
	["BlockPlacementController"] = KnitClient.Controllers.BlockPlacementController,
	["BlockBreaker"] = KnitClient.Controllers.BlockBreakController.blockBreaker,
	["ChestController"] = KnitClient.Controllers.ChestController,
	["ClickHold"] = require(
		game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.ui.lib.util["click-hold"]
	).ClickHold,
	["ClientHandler"] = Client,
	["ClientHandlerDamageBlock"] = require(ReplicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out["shared"].remotes).BlockEngineRemotes.Client,
	["ClientStoreHandler"] = require(game.Players.LocalPlayer.PlayerScripts.TS.ui.store).ClientStore,
	["ClientHandlerSyncEvents"] = require(LocalPlayer.PlayerScripts.TS["client-sync-events"]).ClientSyncEvents,
	["CombatConstant"] = require(game:GetService("ReplicatedStorage").TS.combat["combat-constant"]).CombatConstant,
	["CombatController"] = KnitClient.Controllers.CombatController,
	["ConstantManager"] = require(
		game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].constant["constant-manager"]
	).ConstantManager,
	["CooldownController"] = KnitClient.Controllers.CooldownController,
	["damageTable"] = KnitClient.Controllers.DamageController,
	["DropItem"] = getmetatable(KnitClient.Controllers.ItemDropController).dropItemInHand,
	["DropItemRemote"] = GetRemote(
		debug.getconstants(getmetatable(KnitClient.Controllers.ItemDropController).dropItemInHand)
	),
	["EatRemote"] = GetRemote(
		debug.getconstants(debug.getproto(getmetatable(KnitClient.Controllers.ConsumeController).onEnable, 1))
	),
	["EquipItemRemote"] = GetRemote(
		debug.getconstants(
			debug.getprotos(
				shared.oldequipitem
					or require(game:GetService("ReplicatedStorage").TS.entity.entities["inventory-entity"]).InventoryEntity.equipItem
			)[3]
		)
	),
	["FishermanTable"] = KnitClient.Controllers.FishermanController,
	["GameAnimationUtil"] = require(game:GetService("ReplicatedStorage").TS.animation["animation-util"]).GameAnimationUtil,
	["GamePlayerUtil"] = require(game:GetService("ReplicatedStorage").TS.player["player-util"]).GamePlayerUtil,
	["getEntityTable"] = require(game:GetService("ReplicatedStorage").TS.entity["entity-util"]).EntityUtil,
	["getIcon"] = function(item, showinv)
		local itemmeta = BedwarLibrary["getItemMetadata"](item.itemType)
		if itemmeta and showinv then
			return itemmeta.image
		end
		return ""
	end,
	["getInventory"] = function(plr)
		local plr = plr or LocalPlayer
		local suc, result = pcall(function()
			return InventoryUtil.getInventory(plr)
		end)
		return (suc and result or {
			["items"] = {},
			["armor"] = {},
			["hand"] = nil,
		})
	end,
	["getItemMetadata"] = require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta,
	["HighlightController"] = KnitClient.Controllers.EntityHighlightController,
	["ItemTable"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
	["KatanaController"] = KnitClient.Controllers.DaoController,
	["KatanaRemote"] = GetRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.DaoController.onEnable, 4))),
	["KnockbackTable"] = debug.getupvalue(
		require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity,
		1
	),
	
	["PickupRemote"] = GetRemote(
		debug.getconstants(getmetatable(KnitClient.Controllers.ItemDropController).checkForPickup)
	),
	["PlayerUtil"] = require(game:GetService("ReplicatedStorage").TS.player["player-util"]).GamePlayerUtil,
	["QueryUtil"] = require(
		game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out
	).GameQueryUtil,
	["prepareHashing"] = require(game:GetService("ReplicatedStorage").TS["remote-hash"]["remote-hash-util"]).RemoteHashUtil.prepareHashVector3,
	["RespawnController"] = KnitClient.Controllers.BedwarsRespawnController,
	["ResetRemote"] = GetRemote(
		debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))
	),
	["Roact"] = require(ReplicatedStorage["rbxts_include"]["node_modules"]["@rbxts"]["roact"].src),
	["RuntimeLib"] = require(game:GetService("ReplicatedStorage")["rbxts_include"].RuntimeLib),
	["Shop"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop,
	["TeamUpgrades"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.TeamUpgrades,
	["ShopItems"] = debug.getupvalue(
		require(game:GetService("ReplicatedStorage").TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.getShopItem,
		2
	),
	["ShopRight"] = require(
		LocalPlayer.PlayerScripts.TS.controllers.games.bedwars.shop.ui["item-shop"]["shop-left"]["shop-left"]
	).BedwarsItemShopLeft,
	["SoundManager"] = require(
		game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out
	).SoundManager,
	["SoundList"] = require(game:GetService("ReplicatedStorage").TS.sound["game-sound"]).GameSound,
	["sprintTable"] = KnitClient.Controllers.SprintController,
	SprintController = KnitClient.Controllers.SprintController,
	["SwingSword"] = getmetatable(KnitClient.Controllers.SwordController).swingSwordAtMouse,
	["SwingSwordRegion"] = getmetatable(KnitClient.Controllers.SwordController).swingSwordInRegion,
	["SwordController"] = KnitClient.Controllers.SwordController,
	["VictoryScreen"] = require(LocalPlayer.PlayerScripts.TS.controllers["game"].match.ui["victory-section"]).VictorySection,
	["ViewmodelController"] = KnitClient.Controllers.ViewmodelController,
	["WeldTable"] = require(game:GetService("ReplicatedStorage").TS.util["weld-util"]).WeldUtil,
	["AttackRemote"] = GetRemote(debug.getconstants(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"])),
	["ItemMeta"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
	EntityUtil = require(game:GetService("ReplicatedStorage").TS.entity["entity-util"]).EntityUtil,

}

for i, v in pairs(debug.getupvalues(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"])) do
	if tostring(v) == "AC" then
		BedwarLibrary["AttackHashTable"] = v
		for i2, v2 in pairs(v) do
			if i2:find("constructor") == nil and i2:find("__index") == nil and i2:find("new") == nil then
				BedwarLibrary["AttackHashFunction"] = v2
				BedwarLibrary["AttachHashText"] = i2
			end
		end
	end
end

shared.BedwarTable = BedwarLibrary


--------------------------------------// Non-Blantant Tab
----------// AutoClicker Handler
do

    local NextClickTimer = workspace:GetServerTimeNow()
	local AutoclickerConnection = nil

    Combattab:newmod(
    {ModName = "Autoclicker", ModDescription = "Better than built in marco!",Keybind= "None"},
    function(args)
        if args == true then
            AutoclickerConnection = game:GetService("RunService").Heartbeat:Connect(function()

                local UserInputService = game:GetService("UserInputService")
                local pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

                local GetAutoClickerCPS = shared.IClientToggledProperty["Autoclicker"]["Clicker CPS"]
                local GetBlockClickerCPS = shared.IClientToggledProperty["Autoclicker"]["Block Clicker CPS"]
                local GetDoAllowPlaceBlock = shared.IClientToggledProperty["Autoclicker"]["Place Block"]

                local GetCurrentBedwarsEquippedKid = BedwarLibrary.ClientStoreHandler:getState().Bedwars.kit
                if pressed then else return end
                if #BedwarLibrary.AppController:getOpenApps() > (GetCurrentBedwarsEquippedKid == "hannah" and 4 or 3) then return end
                if not isNotHoveringOverGui() then return end
                if workspace:GetServerTimeNow() < NextClickTimer then return end
                if BedwarLibrary.KatanaController.chargingMaid == nil then else return end
            
                if getEquipped()["Type"] == "sword" then
                    
                    NextClickTimer = workspace:GetServerTimeNow() + (1/GetAutoClickerCPS)
                    BedwarLibrary.SwordController:swingSwordAtMouse()
                elseif getEquipped()["Type"] == "block" and GetDoAllowPlaceBlock then
                    local mouseinfo = BedwarLibrary.BlockPlacementController.blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
                    if mouseinfo then
                        if BedwarLibrary.BlockPlacementController.blockPlacer then
                            BedwarLibrary.BlockPlacementController.blockPlacer:placeBlock(mouseinfo.placementPosition)
                            NextClickTimer = workspace:GetServerTimeNow() + (1/GetBlockClickerCPS)
                        end
                    end
                end
                
            end)
        
        else
            if AutoclickerConnection then
                AutoclickerConnection:Disconnect()
                AutoclickerConnection = nil
            end
        end
    end,
    {
        [1] = {
            DisplayText = "Place Block",
            ConfigType = "Toggle",
            Callback = function(Value)
            end,
            Value = false,
        },
        [2] = {
            DisplayText = "Clicker CPS",
            ConfigType = "Slider",
            Callback = function(Value)
            end,
            Default = 5,
            Min = 1,
            Max = 20,
        },
        [3] = {
            DisplayText = "Block Clicker CPS",
            ConfigType = "Slider",
            Callback = function(Value)
            end,
            Default = 15,
            Min = 1,
            Max = 20,
        }
    }
)

end



----------// Hitbox Handler
do
    
    local Connectionlist = {}

    local function CharacterAdded(Char,ShowHitbox)
		local Makepart = Instance.new("Part")
		Makepart.Name = "wkaodmkads"
		Makepart.Anchored = true
		Makepart.CanCollide = false
		Makepart.Transparency = 0.999

		Makepart.Size = Vector3.new(4,6,4)
		Makepart.Parent = Char

		local highlight = Instance.new("Highlight",Makepart)
		highlight.Name = "Highlight"
		highlight.FillTransparency = 1
		highlight.Enabled = ShowHitbox
		while true do
    		Makepart.Position = Char.HumanoidRootPart.Position
    		task.wait()
		end
	end

	local function PlayerAdded(PlayerAddedthingy)
		Connectionlist[PlayerAddedthingy] = RunService.Heartbeat:Connect(function(args)
			if isAlive(PlayerAddedthingy) and not PlayerAddedthingy.Character:FindFirstChild("wkaodmkads") and not (PlayerAddedthingy.Team.TeamColor == LocalPlayer.Team.TeamColor) then
				local DoesShowHitbox = shared.IClientToggledProperty["Hitboxes"]["Show Hitbox"]
                CharacterAdded(PlayerAddedthingy.Character,DoesShowHitbox)
			end
		end)
	end

    Combattab:newmod(
        {ModName = "Hitboxes", ModDescription = "Lazy of aiming at character? aim at the hitbox instead!",Keybind= "None"},
        function(args)
            if args == true then
                for i , v in pairs(Players:GetPlayers()) do
					if v == LocalPlayer then
					else
						PlayerAdded(v)
					end
				end
				Players.PlayerAdded:Connect(PlayerAdded)
            else
                for i , v in pairs(Connectionlist) do
					pcall(function(args)
						i.Character.wkaodmkads:Destroy()
					end)
					v:Disconnect()
					v = nil
				end
				Connectionlist = {}
            end
        end,
        {
            [1] = {
                DisplayText = "Show Hitbox",
                ConfigType = "Toggle",
                Callback = function(Value)
                    for i , v in pairs(Connectionlist) do
                        pcall(function(args)
                            i.Character.wkaodmkads.Highlight.Enabled = Value
                        end)
                    end
                end,
                Value = false,
            },
        }
    )

end



----------// Sprint Handler
do

	local oldSprintFunction
	local thecharconnct

    Combattab:newmod(
        {ModName = "Sprint", ModDescription = "Holding Shift to run? not anymore!",Keybind= "None"},
        function(args)
            if args == true then
				oldSprintFunction = BedwarLibrary.SprintController.stopSprinting
				BedwarLibrary.SprintController.stopSprinting = function(...)
					local originalCall = oldSprintFunction(...)
					BedwarLibrary.SprintController:startSprinting()
					return originalCall
				end
				thecharconnct =  LocalPlayer.CharacterAdded:Connect(function(char)
					char:WaitForChild("Humanoid", 9e9)
					task.wait(0.5)
					BedwarLibrary.SprintController:stopSprinting()
				end)
				task.spawn(function()
					BedwarLibrary.SprintController:startSprinting()
				end)
			else
				if thecharconnct then
					thecharconnct:Disconnect()
					thecharconnct =nil
				end
				if oldSprintFunction then
					BedwarLibrary.SprintController.stopSprinting = oldSprintFunction
					BedwarLibrary.SprintController:stopSprinting()
				end
            end
        end,
        {
        }
    )
end



--------------------------------------// Utility Tab
----------// Auto Tool Handler
do
	local oldenable2
	local olddisable2
	local oldhitblock
	local blockplacetable2 = {}
	local blockplaceenabled2 = false

    UtilityTab:newmod(
        {ModName = "Auto Tool", ModDescription = "Best module of switching breaking tool when you need! (Note: You need to switch to any tool first)",Keybind= "None"},
        function(args)
            if args == true then
                oldenable2 = BedwarLibrary["BlockBreaker"]["enable"]
				olddisable2 = BedwarLibrary["BlockBreaker"]["disable"]
				oldhitblock = BedwarLibrary["BlockBreaker"]["hitBlock"]
				BedwarLibrary["BlockBreaker"]["enable"] = function(Self, tab)
					blockplaceenabled2 = true
					blockplacetable2 = Self
					return oldenable2(Self, tab)
				end
				BedwarLibrary["BlockBreaker"]["disable"] = function(Self)
					blockplaceenabled2 = false
					return olddisable2(Self)
				end
				BedwarLibrary["BlockBreaker"]["hitBlock"] = function(...)
					if isAlive() and blockplaceenabled2 then
						local mouseinfo = blockplacetable2.clientManager:getBlockSelector():getMouseInfo(0)
						if mouseinfo and mouseinfo.target then
							if switchToAndUseTool(mouseinfo.target.blockInstance, true) then
								return
							end
						end
					end
					return oldhitblock(...)
				end
            else
                BedwarLibrary["BlockBreaker"]["enable"] = oldenable2
				BedwarLibrary["BlockBreaker"]["disable"] = olddisable2
				BedwarLibrary["BlockBreaker"]["hitBlock"] = oldhitblock
				oldenable2 = nil
				olddisable2 = nil
				oldhitblock = nil
            end
        end,
        {
        }
    )
end



----------// Hannah Auto Execute Handler
do

    local HannahConnection 
    local CanExecute = true
    UtilityTab:newmod(
        {ModName = "Hannah Auto Execute", ModDescription = "Better than F marco!!",Keybind= "None"},
        function(args)
            if args == true then
				HannahConnection = RunService.Heartbeat:Connect(function()
                    if isAlive() then
						for i, v in next, Players:GetPlayers() do
							if isAlive(v) and v ~= LocalPlayer and v.Character:FindFirstChild("HannahExecuteInteraction")  and v.Character:FindFirstChild("HannahExecuteInteraction").Enabled == true and (LocalPlayer.Character.HumanoidRootPart.Position -  v.Character.PrimaryPart.Position).Magnitude <= v.Character:FindFirstChild("HannahExecuteInteraction").MaxActivationDistance then
								
								if CanExecute then

									CanExecute = false
									
									task.spawn(function(args)
										task.wait(v.Character:FindFirstChild("HannahExecuteInteraction").HoldDuration + 0.1)
										CanExecute = true
									end)
									v.Character:FindFirstChild("HannahExecuteInteraction"):InputHoldBegin()
									task.wait(v.Character:FindFirstChild("HannahExecuteInteraction").HoldDuration)
									v.Character:FindFirstChild("HannahExecuteInteraction"):InputHoldEnd()
								end
							end
						end
					end
                end)
			else
				if HannahConnection then
                    HannahConnection:Disconnect()
                    HannahConnection = nil
                    CanExecute = true
                end
            end
        end,
        {
        }
    )
end



----------// Kaliyah Handler
do

    local CanBeExecute = true

	local att0 = Instance.new("Attachment")
	local att1 = Instance.new("Attachment")

	att0.Parent = workspace.Terrain
	att1.Parent = workspace.Terrain

    local beam = Instance.new("Beam",workspace)
	beam.Enabled = true
	beam.FaceCamera = true
	beam.Color = ColorSequence.new({ -- a color sequence shifting from white to blue
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255)),
	})
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Width0 = 0.2 -- starts small
	beam.Width1 = 2 -- ends big
	local CurrentEnchant

	ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.EnchantTableResearch.OnClientEvent:Connect(function(args)
		CurrentEnchant = args["enchant"]
	end)
	

	local tier = {
		[0] = 1,
		[1] = 1.2,
		[2] = 1.35,
		[3] = 1.5,
	}

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {workspace:WaitForChild("Map")}
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	raycastParams.IgnoreWater = true

    local KaliyahConnection 

    UtilityTab:newmod(
        {ModName = "Kaliyah Auto Punch", ModDescription = "You will punch the enemy whenever their health is below damage calculation",Keybind= "None"},
        function(args)
            if args == true then
                KaliyahConnection = RunService.Heartbeat:Connect(function()
                    if not isAlive() then
						CurrentEnchant = ""
                        return
					end
                    local IsVisiblable = false
					for i, v in next, Players:GetPlayers() do
						if isAlive(v) and v ~= LocalPlayer and v.Character:FindFirstChild("KaliyahPunchInteraction") and v.Character:FindFirstChild("KaliyahPunchInteraction").Enabled == true and (LocalPlayer.Character.HumanoidRootPart.Position -  v.Character.PrimaryPart.Position).Magnitude <= v.Character:FindFirstChild("KaliyahPunchInteraction").MaxActivationDistance then
							IsVisiblable = true
							raycastParams.FilterDescendantsInstances = {workspace:WaitForChild("Map")}

							local VictimLocation = v.Character.PrimaryPart.Position - Vector3.new(0,2.5,0)
							local CharacterLocation = Vector3.new(LocalPlayer.Character.PrimaryPart.Position.X,VictimLocation.Y,LocalPlayer.Character.PrimaryPart.Position.Z)

							local DisplayPosition = (CFrame.new(VictimLocation,(CFrame.new(CharacterLocation,VictimLocation) * CFrame.new(0,0,-299)).Position ) * CFrame.new(0,0,-(3 * 7))).Position
							local VictimLocation2 = (CFrame.new(VictimLocation,(CFrame.new(CharacterLocation,VictimLocation) * CFrame.new(0,0,-299)).Position ) * CFrame.new(0,0,-(3 * 6))).Position

							local RaycastLocation1	= CFrame.new(CharacterLocation,VictimLocation).LookVector.Unit * (3 * 7)			
							local RaycastLocation2	= Vector3.new(VictimLocation2.X,-1000,VictimLocation2.Z)			

							local raycastResult = workspace:Raycast(VictimLocation, RaycastLocation1, raycastParams)
							local newraycastresult2 = workspace:Raycast(VictimLocation2, RaycastLocation2, raycastParams)

							att0.Position = VictimLocation
							
							local GetTheDamageUpgrade = shared.BedwarTable["ClientStoreHandler"]:getState().Bedwars.teamUpgrades["damage"] or -1
						
							local ArmorReduction = 0
							
							--// Check Armor Reduction
							for index , armorinventory in pairs(shared.BedwarTable["getInventory"](v).armor) do
								ArmorReduction += shared.BedwarTable["ItemTable"][armorinventory.itemType] and shared.BedwarTable["ItemTable"][armorinventory.itemType].armor and shared.BedwarTable["ItemTable"][armorinventory.itemType].armor.damageReductionMultiplier or 0
						    end	

							--// Update Position
							att1.Position = raycastResult and raycastResult.Position or DisplayPosition
                            local IsAnywayToggled = shared.IClientToggledProperty["Kaliyah Auto Punch"]["Punch anyway when detect wall or void"]

							local PunchDamage = raycastResult and (IsAnywayToggled and math.huge or 28) or not raycastResult and not newraycastresult2 and math.huge or 6
							PunchDamage *=  tier[GetTheDamageUpgrade + 1]
							local FireDamage = ((5 * tier[GetTheDamageUpgrade + 1]) )
							FireDamage = math.max(math.floor(FireDamage - (FireDamage * ArmorReduction)),1   ) * 2

							local ExtraDamage = CurrentEnchant == "execute_3" and 20 or 0

							if  v.Character.Humanoid.Health <= (PunchDamage + ExtraDamage) + FireDamage then
								
								if CanBeExecute then
									CanBeExecute = false
									task.delay(v.Character:FindFirstChild("KaliyahPunchInteraction").HoldDuration,function(args)
										CanBeExecute = true
									end)
									v.Character:FindFirstChild("KaliyahPunchInteraction"):InputHoldBegin()
									task.wait(v.Character:FindFirstChild("KaliyahPunchInteraction").HoldDuration)
									v.Character:FindFirstChild("KaliyahPunchInteraction"):InputHoldEnd()
								end
							end

						end
					end
					beam.Enabled = IsVisiblable
                end)
			else
				if KaliyahConnection then
                    KaliyahConnection:Disconnect()
                    KaliyahConnection = nil
                end
            end
        end,
        {
            [1] = {
                DisplayText = "Punch anyway when detect wall or void",
                ConfigType = "Toggle",
                Callback = function()
                    
                end,
                Value = false
            }
        }
    )

end



--------------------------------------// Cosmetics Tab
----------// Nyx Sound Handler
do

    local Combo = 1
	local TheWorkspacetime = workspace:GetServerTimeNow()
    local HitConnection
    CosmeticTab:newmod(
        {ModName = "Better Combat Sound", ModDescription = "You will feel so satisfied when fighting while turning this on",Keybind= "None"},
        function(args)
        
        end,
        {
        }
    )

    RunService.Heartbeat:Connect(function(deltaTime)
        if workspace:GetServerTimeNow() > TheWorkspacetime then
			Combo = 1
		end
    end)

    BedwarLibrary["ClientHandler"]:OnEvent("EntityDamageEvent", function(p3)
        if (p3.fromEntity == LocalPlayer.Character) then
            local IsThingToggled = shared.IClientToggledProperty["Better Combat Sound"]["Toggled"]
            if not IsThingToggled then return end
            BedwarLibrary.SoundManager:playSound(BedwarLibrary["SoundList"]["MIDNIGHT_ATTACK_" .. Combo])
            TheWorkspacetime = workspace:GetServerTimeNow() + 2
            Combo = math.clamp(Combo + 1, 1, 5)
            BedwarLibrary.SoundManager:registerSound(BedwarLibrary["SoundList"]["DAMAGE_3"],{volume = 0 })
        else
            BedwarLibrary.SoundManager:registerSound(BedwarLibrary["SoundList"]["DAMAGE_3"],{volume = 1})
        end
    
    end)

end



----------// Kill Effect Handler
do

    local KillEffectName = {}
	for i,v in pairs(BedwarLibrary.KillEffectMeta) do 
		table.insert(KillEffectName, v.name)
		KillEffectName[v.name] = i
	end
	table.sort(KillEffectName, function(a, b) return a:lower() < b:lower() end)

    CosmeticTab:newmod(
        {ModName = "Kill Effect Adjuster", ModDescription = "Change to any kill effect you want beside dont having it",Keybind= "None"},
        function(args)
           
        end,
        {
            [1] = {
                DisplayText = "Selected Kill Effect",
                ConfigType = "DropDown",
                List = KillEffectName,
                Value = "None",
                Callback = function(Value)

                    local IsThingToggled = shared.IClientToggledProperty["Kill Effect Adjuster"]["Toggled"]
                    if IsThingToggled then
                        LocalPlayer:SetAttribute("KillEffectType", KillEffectName[Value])
                    end
                end
            }
        }
    )

end



----------// Bed Destroy Effect Picker
do

    local BedBreakEffectFunction = {
        ["Bed Firework (Grilwar)"] = function(Position)
    
            local BedCFrame = CFrame.new(Position * 3)
        
            local bedBlock = Instance.new("Part")
            bedBlock.Name = "BedBlock"
            bedBlock.Anchored = true
            bedBlock.BottomSurface = Enum.SurfaceType.Smooth
            bedBlock.BrickColor = BrickColor.new("Really black")
            bedBlock.CFrame = CFrame.new(-81, 85, 234.5, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            bedBlock.Color = Color3.fromRGB(17, 17, 17)
            bedBlock.Rotation = Vector3.new(0, -90, 0)
            bedBlock.Size = Vector3.new(5, 1.59, 2.5)
            bedBlock.Transparency = 0
            
            local decal = Instance.new("Decal")
            decal.Name = "Decal"
            decal.Texture = "http://www.roblox.com/asset/?id=57999972"
            decal.Face = Enum.NormalId.Left
            decal.Parent = bedBlock
            
            local roblox = Instance.new("Decal")
            roblox.Name = "roblox"
            roblox.Face = Enum.NormalId.Right
            roblox.Parent = bedBlock
            
            local decal1 = Instance.new("Decal")
            decal1.Name = "Decal"
            decal1.Texture = "http://www.roblox.com/asset/?id=57999987"
            decal1.Face = Enum.NormalId.Right
            decal1.Parent = bedBlock
            
            local decal2 = Instance.new("Decal")
            decal2.Name = "Decal"
            decal2.Texture = "http://www.roblox.com/asset/?id=58000020"
            decal2.Face = Enum.NormalId.Top
            decal2.Parent = bedBlock
            
            local decal3 = Instance.new("Decal")
            decal3.Name = "Decal"
            decal3.Texture = "http://www.roblox.com/asset/?id=57999999"
            decal3.Parent = bedBlock
            
            local decal4 = Instance.new("Decal")
            decal4.Name = "Decal"
            decal4.Texture = "http://www.roblox.com/asset/?id=58000011"
            decal4.Face = Enum.NormalId.Back
            decal4.Parent = bedBlock
    
            local CloneBed = bedBlock
            CloneBed.Parent = workspace
            CloneBed.CFrame = BedCFrame
            CloneBed.Anchored = true
            TweenService:Create(CloneBed,TweenInfo.new(1.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Position = CloneBed.Position + Vector3.new(0,45,0)}):Play()
            
            local Connection = RunService.Heartbeat:Connect(function()
                CloneBed.CFrame *= CFrame.fromEulerAnglesXYZ(0,0.1,0)
            end)
            
            task.wait(1.5)
            
            KnitClient.Controllers.FireworkController:playFireworkEffect(CloneBed.Position + Vector3.new(math.random() * 7 - 3.5, math.random() * 7 - 3.5, math.random() * 7 - 3.5), 4, {
                sizeMultiplier = 1.5, 
                popSoundPlaybackSpeedMultiplier = 1
            });
        
            local firework = Instance.new("Part",workspace)
            firework.Position =	BedCFrame.Position +   Vector3.new(0,45,0)
            firework.Name = "firework"
            firework.Anchored = true
            firework.BottomSurface = Enum.SurfaceType.Smooth
            firework.BrickColor = BrickColor.new("Institutional white")
            firework.CFrame = CFrame.new(0, -19.980484, -29.9756012, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            firework.Color = Color3.fromRGB(248, 248, 248)
            firework.Size = Vector3.new(1, 1, 1)
            firework.TopSurface = Enum.SurfaceType.Smooth
            firework.Transparency = 0
    
            local v8 = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("ConfettiParticle"):Clone();
            v8.Enabled = false;
            v8.Parent = firework;
    
            local bang = Instance.new("Sound",firework)
            bang.Name = "Bang"
            bang.SoundId = "rbxassetid://269146157"
            bang.Volume = 3
            
            local crackle = Instance.new("Sound",firework)
            crackle.Name = "Crackle"
            crackle.SoundId = "http://www.roblox.com/asset/?id=12555594"
            crackle.Volume = 3
    
            bang:Play()
            crackle:Play()
            Connection:Disconnect()
            CloneBed:Destroy()
        end,
    
        ["Portal Yoinking Bed"] = function(Position)
    
        local BedCFrame = CFrame.new(Position * 3)
    
            local bedBlock = Instance.new("Part")
            bedBlock.Name = "BedBlock"
            bedBlock.Anchored = true
            bedBlock.BottomSurface = Enum.SurfaceType.Smooth
            bedBlock.BrickColor = BrickColor.new("Really black")
            bedBlock.CFrame = CFrame.new(-81, 85, 234.5, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            bedBlock.Color = Color3.fromRGB(17, 17, 17)
            bedBlock.Rotation = Vector3.new(0, -90, 0)
            bedBlock.Size = Vector3.new(5, 1.59, 2.5)
            bedBlock.Transparency = 0
            
            local decal = Instance.new("Decal")
            decal.Name = "Decal"
            decal.Texture = "http://www.roblox.com/asset/?id=57999972"
            decal.Face = Enum.NormalId.Left
            decal.Parent = bedBlock
            
            local roblox = Instance.new("Decal")
            roblox.Name = "roblox"
            roblox.Face = Enum.NormalId.Right
            roblox.Parent = bedBlock
            
            local decal1 = Instance.new("Decal")
            decal1.Name = "Decal"
            decal1.Texture = "http://www.roblox.com/asset/?id=57999987"
            decal1.Face = Enum.NormalId.Right
            decal1.Parent = bedBlock
            
            local decal2 = Instance.new("Decal")
            decal2.Name = "Decal"
            decal2.Texture = "http://www.roblox.com/asset/?id=58000020"
            decal2.Face = Enum.NormalId.Top
            decal2.Parent = bedBlock
            
            local decal3 = Instance.new("Decal")
            decal3.Name = "Decal"
            decal3.Texture = "http://www.roblox.com/asset/?id=57999999"
            decal3.Parent = bedBlock
            
            local decal4 = Instance.new("Decal")
            decal4.Name = "Decal"
            decal4.Texture = "http://www.roblox.com/asset/?id=58000011"
            decal4.Face = Enum.NormalId.Back
            decal4.Parent = bedBlock
    
            local CloneBed = bedBlock
            CloneBed.CFrame = BedCFrame
            CloneBed.Parent = workspace
    
            local part = Instance.new("Part",workspace)
    part.Name = "Part"
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.BrickColor = BrickColor.new("Neon orange")
    part.Position = BedCFrame.Position + Vector3.new(0,0.5,0)
    part.Color = Color3.fromRGB(213, 115, 61)
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.TopSurface = Enum.SurfaceType.Smooth
    part.Transparency = 1
    part.Anchored = true
    local mesh = Instance.new("SpecialMesh")
    mesh.Name = "Mesh"
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://4583493289"
    mesh.Scale = Vector3.new(0, 0.001, 0)
    mesh.Parent = part
        
        local ring = part
        local tweentable = {
            Scale = Vector3.new(0.003, 0.001, 0.003),
        }
        
        local tweentable2 = {
            Transparency = 0
        }
    
    
        TweenService:Create(mesh,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),tweentable):Play()
        TweenService:Create(ring,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),tweentable2):Play()
    
        local ringAppear = Instance.new("Sound")
        ringAppear.Name = "RingAppear"
        ringAppear.SoundId = "rbxassetid://6653065352"
        ringAppear.Volume = 1
    
        ringAppear.Parent = ring
        ringAppear:Play()
        
        local Connection = RunService.Heartbeat:Connect(function(dlt)
            ring.CFrame = ring.CFrame * CFrame.fromEulerAnglesXYZ(0,math.min(0.1-(dlt/100),0.01),0) 
        end)
        
        task.wait(1.5)
        CloneBed.Anchored = false
        CloneBed.CanCollide = false
        task.wait(1.5)
    
        local tweentable = {
            Scale = Vector3.new(0, 0.001, 0),
        }
        
        local tweentable2 = {
            Transparency = 1
        }
        TweenService:Create(mesh,TweenInfo.new(.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),tweentable):Play()
        TweenService:Create(part,TweenInfo.new(.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),tweentable2):Play()
        task.wait(.35)
        Connection:Disconnect()
        CloneBed:Destroy()
        ring:Destroy()
        end,
    
        ["Lightning"] = function(Position2)
            local Position = Position2 * 3
            local startpos = 1125
            local startcf = Position - Vector3.new(0, 8, 0)
            local newpos = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2)
    
            local soundpart = Instance.new("Part")
            soundpart.Transparency = 1
            soundpart.Anchored = true 
            soundpart.Size = Vector3.zero
            soundpart.Position = startcf
            soundpart.Parent = workspace
            BedwarLibrary.QueryUtil:setQueryIgnored(soundpart, true)
    
    
            local sound = Instance.new("Sound")
            sound.SoundId = getcustomasset(("IClient/MicsFile/LightningSound.wav"))
            sound.Volume = 3.5
            sound.Pitch = 0.5 + (math.random(1, 3) / 10)
            sound.Parent = soundpart
            sound:Play()
            sound.Ended:Connect(function()
                soundpart:Destroy()
            end)
            
            for wiandsnd = 1,5 do
                for i = startpos - 75, 0, -75 do 
                    local newpos2 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2)
                        if i == 0 then 
                            newpos2 = Vector3.zero
                        end
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(1.5, 1.5, 77)
                        part.Material = Enum.Material.SmoothPlastic
                        part.Anchored = true
                        part.Material = Enum.Material.Neon
                        part.CanCollide = false
                        part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2)
                        part.Parent = workspace
                        local part2 = part:Clone()
                        part2.Size = Vector3.new(3, 3, 78)
                        part2.Color = Color3.new(0.7, 0.7, 0.7)
                        part2.Transparency = 0.7
                        part2.Material = Enum.Material.SmoothPlastic
                        part2.Parent = workspace
                        game:GetService("Debris"):AddItem(part, 0.20)
                        game:GetService("Debris"):AddItem(part2, 0.2)
                        BedwarLibrary.QueryUtil:setQueryIgnored(part, true)
                        BedwarLibrary.QueryUtil:setQueryIgnored(part2, true)
                    newpos = newpos2
                end
                task.wait(0.20)
            end
        end
    }
    
    local Connection

    CosmeticTab:newmod(
        {ModName = "Bed Destroy Effect", ModDescription = "bed broken effect like Hypixel vibe? hell yeah!",Keybind= "None"},
        function(args)
           if args == true then
             Connection = game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.BedwarsBedBreak.OnClientEvent:Connect(function(FireData)
                    local GetSelectedBedEffect = shared.IClientToggledProperty["Bed Destroy Effect"]["Selected bed broken effect"]

                    if FireData.player == Players.LocalPlayer then
                        if BedBreakEffectFunction[GetSelectedBedEffect] then
                            BedBreakEffectFunction[GetSelectedBedEffect](FireData.bedBlockPosition)
                        end
                    end
            
                end)
           else
                if Connection then
                    Connection:Disconnect()
                    Connection = nil
                end
           end
        end,
        {
            [1] = {
                DisplayText = "Selected bed broken effect",
                ConfigType = "DropDown",
                List =  {"Bed Firework (Grilwar)","Portal Yoinking Bed","Lightning","None"},
                Value = "None",
                Callback = function(Value)  
                end
            }
        }
    )
end


----------// Projectile Replacer
do
	local arrow = Instance.new("Model")
    arrow.Name = "arrow"
    arrow.WorldPivot = CFrame.new(-104.526604, 25.517868, 17.8805618, 0.999999642, -1.19009508e-06, -4.27826308e-09, 4.80213203e-09, 8.64965841e-07, 1.00000179, -1.20130289e-06, -1.00000215, 8.67294148e-07)

    local handle = Instance.new("Part")
    handle.Name = "BabyAhAh"

    handle.BottomSurface = Enum.SurfaceType.Smooth
    handle.BrickColor = BrickColor.new("Mid gray")
    handle.CFrame = CFrame.new(-129.649902, 0.875, 49.1570511, -1, -2.70736469e-39, 0, 2.70736469e-39, 1, 0, 0, 0, -1)
    handle.Color = Color3.fromRGB(205, 205, 205)
    handle.Rotation = Vector3.new(-180, 0, 180)
    handle.Size = Vector3.new(1.5, 1.75, 1)
    handle.TopSurface = Enum.SurfaceType.Smooth
    arrow.PrimaryPart = handle
    local specialMesh = Instance.new("SpecialMesh")
    specialMesh.Name = "SpecialMesh"
    specialMesh.MeshType = Enum.MeshType.FileMesh
    specialMesh.MeshId = "rbxassetid://4004497378"
    specialMesh.TextureId = "rbxassetid://4004497529"
    specialMesh.Scale = Vector3.new(3, 3, 3)
    specialMesh.VertexColor = Vector3.new(1, 1, 2)
    specialMesh.Parent = handle

    handle.Parent = arrow

	local oldarrow = ReplicatedStorage.Assets.Projectiles.arrow

    local TheConnection

    CosmeticTab:newmod(
        {ModName = "Baby projectile", ModDescription = "Change your normal arrow into baby!",Keybind= "None"},
        function(args)
           if args == true then
                oldarrow.Parent = script
                arrow.Parent =ReplicatedStorage.Assets.Projectiles
                TheConnection = workspace.ChildAdded:Connect(function(args)
                    if args:FindFirstChild("BabyAhAh") then
                        local sound = Instance.new("Sound")
                        sound.SoundId = getcustomasset(("IClient/MicsFile/BabyArrow.wav"))
                        sound.Volume = 2
                        sound.Parent = args.BabyAhAh
                        sound:Play()
                    end
                end)
           else
                oldarrow.Parent = game:GetService("ReplicatedStorage").Assets.Projectiles
                arrow.Parent =script
                if TheConnection then
                    TheConnection:Disconnect()
                    TheConnection = nil
                end
           end
        end,
        {     
        }
    )

end