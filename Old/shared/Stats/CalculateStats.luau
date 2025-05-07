local CalculateStats = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModifierEngine = require(ReplicatedStorage.Stats.ModifierEngine)

local CharacterStatDefinitions = require(ReplicatedStorage.Stats.CharacterStatDefinitions)
local SkillTreeEngine = require(ReplicatedStorage.Stats.SkillTreeEngine)
local SkillModifierEngine = require(ReplicatedStorage.Stats.SkillModifierEngine)
local ItemModifierEngine = require(ReplicatedStorage.Stats.ItemModifierEngine)
local BuffModifierEngine = require(ReplicatedStorage.Stats.BuffModifierEngine)

local function appendModifiers(targetList, sourceMap)
	for stat, modList in pairs(sourceMap) do
		for _, mod in ipairs(modList) do
			table.insert(targetList, {
				Stat = stat,
				Value = mod.value,
				Type = mod.type,
			})
		end
	end
end

function CalculateStats:CalculateSkillTreeModifiers(class, skilltree)
	local skillTreeModifiers = SkillTreeEngine.GetTreeModifiers(class, skilltree)
	return skillTreeModifiers
end

function CalculateStats:CalculateSkillModifiers(PlayerSkillTree, skillID)
	local skillModifiers = SkillModifierEngine.GetSkillModifiers(PlayerSkillTree, skillID)
	return skillModifiers
end

function CalculateStats:CalculateItemModifiers(equipment)
	local ItemModifiers = ItemModifierEngine.GetItemModifiers(equipment)
	return ItemModifiers
end

function CalculateStats:CalculateBuffModifiers(buffs)
	local BuffModifiers = BuffModifierEngine.GetBuffModifiers(buffs)
	return BuffModifiers
end

function CalculateStats:CalculateStats(class, skillTreeModifiers, ItemModifiers, BuffModifiers)
	local baseStats = CharacterStatDefinitions.getBaseStats(class)

	local allModifiers = {}
	appendModifiers(allModifiers, skillTreeModifiers)
	appendModifiers(allModifiers, ItemModifiers)
	appendModifiers(allModifiers, BuffModifiers)

	local finalStats = ModifierEngine.ComputeEffectiveStats(baseStats, allModifiers)
	return finalStats
end

function CalculateStats:CalculateSkillStats(class, skillTreeModifiers, ItemModifiers, BuffModifiers, skillModifiers)
	local baseStats = CharacterStatDefinitions.getBaseStats(class)

	local allModifiers = {}
	appendModifiers(allModifiers, skillTreeModifiers)
	appendModifiers(allModifiers, ItemModifiers)
	appendModifiers(allModifiers, BuffModifiers)
	appendModifiers(allModifiers, skillModifiers)

	local finalStats = ModifierEngine.ComputeEffectiveStats(baseStats, allModifiers)
	return finalStats
end

return CalculateStats
