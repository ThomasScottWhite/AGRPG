local Shared = {}

-- Base stats applicable to all classes
local BaseStats = {
	MaxHealth = 100,
	MaxMana = 100,
	Speed = 50,
	HealthRegen = 1,
	ManaRegen = 1,
}

-- Class-specific stat overrides
local ClassStats = {
	Knight = {
		MaxHealth = 150,
		MaxMana = 80,
		Speed = 40,
	},
	Mage = {
		MaxHealth = 80,
		MaxMana = 150,
		Speed = 50,
	},
	Ranger = {
		MaxHealth = 100,
		MaxMana = 100,
		Speed = 60,
	},
	Rogue = {
		MaxHealth = 90,
		MaxMana = 90,
		Speed = 70,
	},
	Priest = {
		MaxHealth = 100,
		MaxMana = 120,
		Speed = 45,
	},
}

-- Function to retrieve base stats for a given class
function Shared.getBaseStats(class)
	local classStats = ClassStats[class]
	if not classStats then
		warn("Invalid class: " .. tostring(class) .. debug.traceback())
		return nil
	end

	-- Merge BaseStats with class-specific overrides
	local stats = {}
	for stat, value in pairs(BaseStats) do
		stats[stat] = classStats[stat] or value
	end
	return stats
end

return Shared
