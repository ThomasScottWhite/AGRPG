local ModifierEngine = {}

-- Define modifier types
ModifierEngine.ModifierType = {
	Flat = "Flat",
	Additive = "Additive",
	Multiplicative = "Multiplicative",
}

-- Compute effective stats based on base stats and a list of modifiers
function ModifierEngine.ComputeEffectiveStats(baseStats, modifiers)
	local finalStats = {}

	-- Initialize finalStats with baseStats
	for stat, value in pairs(baseStats) do
		finalStats[stat] = value
	end

	-- Organize modifiers by type
	local flatMods = {}
	local additiveMods = {}
	local multiplicativeMods = {}

	for _, mod in ipairs(modifiers) do
		if mod.Type == ModifierEngine.ModifierType.Flat then
			table.insert(flatMods, mod)
		elseif mod.Type == ModifierEngine.ModifierType.Additive then
			table.insert(additiveMods, mod)
		elseif mod.Type == ModifierEngine.ModifierType.Multiplicative then
			table.insert(multiplicativeMods, mod)
		end
	end

	-- Apply flat modifiers
	for _, mod in ipairs(flatMods) do
		local stat = mod.Stat
		local value = mod.Value
		finalStats[stat] = (finalStats[stat] or 0) + value
	end

	-- Apply additive percentage modifiers
	for _, mod in ipairs(additiveMods) do
		local stat = mod.Stat
		local percent = mod.Value
		finalStats[stat] = (finalStats[stat] or 0) + (baseStats[stat] or 0) * percent
	end

	-- Apply multiplicative modifiers
	for _, mod in ipairs(multiplicativeMods) do
		local stat = mod.Stat
		local factor = mod.Value
		finalStats[stat] = (finalStats[stat] or 0) * factor
	end

	return finalStats
end

return ModifierEngine

-- Example Usage

--local baseStats = {
--	Strength = 100,
--	Agility = 80
--}

--local modifiers = {
--	{
--		Type = ModifierEngine.ModifierType.Flat,
--		Values = { Strength = 10 },
--		Source = "Sword"
--	},
--	{
--		Type = ModifierEngine.ModifierType.Additive,
--		Values = { Strength = 0.2 },
--		Source = "Buff"
--	},
--	{
--		Type = ModifierEngine.ModifierType.Multiplicative,
--		Values = { Strength = 1.5 },
--		Source = "Skill"
--	}
--}

--local finalStats = ModifierEngine.ComputeEffectiveStats(baseStats, modifiers)
---- finalStats.Strength = ((100 + 10) + (100 * 0.2)) * 1.5 = 195
