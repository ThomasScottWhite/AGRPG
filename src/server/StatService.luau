local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CalculateStats = require(ReplicatedStorage.Stats.CalculateStats)

local StatsService = {}

local dataStore = DataStoreService:GetDataStore("PlayerStats")

StatsService.Defaults = {
	Level = 1,
	Experience = 0,
	Class = "Knight",
	Gold = 0,
	CurrentMana = -42,

	Equipment = {
		Head = nil,
		Chest = nil,
		Boots = nil,
		Weapon = nil,
	},

	SkillTreeData = {
		Fireball = {
			Level = 1,
			SkillTree = {
				IncreasedExplosionRadius = { points = 1 },
			},
		},
	},

	SkillTreePoints = {
		IncreasedHealth = { points = 1 },
	},

	CurrentSkillBar = {
		Slot1 = "DefaultAttack",
		Slot2 = "Fireball",
		Slot3 = nil,
		Slot4 = nil,
		Slot5 = nil,
	},

	Buffs = {},
}

local function createStatInstance(name, value)
	local instance
	if typeof(value) == "number" then
		instance = Instance.new(math.floor(value) == value and "IntValue" or "NumberValue")
	elseif typeof(value) == "string" then
		instance = Instance.new("StringValue")
	else
		return nil
	end
	instance.Name = name
	instance.Value = value
	return instance
end

local function createModifierEntry(parentFolder, statName, value, modifierType, index)
	local statFolder = parentFolder:FindFirstChild(statName)
	if not statFolder then
		statFolder = Instance.new("Folder")
		statFolder.Name = statName
		statFolder.Parent = parentFolder
	end

	local modifierEntry = Instance.new("Folder")
	modifierEntry.Name = "Modifier" .. index
	modifierEntry.Parent = statFolder

	local valueInstance = createStatInstance("Value", value)
	if valueInstance then
		valueInstance.Parent = modifierEntry
	end

	local typeInstance = Instance.new("StringValue")
	typeInstance.Name = "Type"
	typeInstance.Value = modifierType
	typeInstance.Parent = modifierEntry
end

local function readMultiModifiers(folder)
	local output = {}

	for _, statFolder in ipairs(folder:GetChildren()) do
		if statFolder:IsA("Folder") then
			local statName = statFolder.Name
			output[statName] = {}

			for _, modFolder in ipairs(statFolder:GetChildren()) do
				local valueObj = modFolder:FindFirstChild("Value")
				local typeObj = modFolder:FindFirstChild("Type")
				if valueObj and typeObj then
					table.insert(output[statName], {
						value = valueObj.Value,
						type = typeObj.Value,
					})
				end
			end
		end
	end

	return output
end

function StatsService:LoadStats(player, slotNumber)
	local key = "User_" .. player.UserId .. "_Slot_" .. slotNumber

	local success, data = pcall(function()
		return dataStore:GetAsync(key)
	end)

	if not success or typeof(data) ~= "table" then
		data = {}
	end

	-- Fill in missing default values
	for stat, default in pairs(self.Defaults) do
		if data[stat] == nil then
			data[stat] = default
		end
	end

	-- Clean old stats
	local oldStats = player:FindFirstChild("Stats")
	if oldStats then
		oldStats:Destroy()
	end

	local statsFolder = Instance.new("Folder")
	statsFolder.Name = "Stats"
	statsFolder.Parent = player

	local baseFolder = Instance.new("Folder")
	baseFolder.Name = "BaseStats"
	baseFolder.Parent = statsFolder

	local HttpService = game:GetService("HttpService")

	for stat, value in pairs(data) do
		local defaultType = typeof(self.Defaults[stat])
		local actualType = typeof(value)

		if actualType == "number" or actualType == "string" then
			local instance = createStatInstance(stat, value)
			if instance then
				instance.Parent = baseFolder
			end
		else
			-- Store complex/nested tables as JSON strings
			local jsonValue = Instance.new("StringValue")
			jsonValue.Name = stat
			jsonValue.Value = HttpService:JSONEncode(value)
			jsonValue.Parent = baseFolder
		end
	end

	-- Calculate all modifiers
	local skillTreeModifiers = CalculateStats:CalculateSkillTreeModifiers(data.Class, data.SkillTreePoints)
	local itemModifiers = CalculateStats:CalculateItemModifiers(data.Equipment)
	local buffModifiers = CalculateStats:CalculateBuffModifiers(data.Buffs)

	-- Store Modifiers
	-- Store Modifiers
	local modifiersFolder = Instance.new("Folder")
	modifiersFolder.Name = "Modifiers"
	modifiersFolder.Parent = statsFolder

	local function storeModifiers(modData, name)
		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = modifiersFolder

		for i, values in pairs(modData) do
			local Stat = values.Stat
			local Type = values.Type
			local Value = values.Value
			local Source = values.Source
			createModifierEntry(folder, Stat, Value, Type, i)
		end
	end

	storeModifiers(skillTreeModifiers, "SkillTree")
	storeModifiers(itemModifiers, "Items")
	storeModifiers(buffModifiers, "Buffs")

	-- Rebuild modifiers for CalculateStats from folders
	local skillTree = readMultiModifiers(modifiersFolder:FindFirstChild("SkillTree"))
	local items = readMultiModifiers(modifiersFolder:FindFirstChild("Items"))
	local buffs = readMultiModifiers(modifiersFolder:FindFirstChild("Buffs"))

	-- Final calculated stats
	local finalStats = CalculateStats:CalculateStats(data.Class, skillTree, items, buffs)

	local finalStatsFolder = Instance.new("Folder")
	finalStatsFolder.Name = "FinalStats"
	finalStatsFolder.Parent = statsFolder

	for stat, value in pairs(finalStats) do
		local instance = createStatInstance(stat, value)
		if instance then
			instance.Parent = finalStatsFolder
		end
	end

	-- Store SkillTreeData modifiers
	local skillTreeDataFolder = Instance.new("Folder")
	skillTreeDataFolder.Name = "SkillTreeData"
	skillTreeDataFolder.Parent = statsFolder

	for skillID, skillData in pairs(data.SkillTreeData or {}) do
		local skillModifiers = CalculateStats:CalculateSkillModifiers(data.SkillTreeData, skillID)
		local skillStats = CalculateStats:CalculateSkillStats(data.Class, skillTree, items, buffs, skillModifiers)

		local skillFolder = Instance.new("Folder")
		skillFolder.Name = skillID
		skillFolder.Parent = skillTreeDataFolder

		-- Store individual modifiers
		for i, mod in ipairs(skillModifiers) do
			createModifierEntry(skillFolder, mod.Stat, mod.Value, mod.Type, i)
		end

		-- Store final stats under FinalStats subfolder
		local finalStatsFolder = Instance.new("Folder")
		finalStatsFolder.Name = "FinalStats"
		finalStatsFolder.Parent = skillFolder

		for stat, value in pairs(skillStats) do
			local instance = createStatInstance(stat, value)
			if instance then
				instance.Parent = finalStatsFolder
			end
		end
	end

	printStatsFolder(player, statsFolder)
