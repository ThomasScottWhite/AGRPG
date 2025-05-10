local ServerScriptService = game:GetService("ServerScriptService")
local PlayerSlotService = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerSlotService"))
local PlayerDataService = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerDataService"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShowSaveSlots = ReplicatedStorage:WaitForChild("ShowSaveSlots")
local createNewCharacter = ReplicatedStorage:WaitForChild("CreateNewCharacter")
local SelectSaveSlot = ReplicatedStorage:WaitForChild("SelectSaveSlot")

game.Players.PlayerAdded:Connect(function(player: Player)
	task.wait(1)
	local SlotData = PlayerSlotService.GetPlayerSaveSlots(player)
	ShowSaveSlots:FireClient(player, SlotData)
end)

createNewCharacter.OnServerEvent:Connect(function(player: Player, class: string, characterName: string)
	PlayerSlotService.CreateNewCharacter(player, class, characterName)
	PlayerDataService.CreateNewCharacter(player, class, characterName)
end)

SelectSaveSlot.OnServerEvent:Connect(function(player, CharacterNameInput)
	local PlayerSlotData = PlayerSlotService.GetPlayerSaveSlots(player)
	for characterName, characterData in pairs(PlayerSlotData.SaveMetaData) do
		if characterName == CharacterNameInput then
			LoadPlayerSlot(player, characterName, characterData)
			break
		end
	end
end)

function LoadPlayerSlot(player: Player, characterName: string, characterDataKey: string)
	PlayerDataService.LoadPlayerSlot(player, characterName)
	local GetPlayerData: table = PlayerDataService.GetPlayerData(player)
	if GetPlayerData == nil then
		return
	end

	local CharacterData = player:FindFirstChild("CharacterData")
	if CharacterData then
		CharacterData:Destroy()
	end
	CharacterData = Instance.new("Folder")
	CharacterData.Name = "CharacterData"
	CharacterData.Parent = player

	for statName, statValue in pairs(GetPlayerData) do
		if type(statValue) == "table" then
			continue
		end
		if type(statValue) == "string" then
			local stat = Instance.new("StringValue")
			stat.Name = statName
			stat.Value = statValue
			stat.Parent = CharacterData
			continue
		elseif type(statValue) == "number" then
			local stat = Instance.new("NumberValue")
			stat.Name = statName
			stat.Value = statValue
			stat.Parent = CharacterData
			continue
		end
	end
end

function PopulateStatsFolder(player, playerData)
	local statsFolder = player:FindFirstChild("Stats")
	if statsFolder then
		statsFolder:Destroy()
	end
	statsFolder = Instance.new("Folder")
	statsFolder.Name = "Stats"
	statsFolder.Parent = player

	for statName, statValue in pairs(playerData) do
		local stat = Instance.new("IntValue")
		stat.Name = statName
		stat.Value = statValue
		stat.Parent = statsFolder
	end
end
