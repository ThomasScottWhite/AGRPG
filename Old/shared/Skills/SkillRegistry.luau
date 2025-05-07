-- SkillData/SkillRegistry
local SkillRegistry = {}
SkillRegistry.Skills = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local skillFolder = ReplicatedStorage:WaitForChild("SkillData"):WaitForChild("skills")

-- Dynamically load all skills
for _, module in ipairs(skillFolder:GetChildren()) do
	if module:IsA("ModuleScript") then
		local success, skillData = pcall(require, module)
		if success and skillData and skillData.Id then
			SkillRegistry.Skills[skillData.Id] = skillData
		else
			warn("Failed to load skill module:", module.Name)
		end
	end
end

-- Accessors
function SkillRegistry:GetSkillById(skillId)
	return self.Skills[skillId]
end

function SkillRegistry:GetSkillByName(skillName)
	for id, data in pairs(self.Skills) do
		if data.Name == skillName then
			return data
		end
	end
	return nil
end

return SkillRegistry
