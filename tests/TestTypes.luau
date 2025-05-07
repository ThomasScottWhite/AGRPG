-- Import the Types module
local Types = require("../src/shared/Types")

-- Test the Types
local exampleSkillTree: Types.SkillTree = {
	Name = "Berserker",
	Description = "A brutal warrior class focused on offense.",
	MaxPoints = 10,
	Modifiers = {
		{ Type = "Flat", Values = { Attack = 5, Defense = -2 } },
		{ Type = "Multiplicative", Values = { Health = 1.2 } },
	},
	Icon = "rbxassetid://12345678",
}

print("Testing Types:")
print(exampleSkillTree.Name) -- Should print "Berserker"
