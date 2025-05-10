--!nocheck
local SelectCharacterFolder = script.Parent

local Player = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShowSaveSlots: RemoteEvent = ReplicatedStorage:WaitForChild("ShowSaveSlots")

local gui: ScreenGui = Player:WaitForChild("PlayerGui"):WaitForChild("SelectCharacterUI")
local RootFrame = gui:WaitForChild("RootFrame")
local CreateNewCharacterButton: TextButton = RootFrame:WaitForChild("CreateNewCharacterButton")
local CharacterList: ScrollingFrame = RootFrame:WaitForChild("CharacterListFrame")

local createNewCharacterFrame = gui:WaitForChild("CreateNewCharacterFrame")

local CharacterSlotButtons: { TextButton } = {
	createNewCharacterFrame:WaitForChild("Knight"),
	createNewCharacterFrame:WaitForChild("Mage"),
	createNewCharacterFrame:WaitForChild("Ranger"),
	createNewCharacterFrame:WaitForChild("Rogue"),
	createNewCharacterFrame:WaitForChild("Preist"),
}
local CharacterNameTextBox: TextBox = createNewCharacterFrame:WaitForChild("CharacterNameTextBox")

local PlayerDataTemplate =
	require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DBTemplates"):WaitForChild("PlayerData"))

local function ShowMakeNewCharacterPanel()
	createNewCharacterFrame.Visible = true
	RootFrame.Visible = false
end

ShowSaveSlots.OnClientEvent:Connect(function(SaveSlotData: PlayerDataTemplate.PlayerSaves)
	gui.Enabled = true
	RootFrame.Visible = true

	if SaveSlotData == nil then
		print("No save slot data found")
		ShowMakeNewCharacterPanel()
		return
	end

	if SaveSlotData.SaveMetaData ~= nil then
		for _, character in pairs(SaveSlotData.SaveMetaData) do
			local characterButton = Instance.new("TextButton")
			characterButton.Size = UDim2.new(1, 0, 0, 50)
			characterButton.Text = character.CharacterName
			characterButton.Parent = CharacterList

			characterButton.MouseButton1Click:Connect(function()
				game.ReplicatedStorage.SelectSaveSlot:FireServer(character.CharacterName, character.DataKey)
				gui.Enabled = false
			end)
		end
	end
end)

CreateNewCharacterButton.MouseButton1Click:Connect(function()
	ShowMakeNewCharacterPanel()
end)

for _, button in ipairs(CharacterSlotButtons) do
	print(button.Name)
	button.MouseButton1Click:Connect(function()
		local class = button.Name
		local characterName = CharacterNameTextBox.Text
		if characterName == "" then
			print("Character name cannot be empty")
			return
		end
		print("Class: ", class)
		game.ReplicatedStorage.CreateNewCharacter:FireServer(class, characterName)
		gui.Enabled = false
	end)
end
