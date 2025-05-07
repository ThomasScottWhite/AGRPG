local SkillTreeModifierEngine = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModifierEngine = require(ReplicatedStorage.Stats.ModifierEngine)

local SkillTreeMap = {
	["Knight"] = require(ReplicatedStorage.Stats.ClassSkillTree.Knight),
	["Mage"] = require(ReplicatedStorage.Stats.ClassSkillTree.Mage),
	["Ranger"] = require(ReplicatedStorage.Stats.ClassSkillTree.Ranger),
	["Rogue"] = require(ReplicatedStorage.Stats.ClassSkillTree.Rogue),
	["Priest"] = require(ReplicatedStorage.Stats.ClassSkillTree.Priest),
}

-- Function to retrieve modifiers from the skill tree based on allocated points
function SkillTreeModifierEngine.GetTreeModifiers(class, SkillTreePoints)
	local skillTree = SkillTreeMap[class]
	if not skillTree then
		warn("Invalid class: " .. tostring(class) .. debug.traceback())
		return {}
	end

	local modifiers = {}

	for nodeId, nodeData in pairs(SkillTreePoints) do
		local nodeDefinition = skillTree[nodeId]
		if nodeDefinition and nodeDefinition.modifiers then
			local points = nodeData.points or 0
			if points > 0 then
				for _, modifier in ipairs(nodeDefinition.modifiers) do
					local modType = modifier.Type
					local values = modifier.Values

					for stat, baseValue in pairs(values) do
						table.insert(modifiers, {
							Type = modType,
							Value = baseValue * points,
							Stat = stat,
							Source = "SkillTree_" .. nodeId,
						})
					end
				end
			end
		end
	end

	return modifiers
end

return SkillTreeModifierEngine

-- Function to retrieve base stats for a given class
-- SkillTreePoints should be organized such as

--SkillTreePoints = {
--	["IncreasedHealth"] = {
--		points = 1
--	},
--	["IncreasedDamage"] = {
--		points = 3
--	}

--}
