-- SkillData/skills/Fireball.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModifierEngine = require(ReplicatedStorage.Stats.ModifierEngine)

return {
	Id = "Fireball",
	Name = "Fireball",
	Description = "Launches a fiery projectile.",
	Icon = "rbxassetid://234567",
	Cooldown = 3,
	ManaCost = 20,
	Class = "Mage",

	DefaultModifiers = {
		{
			Type = ModifierEngine.ModifierType.Flat,
			Values = { MagicDamage = 10 },
		},
		{
			Type = ModifierEngine.ModifierType.Multiplicative,
			Values = { BurnDuration = 1.25 },
		},
	},

	SkillTree = {
		["IncreasedExplosionRadius"] = {
			Name = "Widen Blast",
			Description = "Increases Fireball radius.",
			MaxPoints = 3,
			Modifiers = {
				{
					Type = ModifierEngine.ModifierType.Additive,
					Values = { ExplosionRadius = 0.1 }, -- +10% per point
				},
			},
			Icon = "rbxassetid://333333",
			Requires = {},
		},

		["ReducedCooldown"] = {
			Name = "Quicker Cast",
			Description = "Reduces cooldown by 0.2 seconds per point.",
			MaxPoints = 5,
			Modifiers = {
				{
					Type = ModifierEngine.ModifierType.Flat,
					Values = { Cooldown = -0.2 },
				},
			},
			Icon = "rbxassetid://444444",
			Requires = {},
		},
	},
}
