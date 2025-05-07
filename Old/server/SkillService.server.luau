local Players = game:GetService("Players")
local DataStore = game:GetService("DataStoreService"):GetDataStore("PlayerStats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteShowUI = ReplicatedStorage:WaitForChild("ShowSaveSlots")
local remoteSelectSlot = ReplicatedStorage:WaitForChild("SelectSaveSlot")

local StatService = require(script.Parent:WaitForChild("StatService"))

-- Attaches Scripts To Player
local StatsManager = require(script.Parent:WaitForChild("StatsManager"))

local validClasses = {
	["Knight"] = true,
	["Mage"] = true,
	["Ranger"] = true,
	["Rogue"] = true,
	["Preist"] = true,
}

-- Get all 3 save slots for a player
local function getAllSaves(userId)
	local data = {}
	for i = 1, 3 do
		local key = "User_" .. userId .. "_Slot_" .. i
		local success, slotData = pcall(function()
			return DataStore:GetAsync(key)
		end)

		if success then
			-- Normalize for frontend
			local slotInfo = slotData or nil
			if slotInfo then
				data[i] = {
					class = slotInfo.Class or "[Unknown]",
					level = slotInfo.Level or 0,
				}
			else
				data[i] = nil
			end
		else
			warn("Failed to read save slot", i, "for user", userId)
			data[i] = nil
		end
	end
	return data
end

-- When player joins, send slot data to client
Players.PlayerAdded:Connect(function(player)
	local userId = player.UserId
	local saveSlots = getAllSaves(userId)
	print("Sending slot data to client for", player.Name, ":", saveSlots)
	remoteShowUI:FireClient(player, saveSlots)
end)

-- When player selects a slot
remoteSelectSlot.OnServerEvent:Connect(function(player, slotNumber, class)
	local key = "User_" .. player.UserId .. "_Slot_" .. slotNumber

	-- Check if save exists
	local success, data = pcall(function()
		return DataStore:GetAsync(key)
	end)

	if success and not data then
		-- Creating a new save (must have class)
		if class then
			StatService:CreateNewSave(player, slotNumber, class)
		else
			warn("Client attempted to create save without specifying a class.")
		end
	else
		-- Load existing save
		StatService:LoadStats(player, slotNumber)
	end
end)

local DeleteSaveSlot = ReplicatedStorage:WaitForChild("DeleteSaveSlot")

DeleteSaveSlot.OnServerEvent:Connect(function(player, slotNumber)
	local success = StatService:DeleteSave(player, slotNumber)

	if success then
		local userId = player.UserId
		local saveSlots = getAllSaves(userId)
		remoteShowUI:FireClient(player, saveSlots)
	end
end)

Players.PlayerAdded:Connect(function(player)
	-- Example: Start health and mana regeneration loops
	player:WaitForChild("Stats")

	spawn(function()
		while player.Parent do
			StatsManager.HealthRegen(player)
			StatsManager.ManaRegen(player)
			wait(1) -- Adjust the wait time as needed
		end
	end)
end)
