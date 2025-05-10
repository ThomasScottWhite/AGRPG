local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("Shared")

local PlayerDataTemplate = require(shared:WaitForChild("DBTemplates"):WaitForChild("PlayerData"))

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Server = ServerScriptService:WaitForChild("Server")

local Players = game:GetService("Players")
local ProfileStore = require(Server:WaitForChild("ProfileStore"))

local DATA_STORE_KEY = "PlayerDataService"
if RunService:IsStudio() then
	DATA_STORE_KEY = "PlayerDataServiceTest"
end

local SelectSaveSlot = ReplicatedStorage:WaitForChild("SelectSaveSlot")
local PlayerStore = ProfileStore.New(DATA_STORE_KEY, PlayerDataTemplate.DEFAULT_PLAYER_DATA)
local PlayerData: { [Player]: typeof(PlayerStore:StartSessionAsync()) } = {}
local Local = {}
local Shared = {}

function Shared.LoadPlayerSlot(player: Player, CharacterName: string)
	local profile = PlayerStore:StartSessionAsync(player.Name .. CharacterName, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile == nil then
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile.OnSessionEnd:Connect(function()
		PlayerData[player] = nil
		player:Kick("Profile Session Ended")
	end)

	local isInGame = player.Parent == Players
	if isInGame then
		PlayerData[player] = profile
	else
		profile:EndSession()
	end
end

function Shared.GetPlayerData(player: Player): PlayerDataTemplate.PlayerData
	local profile = PlayerData[player]
	if profile == nil then
		return
	end
	return profile.Data
end

function Shared.CreateNewCharacter(player: Player, class: string, CharacterName: string)
	local profile = PlayerStore:StartSessionAsync(player.Name .. CharacterName, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})
	if profile.Data.CharacterName ~= "" then
		return
	end
	profile:AddUserId(player.UserId)

	profile.Data = PlayerDataTemplate.CreateNewSaveData(CharacterName, class)
	profile:Reconcile()
	profile:Save()

	PlayerData[player] = profile
end

function Shared.UpdatePlayerEquipment(player: Player, CharacterName: string, Item, slot: string)
	local profile = PlayerData[player]
	if profile == nil then
		return
	end
	profile.Data.Equipment = Equipment
	profile:Reconcile()
	profile:Save()
end

function Shared.DeleteSlotData(player: Player, CharacterName: string)
	print(
		"PlayerDataService: Deleting player save slot for " .. player.Name .. " with character name " .. CharacterName
	)
	local Data = PlayerStore:GetAsync(player.Name .. CharacterName)
	if Data == nil then
		print("PlayerDataService: No player data found for " .. player.Name .. " with character name " .. CharacterName)
		return
	end
	PlayerStore:RemoveAsync(player.Name .. CharacterName)
end

return Shared
