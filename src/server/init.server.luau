--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(shared:WaitForChild("Types"))

local ServerScriptService = game:GetService("ServerScriptService")
local Server = ServerScriptService:WaitForChild("Server")
local PlayerSlotService = require(Server:WaitForChild("PlayerSlotService"))
local PlayerDataService = require(Server:WaitForChild("PlayerDataService"))
local Players = game:GetService("Players")

function DeleteAllPlayerData(player: Player)
	local PlayerSlotData = PlayerSlotService.GetPlayerSaveSlots(player)
	if PlayerSlotData == nil then
		return
	end
	for characterName, characterData in pairs(PlayerSlotData.SaveMetaData) do
		PlayerDataService.DeleteSlotData(player, characterName)
		PlayerSlotService.DeletePlayerSaveSlots(player, characterName)
	end
end

-- while true do
-- 	for _, player in ipairs(Players:GetPlayers()) do
-- 		DeleteAllPlayerData(player)
-- 	end
-- 	task.wait(5)
-- end
