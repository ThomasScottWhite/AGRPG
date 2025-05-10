local BuffModifierEngine = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModifierEngine = require(ReplicatedStorage.Stats.ModifierEngine)

-- Function to retrieve modifiers from the skill tree based on allocated points
function BuffModifierEngine.GetBuffModifiers(Buffs)
	local modifiers = {}
	return modifiers
end

return BuffModifierEngine

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
