local ItemModifierEngine = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModifierEngine = require(ReplicatedStorage.Stats.ModifierEngine)

-- Function to retrieve modifiers from the skill tree based on allocated points
function ItemModifierEngine.GetItemModifiers(equipment)
	local modifiers = {}
	return modifiers
end

return ItemModifierEngine

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
