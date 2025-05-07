-- ServerScriptService/NPCCombatModule.lua
local NPCCombatModule = {}

-- Function to apply damage and track it
function NPCCombatModule.applyPlayerDamage(npcModel, player, damageAmount)
	local humanoid = npcModel:FindFirstChild("Humanoid")
	if not humanoid or not player then
		return
	end

	-- Initialize damage log if it doesn't exist
	if not npcModel:FindFirstChild("DamageLog") then
		local damageLog = Instance.new("Folder")
		damageLog.Name = "DamageLog"
		damageLog.Parent = npcModel
	end

	local damageLog = npcModel:FindFirstChild("DamageLog")
	local playerTag = damageLog:FindFirstChild(player.UserId)

	if not playerTag then
		playerTag = Instance.new("IntValue")
		playerTag.Name = player.UserId
		playerTag.Value = 0
		playerTag.Parent = damageLog
	end

	playerTag.Value += damageAmount
	humanoid:TakeDamage(damageAmount)
end

return NPCCombatModule
