
local CollectionService = game:GetService("CollectionService")
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

---// Varibles
local BedwarLibrary = {}
repeat
    task.wait()
until  Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer


--// Bindable
local updateitem = Instance.new("BindableEvent")
local DoNotPlaceAnyBlock = false

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

local function getItem(itemName)
	for slot, item in pairs(BedwarLibrary["ClientStoreHandler"]:getState().Inventory.observedInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local function getHotbarSlot(itemName)
	for index, itemvalue in pairs(BedwarLibrary["ClientStoreHandler"]:getState().Inventory.observedInventory.hotbar) do
		if itemvalue["item"] and itemvalue["item"].itemType == itemName then
			return index - 1
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
        else
            if tool == nil and meta["breakBlock"] then
                tool = v
            end
		end
	end
	return tool
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(typeof(block) == "string" and block or block.Name)
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
				return true
			else
				return false
			end
		end
		switchItem(tool["tool"])
		task.wait(0.1)
	end
end

local function getPlacedBlock(pos)
	local roundedPosition = BedwarLibrary.BlockController:getBlockPosition(pos)
	return BedwarLibrary.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local healthbarblocktable = {
    blockHealth = -1,
    breakingBlockPosition = Vector3.zero
}

function BreakBlock(Position)
    if LocalPlayer:GetAttribute("DenyBlockBreak") then
        return
    end

    local block, blockpos = getPlacedBlock(Position)

    if BedwarLibrary.BlockEngineClientEvents.DamageBlock:fire(block.Name, blockpos, block):isCancelled() then
        return
    end

    local blockhealthbarpos = {blockPosition = Vector3.zero}
	local blockdmg = 0
	if block and block.Parent ~= nil then
		if ((LocalPlayer.Character.HumanoidRootPart.Position) - (blockpos * 3)).magnitude > 30 then return end
			switchToAndUseTool(block)
			blockhealthbarpos = {
				blockPosition = blockpos
			}

            task.spawn(function()
                local animation
                animation = BedwarLibrary.AnimationUtil:playAnimation(LocalPlayer, BedwarLibrary.BlockController:getAnimationController():getAssetId(1))
                BedwarLibrary.ViewmodelController:playAnimation(15)
                task.wait(0.3)
                if animation ~= nil then
                    animation:Stop()
                    animation:Destroy()
                end
            end)


			task.spawn(function()
			BedwarLibrary.ClientHandlerDamageBlock:Get("DamageBlock"):CallServerAsync({
				blockRef = blockhealthbarpos, 
				hitPosition = blockpos * 3, 
				hitNormal = Vector3.FromNormalId(Enum.NormalId.Top)
			}):andThen(function(result)
				if result ~= "failed" then
					failedBreak = 0
					if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
						local blockdata = BedwarLibrary.BlockController:getStore():getBlockData(blockhealthbarpos.blockPosition)
						local blockhealth = blockdata and blockdata:GetAttribute(LocalPlayer.Name .. "_Health") or block:GetAttribute("Health")
						healthbarblocktable.blockHealth = blockhealth
						healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
					end

					healthbarblocktable.blockHealth = result == "destroyed" and 0 or healthbarblocktable.blockHealth
					blockdmg = BedwarLibrary.BlockController:calculateBlockDamage(LocalPlayer, blockhealthbarpos)
					healthbarblocktable.blockHealth = math.max(healthbarblocktable.blockHealth - blockdmg, 0)
					BedwarLibrary.BlockBreaker:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg, block)
						if healthbarblocktable.blockHealth <= 0 then
							BedwarLibrary.BlockBreaker.breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, LocalPlayer)
							BedwarLibrary.BlockBreaker.healthbarMaid:DoCleaning()
							healthbarblocktable.breakingBlockPosition = Vector3.zero
						else
							BedwarLibrary.BlockBreaker.breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, LocalPlayer)
						end
					end
					failedBreak = failedBreak + 1
				end)
			end)
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

