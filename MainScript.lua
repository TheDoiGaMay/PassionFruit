
--// Wait Until game is loaded
repeat
	task.wait()
until game:IsLoaded() == true

--// Main Service
local Players = game:GetService("Players")

--// Varibles
local LocalPlayer = Players.LocalPlayer
local MainFileDirectory = "IClientRework"
local MainCodeDirectory = "IClientReworkCode"
local MainFileWebsiteDirectory = "PassionFruit"

local PlaceSaveId = {
	--// Bedwars
	[8444591321] = 6872274481,
	[8560631822] = 6872274481,
}


repeat
	task.wait(1)
until LocalPlayer.Character ~= nil
local Character = LocalPlayer.Character or LocalPlayer.Character.CharacterAdded:Wait()

--// Functions

local function IsBetterFile(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil
end


function LoadFileFromRepos(scripturl,strike)
	local strike = strike or 1
	if shared.PassionFruitDev then
		if not IsBetterFile(MainCodeDirectory.. "/" .. scripturl) then
			warn("File not found : "..MainCodeDirectory.."/" .. scripturl)
			return
		end
		return readfile(MainCodeDirectory .. "/" .. scripturl)
	else
		local suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/randomdude11135/".. MainFileWebsiteDirectory.. "/master/".. scripturl, true) end)
		if not suc or res == "404: Not Found" then
			strike += 1
			warn("File not found, Strike: " .. strike .. ", Path: " .. scripturl)

			task.wait(1)
			if strike >= 4 then
				return nil
			else
				local Yes = LoadFileFromRepos(scripturl,strike)
				return Yes
			end
		else
			return res
		end
	end
end

local getasset = getsynasset or getcustomasset or function(location)
	return "rbxasset://" .. location
end

local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function(tab)
	if tab.Method == "GET" then
		return {
			Body = game:HttpGet(tab.Url, true),
			Headers = {},
			StatusCode = 200,
		}
	else
		return {
			Body = "bad exploit",
			Headers = {},
			StatusCode = 404,
		}
	end
end
local delfile = delfile or function(file) writefile(file, "") end

local GuiLibrary = loadstring(LoadFileFromRepos("GuiLibrary.lua"))()

--// Check if script is supported
if not (getasset and requestfunc and queueteleport) then
	return
end

--// Check if already excuted
if shared[MainFileWebsiteDirectory.. "AlreadyExecuted"] then
	return
else
	shared[MainFileWebsiteDirectory.. "AlreadyExecuted"] = true
end

local PlaceId = PlaceSaveId[game.PlaceId] or game.PlaceId
if PlaceSaveId[game.PlaceId] then
	print("using custom place id as data")
end

--// Create Folder
if isfolder(MainFileDirectory) == false then
	makefolder(MainFileDirectory)
end

if isfolder(MainFileDirectory.."/Settings") == false then
	makefolder(MainFileDirectory.."/Settings")
end

if isfolder(MainFileDirectory.."/Settings/" .. PlaceId) == false then
	makefolder(MainFileDirectory.."/Settings/" .. PlaceId)
end

if isfolder(MainFileDirectory.."/SettingsSelecting") == false then
	makefolder(MainFileDirectory.."/SettingsSelecting")
end

local success2, result2 = pcall(function()
	return readfile(MainFileDirectory.."/SettingsSelecting/" .. PlaceId .. ".txt")
end)

if not success2 or not result2 then
	writefile(MainFileDirectory.."/SettingsSelecting/" .. PlaceId .. ".txt", "MainSetting")
end



--// Set Shared Info
shared.IClientToggledProperty = {}
shared.PassionFruitMainGui = nil

-------// Read Their Settings

local GetSelectConfig = readfile(MainFileDirectory.."/SettingsSelecting/" ..PlaceId .. ".txt")

local success2, result2 = pcall(function()
	return game:GetService("HttpService"):JSONDecode(readfile(MainFileDirectory .. "/Settings/" .. PlaceId .. "/"..GetSelectConfig .. ".txt"))
end)

if success2 and result2 then
	for i, v in pairs(result2) do
		shared.IClientToggledProperty[i] = v
	end
else
    writefile(MainFileDirectory .. "/Settings/" .. PlaceId .. "/"..GetSelectConfig .. ".txt", game:GetService("HttpService"):JSONEncode(shared.IClientToggledProperty))
end


LocalPlayer.OnTeleport:Connect(function(State)

	local GetSelectConfig = readfile(MainFileDirectory.."/SettingsSelecting/" ..PlaceId .. ".txt")
	print("Passion: Saving " .. GetSelectConfig .. "'s Config")
	writefile(MainFileDirectory .. "/Settings/" .. PlaceId .. "/"..GetSelectConfig .. ".txt", game:GetService("HttpService"):JSONEncode(shared.IClientToggledProperty))

	local teleportScript = [[
		loadstring(game:HttpGet("https://raw.githubusercontent.com/randomdude11135/PassionFruit/master/MainScript.lua", true))()
	]]
	
	if shared.PassionFruitDev then 
		teleportScript = "shared.PassionFruitDev = true; "..teleportScript
	end
	
	queueteleport(teleportScript)
end)

-------// Load UI
local CreateNewWindow = GuiLibrary:new()
shared.PassionFruitMainGui = CreateNewWindow


-------// Load Universal Game Module
loadstring(LoadFileFromRepos("GameModules/Universal.lua"))()

-------// Load Load Specific Game Module
repeat
	task.wait()
until game.PlaceId
loadstring(LoadFileFromRepos("GameModules/" .. game.PlaceId .. ".Lua"))()


