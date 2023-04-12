
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


local function LoadFileFromRepos(scripturl)
	if shared.IClientDev then
		if not IsBetterFile(MainCodeDirectory.. "/" .. scripturl) then
			warn("File not found : "..MainCodeDirectory.."/" .. scripturl)
			return
		end
		return readfile(MainCodeDirectory .. "/" .. scripturl)
	else
		local res = game:HttpGet("https://raw.githubusercontent.com/randomdude11135/".. MainFileWebsiteDirectory .."/master/" .. scripturl, true)
		assert(res ~= "404: Not Found", "File not found")
		return res
	end
end

local getasset = getsynasset or getcustomasset or function(location)
	return "rbxasset://" .. location
end

local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport or function() end
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

--// Create Folder
if isfolder(MainFileDirectory) == false then
	makefolder(MainFileDirectory)
end

if isfolder(MainFileDirectory.."/Settings") == false then
	makefolder(MainFileDirectory.."/Settings")
end

if isfolder(MainFileDirectory.."/Settings/" .. game.PlaceId) == false then
	makefolder(MainFileDirectory.."/Settings/" .. game.PlaceId)
end

if isfolder(MainFileDirectory.."/SettingsSelecting") == false then
	makefolder(MainFileDirectory.."/SettingsSelecting")
end

local success2, result2 = pcall(function()
	return readfile(MainFileDirectory.."/SettingsSelecting/" .. game.PlaceId .. ".txt")
end)

if not success2 or not result2 then
	writefile(MainFileDirectory.."/SettingsSelecting/" .. game.PlaceId .. ".txt", "MainSetting")
end

--// Set Shared Info
shared.IClientToggledProperty = {}
shared.MainGui = nil

-------// Read Their Settings
local PlaceId = game.PlaceId
local GetSelectConfig = readfile(MainFileDirectory.."/SettingsSelecting/" ..PlaceId .. ".txt")

local success2, result2 = pcall(function()
	return game:GetService("HttpService"):JSONDecode(
        readfile(MainFileDirectory .. "/Settings/" .. game.PlaceId .. "/"..GetSelectConfig .. "/.txt"))
end)

if success2 and result2 then
	for i, v in pairs(result2) do
		shared.IClientToggledProperty[i] = v
	end
else
    writefile(MainFileDirectory .. "/Settings/" .. game.PlaceId .. "/"..GetSelectConfig .. "/.txt", game:GetService("HttpService"):JSONEncode(shared.IClientToggledProperty))
end


-------// Load UI
local CreateNewWindow = GuiLibrary:new()
shared.MainGui = CreateNewWindow


-------// Load Universal Game Module
loadstring(LoadFileFromRepos("GameModules/Universal.Lua"))()

-------// Load Load Specific Game Module
loadstring(LoadFileFromRepos("GameModules/" .. game.PlaceId .. ".lua"))()


