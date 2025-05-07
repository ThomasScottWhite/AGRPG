-- SkillModifierEngine.lua
local SkillModifierEngine = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SkillRegistry = require(ReplicatedStorage.SkillData.SkillRegistry)
local ModifierEngine = require(ReplicatedStorage.Stats.ModifierEngine)

function SkillModifierEngine.GetSkillModifiers(PlayerSkillTree, skillId)
	local modifiers = {}
	local skillData = SkillRegistry:GetSkillById(skillId)

	if not skillData then
		warn("Skill not found in registry:", skillId)
		return modifiers
	end

	-- Add default modifiers (static, not scaled)
	if skillData.DefaultModifiers then
		for _, mod in ipairs(skillData.DefaultModifiers) do
			table.insert(modifiers, mod)
		end
	end

	-- Fetch allocated skill tree points for this skill (if any)
	local playerSkillEntry = PlayerSkillTree[skillId]
	if not playerSkillEntry then
		return modifiers
	end

	local playerTreeData = playerSkillEntry.SkillTree or {}
	local skillTree = skillData.SkillTree or {}

	for nodeId, pointData in pairs(playerTreeData) do
		local nodeDefinition = skillTree[nodeId]
		if nodeDefinition and pointData.points and pointData.points > 0 then
			for _, mod in ipairs(nodeDefinition.Modifiers or {}) do
				-- Multiply each modifier value by the number of points spent
				local scaledValues = {}
				for stat, value in pairs(mod.Values) do
					scaledValues[stat] = value * pointData.points
				end
				table.insert(modifiers, {
					Type = mod.Type,
					Values = scaledValues,
				})
			end
		end
	end

	return modifiers
end

return SkillModifierEngine

-- funciton to get all modifiers from a skill with the given allocated skills

-- This is an example of "PlayerSkillTree" may look like

--SkillTreeData = {
--	Fireball = {
--		Level = 1 ,
--		SkillTree = {
--			IncreasedExplosionRadius = { points = 1 }
--		}
--	},
--},

-- This is an example of what "SkillTree" may look like
-- {
--	Id = "Fireball",
--	Name = "Fireball",
--	Description = "Launches a fiery projectile.",
--	Icon = "rbxassetid://234567",
--	Cooldown = 3,
--	ManaCost = 20,
--	Class = "Mage",

--	DefaultModifiers = {
--		{
--			Type = ModifierEngine.ModifierType.Flat,
--			Values = { MagicDamage = 10 }
--		},
--		{
--			Type = ModifierEngine.ModifierType.Multiplicative,
--			Values = { BurnDuration = 1.25 }
--		}
--	},

--	SkillTree = {
--		["IncreasedExplosionRadius"] = {
--			Name = "Widen Blast",
--			Description = "Increases Fireball radius.",
--			MaxPoints = 3,
--			Modifiers = {
--				{
--					Type = ModifierEngine.ModifierType.Additive,
--					Values = { ExplosionRadius = 0.1 } -- +10% per point
--				}
--			},
--			Icon = "rbxassetid://333333",
--			Requires = {}
--		},

--		["ReducedCooldown"] = {
--			Name = "Quicker Cast",
--			Description = "Reduces cooldown by 0.2 seconds per point.",
--			MaxPoints = 5,
--			Modifiers = {
--				{
--					Type = ModifierEngine.ModifierType.Flat,
--					Values = { Cooldown = -0.2 }
--				}
--			},
--			Icon = "rbxassetid://444444",
--			Requires = {}
--		},
--	}
--}
