local Types = require(script.Parent.Types)

local SkillRegistry = {}
SkillRegistry.Skills = {}

local function RegisterSkill(skillName: string, skillTree: Types.SkillTree)
	if SkillRegistry.Skills[skillName] then
		error("Skill already registered: " .. skillName)
	end

	SkillRegistry.Skills[skillName] = skillTree
end

for i = 1, #script:GetChildren() do
	local skillModule = script[i]
	if skillModule:IsA("ModuleScript") then
		local skillName = skillModule.Name
		local skillTree = require(skillModule)
		RegisterSkill(skillName, skillTree)
	end
end
return SkillRegistry
