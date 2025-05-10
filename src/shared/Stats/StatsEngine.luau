Shared = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Stats = require(Shared:WaitForChild("Stats"))
local BaseStatsEngine = require(Shared:WaitForChild("BaseStatsEngine"))

function Shared.CalculateStats(player: Player)
	local CharacterData = player:FindFirstChild("CharacterData")
	if not CharacterData then
		return
	end
	local CharacterName = CharacterData:FindFirstChild("CharacterName")
	local CharacterLevel = CharacterData:FindFirstChild("Level")
	local CharacterClass = CharacterData:FindFirstChild("Class")

	if not CharacterName or not CharacterLevel or not CharacterClass then
		return
	end
	local stats = {}

	BaseStatsEngine.CalculateBaseStats(CharacterClass)
	return stats
end

return Shared