BedwarLibrary = {
    EmoteMeta = require(ReplicatedStorage.TS.locker.emote["emote-meta"]).EmoteMeta,
	KillEffectMeta = require(game.ReplicatedStorage.TS.locker["kill-effect"]["kill-effect-meta"]).KillEffectMeta,
	KillEffectController = KnitClient.Controllers.KillEffectController,
	DefaultKillEffect = require(LocalPlayer.PlayerScripts.TS.controllers.game.locker["kill-effect"].effects["default-kill-effect"]),
	["AnimationUtil"] = require(
		game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["animation-util"]
	).AnimationUtil,
	["AppController"] = require(
		game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]
	).AppController,

    --// Blocks
    BlockBreaker = KnitClient.Controllers.BlockBreakController.blockBreaker,
	BlockController = require(ReplicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
	BlockCpsController = KnitClient.Controllers.BlockCpsController,
    BlockEngine = require(LocalPlayer.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
    BlockEngineClientEvents = require(ReplicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["block-engine-client-events"]).BlockEngineClientEvents,
    BlockPlacementController = KnitClient.Controllers.BlockPlacementController,
    BlockPlacer = require(ReplicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
	
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
    GameAnimationType = require(ReplicatedStorage.TS.animation["animation-type"]).AnimationType,
	["GamePlayerUtil"] = require(game:GetService("ReplicatedStorage").TS.player["player-util"]).GamePlayerUtil,
	["getEntityTable"] = require(game:GetService("ReplicatedStorage").TS.entity["entity-util"]).EntityUtil,
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
    KnockbackUtil = require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil,

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
	["SoundManager"] = require(
		game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out
	).SoundManager,
	["SoundList"] = require(game:GetService("ReplicatedStorage").TS.sound["game-sound"]).GameSound,
	["sprintTable"] = KnitClient.Controllers.SprintController,
	SprintController = KnitClient.Controllers.SprintController,
	["SwingSword"] = getmetatable(KnitClient.Controllers.SwordController).swingSwordAtMouse,
	["SwingSwordRegion"] = getmetatable(KnitClient.Controllers.SwordController).swingSwordInRegion,
    SwordController = KnitClient.Controllers.SwordController,
	["VictoryScreen"] = require(LocalPlayer.PlayerScripts.TS.controllers["game"].match.ui["victory-section"]).VictorySection,
	["ViewmodelController"] = KnitClient.Controllers.ViewmodelController,
	["WeldTable"] = require(game:GetService("ReplicatedStorage").TS.util["weld-util"]).WeldUtil,
	["AttackRemote"] = GetRemote(debug.getconstants(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"])),
	["ItemMeta"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
	EntityUtil = require(game:GetService("ReplicatedStorage").TS.entity["entity-util"]).EntityUtil,

    getIcon = function(item, showinv)
        local itemmeta = BedwarLibrary.ItemTable[item.itemType]
        if itemmeta and showinv then
            return itemmeta.image or ""
        end
        return ""
    end,
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
    local StartPlacing = nil

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

                local GetCurrentState = BedwarLibrary.ClientStoreHandler:getState()
                if GetCurrentState.Game.matchState == 0 then return end
                if pressed then else StartPlacing = nil return end
                
                if not isNotHoveringOverGui() then return end
                if workspace:GetServerTimeNow() < NextClickTimer then return end
                if BedwarLibrary.KatanaController.chargingMaid == nil then else return end
                
                if getEquipped()["Type"] == "sword" then 
                    NextClickTimer = workspace:GetServerTimeNow() + (1/GetAutoClickerCPS)
                    BedwarLibrary.SwordController:swingSwordAtMouse()
                elseif getEquipped()["Type"] == "block" and GetDoAllowPlaceBlock and DoNotPlaceAnyBlock == false then
                    local mouseinfo = BedwarLibrary.BlockPlacementController.blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
                    if mouseinfo then

                        if not StartPlacing then
                            StartPlacing = tick()
                        else
                            if (tick() - StartPlacing) > (1/12) then
                                if BedwarLibrary.BlockPlacementController.blockPlacer then
                                    BedwarLibrary.BlockPlacementController.blockPlacer:placeBlock(mouseinfo.placementPosition)
                                    NextClickTimer = workspace:GetServerTimeNow() + (1/GetBlockClickerCPS)
                                end
                            end
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



----------// Velocity Handler
do
    
    local KBFunction = nil

    Combattab:newmod(
        {ModName = "Velocity", ModDescription = "Hate current Knockback system when u just bought 1K USD PC for kb advantage?? Passionfruit make it better and cheaper!",Keybind= "None"},
        function(args)
            if args == true then
                KBFunction = BedwarLibrary.KnockbackUtil.applyKnockback
				BedwarLibrary.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					knockback = knockback or {}

                    local GetHorValue = shared.IClientToggledProperty["Velocity"]["Horizontal"]
                    local GetVertValue = shared.IClientToggledProperty["Velocity"]["Vertical"]

					if GetHorValue == 0 and GetVertValue == 0 then return end
					knockback.horizontal = (knockback.horizontal or 1) * (GetHorValue / 100)
					knockback.vertical = (knockback.vertical or 1) * (GetVertValue / 100)
					return KBFunction(root, mass, dir, knockback, ...)
				end
			else
				if KBFunction then
                    BedwarLibrary.KnockbackUtil.applyKnockback = KBFunction
                end
            end
        end,
        {
            [1] = {
                DisplayText = "Horizontal",
                ConfigType = "Slider",
                Callback = function(Value)
                end,
                Default = 100,
                Min = 0,
                Max = 100,
            },
            [2] = {
                DisplayText = "Vertical",
                ConfigType = "Slider",
                Callback = function(Value)
                end,
                Default = 100,
                Min = 0,
                Max = 100,
            },
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
                    print(...)
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



----------// Kit ESP Handler
do

    local espobjs = {}
    local ESPConnection = {}
	local espfold = Instance.new("Folder")

    local StarsIconIndex = {
        CritStar = "crit_star",
        VitalityStar = "vitality_star",
    }

    espfold.Parent = game.CoreGui

    function RenderItem(ItemPrimaryPart, icon)
        local billboard = Instance.new("BillboardGui")
		billboard.Parent = espfold
		billboard.Name = "iron"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 1, 0)
		billboard.Size = UDim2.new(0, 32, 0, 32)
		billboard.AlwaysOnTop = true
		billboard.Adornee = ItemPrimaryPart
		local image = Instance.new("ImageLabel")
		image.BackgroundTransparency = 0.5
		image.BorderSizePixel = 0
		image.Image = BedwarLibrary.getIcon({itemType = (icon == "crit_star" and StarsIconIndex[ItemPrimaryPart.Parent.Name] or icon)}, true)
		image.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		image.Size = UDim2.new(0, 32, 0, 32)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Parent = billboard
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		espobjs[ItemPrimaryPart] = billboard


    end

    local IconIndex = {
        metal_detector = "iron",
        beekeeper = "bee",
        bigman = "natures_essence_1",
        star_collector = "crit_star"
    }

    local KitItemTag = {
        metal_detector = "hidden-metal",
        beekeeper = "bee",
        bigman = "treeOrb",
        star_collector = "stars"
    }

    UtilityTab:newmod(
        {ModName = "Kit ESP", ModDescription = "Show where all the item are! so u dont have to walk around the map 24/7",Keybind= "None"},
        function(args)
            if args == true then

                local GetCurrentState = BedwarLibrary.ClientStoreHandler:getState()
                local GetCurrentBedwarsEquippedKid = GetCurrentState.Bedwars.kit

                if IconIndex[GetCurrentBedwarsEquippedKid] and KitItemTag[GetCurrentBedwarsEquippedKid] then
                   
                    ESPConnection.InstanceAdded = CollectionService:GetInstanceAddedSignal(KitItemTag[GetCurrentBedwarsEquippedKid]):Connect(function(newObject)
                        RenderItem(newObject.PrimaryPart, IconIndex[GetCurrentBedwarsEquippedKid])
                    end)
                    
                    ESPConnection.InstanceRemoved = CollectionService:GetInstanceRemovedSignal(KitItemTag[GetCurrentBedwarsEquippedKid]):Connect(function(v)
                        if espobjs[v.PrimaryPart] then
                            espobjs[v.PrimaryPart]:Destroy()
                            espobjs[v.PrimaryPart] = nil
                        end
                    end)

                    for i,v in pairs(CollectionService:GetTagged(KitItemTag[GetCurrentBedwarsEquippedKid])) do 
                        RenderItem(v.PrimaryPart, IconIndex[GetCurrentBedwarsEquippedKid])
                    end

                end
                
			else
				
                if ESPConnection.InstanceAdded then
                    ESPConnection.InstanceAdded:Disconnect()
                    ESPConnection.InstanceAdded = nil
                end

                if ESPConnection.InstanceRemoved then
                    ESPConnection.InstanceRemoved:Disconnect()
                    ESPConnection.InstanceRemoved = nil
                end

                espfold:ClearAllChildren()
                table.clear(espobjs)

            end
        end,
        {
            [1] = {
                DisplayText = "You though there configuration for it? lol",
                ConfigType = "Label",
                Callback = function()
                    
                end,
                Value = false
            }
        }
    )
end



----------// No Explosion particle Handler
do
    
    local NoParticleConnection = nil
    local ShowTNTRadiusConnection = nil
    local ShowTNTDestroyedConnection = nil
    local TNTRadiusRender = nil
    local VisualTable = {}
    UtilityTab:newmod(
        {ModName = "Explosion", ModDescription = "TNT / Fireball Related",Keybind= "None"},
        function(args)
            if args == true then

                NoParticleConnection = workspace.Explosions.ChildAdded:Connect(function(object)
                    if not shared.IClientToggledProperty["Explosion"]["No Explosion Particle"] then return end
                    task.wait()
                    object:ClearAllChildren()
                end)
               
                ShowTNTRadiusConnection = CollectionService:GetInstanceAddedSignal("tnt"):Connect(function(obj)
                    if not shared.IClientToggledProperty["Explosion"]["Show Explosion Radius (Not Accurate)"] then return end
                    local killaurarangecirclepart = Instance.new("MeshPart")
				    killaurarangecirclepart.MeshId = "rbxassetid://3726303797"
				    killaurarangecirclepart.Color = Color3.fromRGB(255,255,255)
				    killaurarangecirclepart.CanCollide = false
				    killaurarangecirclepart.Anchored = true
				    killaurarangecirclepart.Material = Enum.Material.Neon
				    killaurarangecirclepart.Size = Vector3.new(24 * 0.75, 0.01, 24 * 0.75)
                    killaurarangecirclepart.Transparency = shared.IClientToggledProperty["Explosion"]["Radius Transparency"] / 100
				    killaurarangecirclepart.Parent = workspace.CurrentCamera
                    killaurarangecirclepart.Position = obj.Position
				    BedwarLibrary.QueryUtil:setQueryIgnored(killaurarangecirclepart, true)
                    VisualTable[obj] = killaurarangecirclepart
                end)

                ShowTNTDestroyedConnection = CollectionService:GetInstanceRemovedSignal("tnt"):Connect(function(obj)
                    if VisualTable[obj] then
                        VisualTable[obj]:Destroy()
                    end
                end)

                TNTRadiusRender = RunService.Heartbeat:Connect(function()
                    for index, value in VisualTable do
                        value.Position = index.Position
                    end
                end)

			else
				
                if NoParticleConnection then
                    NoParticleConnection:Disconnect()
                    NoParticleConnection = nil
                end
              
                if ShowTNTRadiusConnection then
                    ShowTNTRadiusConnection:Disconnect()
                    ShowTNTRadiusConnection = nil
                end

                if ShowTNTDestroyedConnection then
                    ShowTNTDestroyedConnection:Disconnect()
                    ShowTNTDestroyedConnection = nil
                end

                if TNTRadiusRender then
                    TNTRadiusRender:Disconnect()
                    TNTRadiusRender = nil
                end

            end
        end,
        {
            [1] = {
                DisplayText = "Show Explosion Radius (Not Accurate)",
                ConfigType = "Toggle",
                Callback = function()
                    
                end,
                Value = false
            },
            [2] = {
                DisplayText = "No Explosion Particle",
                ConfigType = "Toggle",
                Callback = function()
                    
                end,
                Value = false
            },
            [3] = {
                DisplayText = "For No Explosion Radius",
                ConfigType = "Label",
                Callback = function()
                    
                end,
                Value = false
            },
            [4] = {
                DisplayText = "Radius Transparency",
                ConfigType = "Slider",
                Callback = function(Value)
                end,
                Default = 20,
                Min = 0,
                Max = 100,
            }
        }
    )
end



----------// Auto Ginger
do

    PlaceBlockEngine = BedwarLibrary.BlockPlacer.new(BedwarLibrary.BlockEngine, "gumdrop_bounce_pad")


    function PlaceGinger(Position)
        if getItem("gumdrop_bounce_pad") then
            switchItem(getItem("gumdrop_bounce_pad").tool,true)
            PlaceBlockEngine.blockType = "gumdrop_bounce_pad"
			return PlaceBlockEngine:placeBlock(Vector3.new(Position.X / 3, Position.Y / 3, Position.Z / 3))
		end
    end

    function RoudUpPosition(Position)
        return Vector3.new(math.floor((Position.X / 3) + 0.5) * 3, math.floor((Position.Y / 3) + 0.5) * 3, math.floor((Position.Z / 3) + 0.5) * 3) 
    end

    UtilityTab:newmod(
        {ModName = "GingerbreadMan", ModDescription = "Tired of quick hotkeying + tryharding with ginger? just use this ez peezee",Keybind= "None",BindOnly = true},
        function(args)
            if args == true then else return end
            if not isAlive() then return end

            if shared.IClientToggledProperty["GingerbreadMan"]["Keep watching for ground"] == true then
                repeat
                    task.wait() 
                until not (LocalPlayer.Character.Humanoid.FloorMaterial == Enum.Material.Air)
                task.wait()
            end
            
            local CurrentPlayerPosition = isAlive() and LocalPlayer.Character.HumanoidRootPart.Position
            local CurrentPlayerHrootSize = LocalPlayer.Character.HumanoidRootPart.Size
            local CurrentHumanoid = LocalPlayer.Character.Humanoid
            local GetCurrentEquuipped = getEquipped()
            DoNotPlaceAnyBlock = true
            local pos = Vector3.new(CurrentPlayerPosition.X, RoudUpPosition(Vector3.new(0, CurrentPlayerPosition.Y - (((CurrentPlayerHrootSize.Y / 2) + CurrentHumanoid.HipHeight) - 1.5), 0)).Y, CurrentPlayerPosition.Z)
            task.spawn(function()
                PlaceGinger(pos)
            end)

            task.delay(0.075, function()    
                local block, blockpos = getPlacedBlock(pos)
                if block.Name == "gumdrop_bounce_pad" then
                    switchToAndUseTool("gumdrop_bounce_pad",true)
                    BreakBlock(pos)
                    task.wait(0.1)
                    switchItem(GetCurrentEquuipped.Object,true)  
                    DoNotPlaceAnyBlock = false            
                end           
               
                --BedwarLibrary.BlockEngineClientEvents.DamageBlock:fire(block.Name, pos, block) 
            end)


        end,
        {
            [1] = {
                DisplayText = "It will just quick hotkey for you so dw",
                ConfigType = "Label",
                Callback = function()
                    
                end,
                Value = false
            },
            [2] = {
                DisplayText = "Keep watching for ground",
                ConfigType = "Toggle",
                Callback = function()
                    
                end,
                Value = false
            }
        }
    )
end


----------// Chest Stealer i think
do

    local ChestStealerConnection = nil
    local cheststealerdelays = {}


    function ChestGrab()

        local GetChestDelayProperty = shared.IClientToggledProperty["Chest"]["Grab Delay"]

        if BedwarLibrary.AppController:isAppOpen("ChestApp") then
            local chest = LocalPlayer.Character:FindFirstChild("ObservedChestFolder")
            local chestitems = chest and chest.Value and chest.Value:GetChildren() or {}
            --print(chest.Value.Name)
            if shared.IClientToggledProperty["Chest"]["Skywars Only?"] == true then
                if BedwarLibrary.ClientStoreHandler:getState().Game.queueType:find("skywars") then
                    
                else
                    return
                end
            end
          
            if shared.IClientToggledProperty["Chest"]["Ignore Personal Chest"] == true then
                if  chest.Value.Name == LocalPlayer.Name.."_personal" then
                    return
                end
            end

            if #chestitems > 0 then
                for i3,v3 in pairs(chestitems) do
                    if v3:IsA("Accessory") then
                        if (cheststealerdelays[v3] == nil ) then
                            cheststealerdelays[v3] = tick() + (GetChestDelayProperty/100)
                            or cheststealerdelays[v3] < tick()
                        else
                            if tick() > cheststealerdelays[v3] then
                                BedwarLibrary.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(chest.Value, v3)
                            end
                        end

                        --task.wait(GetChestDelayProperty / 100)
                    end
                end
            end
        end
    end

    UtilityTab:newmod(
        {ModName = "Chest", ModDescription = "Hate to manually click?? passionfruit got u covered!",Keybind= "None"},
        function(args)
           
            if args == true then

                ChestStealerConnection = RunService.Heartbeat:Connect(function()
                    ChestGrab()
                end)

            else
                if ChestStealerConnection then
                    ChestStealerConnection:Disconnect()
                    ChestStealerConnection = nil
                end
            end

        end,
        {
            [1] = {
                DisplayText = "Grab Delay is percentage of 1 second ex 100% is 1 seconds 0% is no delay",
                ConfigType = "Label",
                Callback = function()
                    
                end,
                Value = false
            },

            [2] = {
                DisplayText = "Grab Delay",
                ConfigType = "Slider",
                Callback = function(Value)
                end,
                Default = 100,
                Min = 0,
                Max = 100,
            },

            [3] = {
                DisplayText = "Skywars Only?",
                ConfigType = "Toggle",
                Callback = function()
                    
                end,
                Value = false,
            },
            [4] = {
                DisplayText = "Ignore Personal Chest",
                ConfigType = "Toggle",
                Callback = function()
                    
                end,
                Value = false,
            }
        }
    )
end


----------// Auto banner
do
    PlaceBlockEngine = BedwarLibrary.BlockPlacer.new(BedwarLibrary.BlockEngine, "defense_banner")

    local FlagList = {[1] = "damage_banner",[2] = "heal_banner",[3] ="defense_banner"}

    local function RoudUpPosition(Position)
        return Vector3.new(math.floor((Position.X / 3) + 0.5) * 3, math.floor((Position.Y / 3) + 0.5) * 3, math.floor((Position.Z / 3) + 0.5) * 3) 
    end

    local function GetrandomPosition()

        local CurrentPlayerHrootSize = game.Players.LocalPlayer.Character.HumanoidRootPart.Size
        local CurrentHumanoid = game.Players.LocalPlayer.Character.Humanoid
        local CurrentPlayerCframe = ( game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3))
        local RandomCFrame = CurrentPlayerCframe * CFrame.new(math.random(-1,1) * 3, 0, math.random(-2,0) * 3)
        local CalculatedPosition = Vector3.new(RandomCFrame.Position.X, RoudUpPosition(Vector3.new(0, RandomCFrame.Position.Y - (((CurrentPlayerHrootSize.Y / 2) + CurrentHumanoid.HipHeight) - 1.5), 0)).Y, RandomCFrame.Position.Z)
        local RoundedUp = RoudUpPosition(CalculatedPosition)

        local block, blockpos = getPlacedBlock(RoundedUp)
        --print(block, blockpos)
        if block then
            GetrandomPosition()
        else
            return RoundedUp
        end
        
    end

    function placeflag ()

        local PlacedFlag = {}
        
        local GetCurrentEquuipped = getEquipped()

        DoNotPlaceAnyBlock = true
        for x = 0,2 do
            for z = 0,2 do

                for i , v in pairs (FlagList) do
                    if getItem(v) then

                        -- Calculating PLayer Position
                        local GetTheRandomPosition = GetrandomPosition()
                        if not PlacedFlag[v] then
                            PlacedFlag[v] = true
                            switchItem(getItem(v).tool,true)
                            PlaceBlockEngine.blockType = v
                            task.spawn(function()
                                PlaceBlockEngine:placeBlock(Vector3.new(GetTheRandomPosition.X / 3, GetTheRandomPosition.Y / 3, GetTheRandomPosition.Z  / 3))
                            end)
                            task.wait((1/10))
                            break
                        end
                        
                    end
                end

            end
        end
        switchItem(GetCurrentEquuipped.Object,true)
        DoNotPlaceAnyBlock = false
    end

    UtilityTab:newmod(
        {ModName = "Auto Banner", ModDescription = "idk if it actually working",Keybind= "None",BindOnly = true},
        function(args)
            if args == true then else return end
            if not isAlive() then return end

            placeflag()
        end,
        {
            [1] = {
                DisplayText = "It will just quick hotkey for you so dw",
                ConfigType = "Label",
                Callback = function()
                    
                end,
                Value = false
            },
        }
    )
end

--------------------------------------// Cosmetics Tab
----------// Nyx Sound Handler
do

    local Combo = 1
	local TheWorkspacetime = workspace:GetServerTimeNow()
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

----------// Very Boom Boom Sound Sound Handler
do
    local Combo = 1
	local TheWorkspacetime = workspace:GetServerTimeNow()
    CosmeticTab:newmod(
        {ModName = "Better Combat Sound Part 2", ModDescription = "You will feel so satisfied when fighting while turning this on",Keybind= "None"},
        function(args)
            if args then
                BedwarLibrary.SoundManager:registerSound("rbxassetid://3919693908",{volume = 1,TimePosition = 0.3 })
            end
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
            local IsThingToggled = shared.IClientToggledProperty["Better Combat Sound Part 2"]["Toggled"]
            if not IsThingToggled then return end
            BedwarLibrary.SoundManager:registerSound(BedwarLibrary["SoundList"]["DAMAGE_3"],{volume = 0 })
            local Hello = BedwarLibrary.SoundManager:playSound("rbxassetid://3919693908")
            Hello.TimePosition = 0.4
        else
            BedwarLibrary.SoundManager:registerSound(BedwarLibrary["SoundList"]["DAMAGE_3"],{volume = 1})
        end
    
    end)

end

----------// Very Ouchie Sound Handler
do
    local OldTNTSound,OldFireballSound
  
    CosmeticTab:newmod(
        {ModName = "Micheal bay", ModDescription = "You will feel so satisfied when fighting while turning this on",Keybind= "None"},
        function(args)
            if args then
                OldTNTSound = BedwarLibrary["SoundList"]["TNT_EXPLODE_1"]
                OldFireballSound = BedwarLibrary["SoundList"]["FIREBALL_EXPLODE"]
                BedwarLibrary["SoundList"]["TNT_EXPLODE_1"] = "rbxassetid://3995434918"
                BedwarLibrary["SoundList"]["FIREBALL_EXPLODE"] = "rbxassetid://3995434918"
                --BedwarLibrary.SoundManager:registerSound("rbxassetid://3919693908",{volume = 1,TimePosition = 0.3 })
            else
                if OldTNTSound then
                    BedwarLibrary["SoundList"]["TNT_EXPLODE_1"] = OldTNTSound
                end
                if OldFireballSound then
                    BedwarLibrary["SoundList"]["FIREBALL_EXPLODE"] = OldFireballSound
                end
            end
        end,
        {
        }
    )
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



----------// I Wanna sleep
do

    CosmeticTab:newmod(
        {ModName = "IWannaSleep", ModDescription = "Imma Sleep GN",Keybind= "None"},
        function(args)
        
        end,
        {
            [1] = {
                DisplayText = "Random Color",
                ConfigType = "Toggle",
                Callback = function()
                    
                end,
                Value = false
            },
            [2] = {
                DisplayText = "Color Settings (THIS IS RGB so find your color in google)",
                ConfigType = "Label",
                Callback = function()
                    
                end,
                Value = false
            },
            [3] = {
                DisplayText = "Red",
                ConfigType = "Slider",
                Callback = function(Value)
                end,
                Default = 0,
                Min = 0,
                Max = 255,
            },
            [4] = {
                DisplayText = "Green",
                ConfigType = "Slider",
                Callback = function(Value)
                end,
                Default = 0,
                Min = 0,
                Max = 255,
            },
            [5] = {
                DisplayText = "Blue",
                ConfigType = "Slider",
                Callback = function(Value)
                end,
                Default = 0,
                Min = 0,
                Max = 255,
            }
        }
    )

    BedwarLibrary["ClientHandler"]:OnEvent("EntityDamageEvent", function(p3)
        local IsThingToggled = shared.IClientToggledProperty["IWannaSleep"]["Toggled"]
        if not IsThingToggled then return end
        if p3.entityInstance:FindFirstChild("_DamageHighlight_") then else return end
        if (p3.fromEntity == LocalPlayer.Character) then
            if shared.IClientToggledProperty["IWannaSleep"]["Random Color"] == true then
                p3.entityInstance:FindFirstChild("_DamageHighlight_").FillColor = Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))
            else
                local R,G,B = shared.IClientToggledProperty["IWannaSleep"]["Red"],shared.IClientToggledProperty["IWannaSleep"]["Green"],shared.IClientToggledProperty["IWannaSleep"]["Blue"]
                p3.entityInstance:FindFirstChild("_DamageHighlight_").FillColor = Color3.fromRGB(R,G,B)
            end
        else
            p3.entityInstance:FindFirstChild("_DamageHighlight_").FillColor = Color3.FromRGB(255,0,0)
        end
    
    end)

end

do
    local oldemote

    local SetEmoteName = {}
    local SetEmoteName2 = {}
	for i,v in pairs(BedwarLibrary.EmoteMeta) do 
		table.insert(SetEmoteName, v.name)
		SetEmoteName2[v.name] = i
	end
	table.sort(SetEmoteName, function(a, b) return a:lower() < b:lower() end)

    CosmeticTab:newmod(
        {ModName = "Emote Adjuster", ModDescription = "Im Sleepy Joe",Keybind= "None"},
        function(args)
            if args == true then
                if not ( shared.IClientToggledProperty["Emote Adjuster"]["Selected Emote"] == "")  then
                    task.spawn(function()
                        repeat
                            task.wait()
                        until BedwarLibrary.ClientStoreHandler:getState() --and not (BedwarLibrary.ClientStoreHandler:getState().Game.matchState == 0 )
                        oldemote = BedwarLibrary.ClientStoreHandler:getState().Locker.selectedSpray
                        BedwarLibrary.ClientStoreHandler:getState().Locker.selectedSpray = SetEmoteName2[shared.IClientToggledProperty["Emote Adjuster"]["Selected Emote"]]
                    end)
                   
                end
            else
                if oldemote then
                    BedwarLibrary.ClientStoreHandler:getState().Locker.selectedSpray = oldemote
                end
            end
        end,
        {
            [1] = {
                DisplayText = "Selected Emote",
                ConfigType = "DropDown",
                List = SetEmoteName,
                Value = "",
                Callback = function(Value)

                    local IsThingToggled = shared.IClientToggledProperty["Emote Adjuster"]["Toggled"]
                    if IsThingToggled then
                        --LocalPlayer:SetAttribute("KillEffectType", KillEffectName[Value])
                        oldemote = BedwarLibrary.ClientStoreHandler:getState().Locker.selectedSpray
                        BedwarLibrary.ClientStoreHandler:getState().Locker.selectedSpray = SetEmoteName2[Value]
                        --shared.IClientToggledProperty["Emote Adjuster"]["SavedEmote"] = Value
                    end
                end
            }
        }
    )

end

----------// Fake Lag handler
do

    local TheConnection
    local LagToWhatTime = tick()
    local TimeToStartFakeLag = tick()
    local FirstTimeLagging = galse
    local IsLagging = false
    BlantantTab:newmod(
        {ModName = "Fake Lag", ModDescription = "Uhm idk",Keybind= "None"},
        function(args)
            if args == true then
                TheConnection = RunService.Heartbeat:Connect(function()
                    local IsStillFakeLag = shared.IClientToggledProperty["Fake Lag"]["still do fake lag but not that much when not near player"]
                    local Radius = shared.IClientToggledProperty["Fake Lag"]["Player Radius"]
                    local NearPlayerOnly = shared.IClientToggledProperty["Fake Lag"]["Near Player Only?"]
                    local IsNear = false

                    if  NearPlayerOnly then

                        for i , v in pairs(Players:GetPlayers()) do
                            if v == LocalPlayer then
                            else
                                if v.TeamColor == LocalPlayer.TeamColor then
                                else
                                    if v and v.Character and v.Character.PrimaryPart and (v.Character.PrimaryPart.Position -LocalPlayer.Character.PrimaryPart.Position).Magnitude < Radius then
                                        IsNear = true
                                    end
                                end
                            end
                        end
                        if IsNear == false then 
                            if not IsStillFakeLag then
                                FirstTimeLagging = false 
                                game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge) 
                                return 
                            end
                        end
                    end

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
                        LagToWhatTime = tick() +  (shared.IClientToggledProperty["Fake Lag"]["Spoof Time"]/100) * (NearPlayerOnly and IsNear == false and IsStillFakeLag and 0.5 or 1)
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
        [4] = {
            DisplayText = "Near Player Only?",
            ConfigType = "Toggle",
            Callback = function()
            end,
            Value = false,
        },
        [4] = {
            DisplayText = "still do fake lag but not that much when not near player",
            ConfigType = "Toggle",
            Callback = function()
            end,
            Value = false,
        },
        [6] = {
            DisplayText = "The Radius is stud btw",
            ConfigType = "Label",
        },
        [7] = {
            DisplayText = "Player Radius",
            ConfigType = "Slider",
            Callback = function()
                
            end,
            Default = 16,
            Min = 8,
            Max = 32,
        }
        }
    )

    local mt = getrawmetatable(game)
    local backup = mt.__namecall
    if setreadonly then setreadonly(mt, false) else make_writeable(mt, true) end

    mt.__namecall = newcclosure(function(...)
        local method = getnamecallmethod()
        local args = {...}
        pcall(function()
        if (method == "FireServer" or method == "InvokeServer") and args[2] and args[2].chargedAttack and args[2].weapon then
            TimeToStartFakeLag = tick() + 0.075
            LagToWhatTime = tick()
            game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
            end
        end)
        return backup(...)
    end)

    --[[
    BedwarLibrary["ClientHandler"]:OnEvent("EntityDamageEvent", function(p3)
        local IsThingToggled = shared.IClientToggledProperty["Fake Lag"]["Toggled"]
        if not IsThingToggled then return end

        if (p3.fromEntity == LocalPlayer.Character) then
           
           
            TimeToStartFakeLag = tick() + 0.5
            LagToWhatTime = tick()

        elseif p3.entityInstance == LocalPlayer.Character then 

          
        
        end
    
    end)]]

end
