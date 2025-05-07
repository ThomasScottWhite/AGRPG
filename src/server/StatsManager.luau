local StatsManager = {}

-- XP gain logic
function StatsManager.AddXP(player, xp)
	local baseStats = player:FindFirstChild("Stats") and player.Stats:FindFirstChild("BaseStats")
	if baseStats then
		local experience = baseStats:FindFirstChild("Experience")
		if experience then
			experience.Value += xp
		end
	end
end

local function getStats(player)
	local stats = nil
	local base = nil
	local final = nil
	stats = player:FindFirstChild("Stats")
	if stats then
		base = stats:FindFirstChild("BaseStats")
		final = stats:FindFirstChild("FinalStats")
	end
	return stats, base, final
end
-- Health regeneration logic
function StatsManager.HealthRegen(player)
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
	local stats, base, final = getStats(player)

	if base and final and humanoid then
		local regen = final:FindFirstChild("HealthRegen")
		local maxHealth = final:FindFirstChild("MaxHealth")

		if regen and maxHealth and humanoid.Health < maxHealth.Value then
			humanoid.MaxHealth = maxHealth.Value
			humanoid.Health = math.min(humanoid.Health + regen.Value, maxHealth.Value)
			print(humanoid.Health)
		end
	end
end

-- Mana regeneration logic
function StatsManager.ManaRegen(player)
	local stats, base, final = getStats(player)

	if base and final then
		local current = base:FindFirstChild("CurrentMana")
		local max = final:FindFirstChild("MaxMana")
		local regen = final:FindFirstChild("ManaRegen")

		if current and max and regen and current.Value < max.Value then
			current.Value = math.min(current.Value + regen.Value, max.Value)
		end
	end
end

return StatsManager
