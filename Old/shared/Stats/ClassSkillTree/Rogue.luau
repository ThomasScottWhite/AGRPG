local ReplicatedStorage = game:GetService("ReplicatedStorage")
ModifierEngine = require(ReplicatedStorage.Stats.ModifierEngine)

local KnightSkillTree = {
	["IncreasedHealth"] = {
		Name = "Increased Health",
		Description = "Increases Health by 20 per point",
		MaxPoints = 5,
		modifiers = {
			{
				Type = ModifierEngine.ModifierType.Flat,
				Values = { MaxHealth = 20 },
			},
			{
				Type = ModifierEngine.ModifierType.Multiplicative,
				Values = { HealthRegen = 1.1 },
			},
		},

		Icon = "rbxassetid://123456",
	},
}

return KnightSkillTree