end

function printStatsFolder(player, statsFolder)
	local function printFolderContents(folder, indent)
		indent = indent or ""
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("Folder") then
				print(indent .. "[" .. child.Name .. "]")
				printFolderContents(child, indent .. "  ")
			elseif child:IsA("ValueBase") then
				print(indent .. child.Name .. " =", child.Value)
			else
				print(indent .. child.Name .. " (Unknown Type)")
			end
		end
	end

	print("===== Stats for", player.Name, "=====")

	for _, topFolder in ipairs(statsFolder:GetChildren()) do
		if topFolder:IsA("Folder") then
			print("[" .. topFolder.Name .. "]")
			printFolderContents(topFolder, "  ")
		end
	end

	print("===================================")
end

--function printStatsFolder(player, statsFolder)

--	local function printFolderContents(folder, indent)
--		indent = indent or ""
--		for _, child in ipairs(folder:GetChildren()) do
--			if child:IsA("Folder") then
--				print(indent .. "[" .. child.Name .. "]")
--				printFolderContents(child, indent .. "  ")
--			elseif child:IsA("ValueBase") then
--				print(indent .. child.Name .. " =", child.Value)
--			else
--				print(indent .. child.Name .. " (Unknown Type)")
--			end
--		end
--	end

--	print("===== Stats for", player.Name, "=====")

--	local base = statsFolder:FindFirstChild("BaseStats")
--	if base then
--		print("[BaseStats]")
--		printFolderContents(base, "  ")
--	end

--	local final = statsFolder:FindFirstChild("FinalStats")
--	if final then
--		print("[FinalStats]")
--		printFolderContents(final, "  ")
--	end

--	print("===================================")
--end
function StatsService:CreateNewSave(player, slotNumber, class)
	local validClasses = {
		Knight = true,
		Mage = true,
		Ranger = true,
		Rogue = true,
		Priest = true,
	}

	if not validClasses[class] then
		warn("Invalid class selected for", player.Name)
		return
	end

	local key = "User_" .. player.UserId .. "_Slot_" .. slotNumber
	local newData = {}

	for stat, default in pairs(self.Defaults) do
		newData[stat] = (stat == "Class") and class or default
	end

	local success, err = pcall(function()
		dataStore:SetAsync(key, newData)
	end)

	if not success then
		warn("Failed to create new save for", player.Name, ":", err)
		return
	end

	self:LoadStats(player, slotNumber)
end

function StatsService:DeleteSave(player, slotNumber)
	local key = "User_" .. player.UserId .. "_Slot_" .. tostring(slotNumber)

	local success, err = pcall(function()
		dataStore:RemoveAsync(key)
	end)

	if not success then
		warn("Failed to delete save:", err)
	end
	return success
end

return StatsService
