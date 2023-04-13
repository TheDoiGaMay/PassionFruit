
--// Game Mega
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local checkpublicreponum = 0
local checkpublicrepo

--// Synapse X Functions
function IsBetterFile(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil
end

local MainFileDirectory = "IClientRework"
local MainCodeDirectory = "IClientReworkCode"
local MainFileWebsiteDirectory = "PassionFruit"

local function LoadFileFromRepos(scripturl)
	print( shared.PassionFruitDev)
	if shared.PassionFruitDev then
		if not IsBetterFile(MainCodeDirectory.. "/" .. scripturl) then
			warn("File not found : "..MainCodeDirectory.."/" .. scripturl)
			return
		end
		return readfile(MainCodeDirectory .. "/" .. scripturl)
	else
		local res = game:HttpGet("https://raw.githubusercontent.com/randomdude11135/".. MainFileWebsiteDirectory.. "/master/".. scripturl, true)
		return res
	end
end

for i = 1,5 do
local publicrepo = LoadFileFromRepos("GameModules/6872274481.lua")
if publicrepo then
	loadstring(publicrepo)()
	break
else
	task.wait(1)
end
end