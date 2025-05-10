local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("Shared")

local PlayerDataTemplate = require(shared:WaitForChild("DBTemplates"):WaitForChild("PlayerData"))

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Server = ServerScriptService:WaitForChild("Server")

local Players = game:GetService("Players")
local ProfileStore = require(Server:WaitForChild("ProfileStore"))

local DATA_STORE_KEY = "PlayerSlotService"
if RunService:IsStudio() then
	DATA_STORE_KEY = "PlayerSlotServiceTest"
end
local Local = {}
local Shared = {}

local PlayerStore = ProfileStore.New(DATA_STORE_KEY, PlayerDataTemplate.DEFAULT_SAVE_SLOTS)
local SaveSlotProfiles: { [Player]: typeof(PlayerStore:StartSessionAsync()) } = {}

local CreateNewCharacterReturn = ReplicatedStorage:WaitForChild("CreateNewCharacterReturn")
function Local.OnStart()
	-- Load all player save slots when they join

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Parent == Players then
			task.spawn(Local.LoadPlayerSaveSlots(player))
		end
	end
	Players.PlayerAdded:Connect(function(player: Player)
		if player.Parent == Players then
			Local.LoadPlayerSaveSlots(player)
		end
	end)

	-- Load all player save slots when they respawn
	Players.PlayerRemoving:Connect(function(player: Player)
		Local.RemovePlayerSaveSlots(player)
	end)
end

function Local.LoadPlayerSaveSlots(player: Player)
	local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
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
		SaveSlotProfiles[player] = nil
		player:Kick("Profile Session Ended")
	end)

	local isInGame = player.Parent == Players
	if isInGame then
		SaveSlotProfiles[player] = profile
	else
		profile:EndSession()
	end
end

function Local.RemovePlayerSaveSlots(player: Player)
	local profile = SaveSlotProfiles[player]
	if profile then
		profile:EndSession()
		SaveSlotProfiles[player] = nil
	end
end

function Shared.DeletePlayerSaveSlots(player: Player, CharacterName: string)
	local profile = SaveSlotProfiles[player]
	print(
		"PlayerSlotService: Deleting player save slot for " .. player.Name .. " with character name " .. CharacterName
	)
	profile.Data.SaveMetaData[CharacterName] = nil
	profile.Data.LastUsedSave = nil
end

function Shared.GetPlayerSaveSlots(player: Player): PlayerDataTemplate.PlayerSaves?
	local profile = SaveSlotProfiles[player]
	if profile then
		return profile.Data
	else
		return nil
	end
end

function Shared.CreateNewCharacter(player: Player, class: string, characterName: string)
	local profile = SaveSlotProfiles[player]
	if not profile then
		return
	end

	if profile.Data.SaveMetaData[characterName] then
		CreateNewCharacterReturn:FireClient(player, "Character name already exists")
		return
	end

	profile.Data.SaveMetaData[characterName] = {
		CharacterName = characterName,
		DataKey = player.Name .. characterName,
		Class = class,
		Level = 1,
		Experience = 0,
	}
	profile.Data.LastUsedSave = characterName

	profile:Save()

	CreateNewCharacterReturn:FireClient(player, "Character created successfully")
end
Local.OnStart()
return Shared
