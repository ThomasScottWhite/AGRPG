local Shared = {}

Shared.DEFAULT_SAVE_SLOTS = {
	SaveMetaData = {},
	LastUsedSave = "nil",
}

Shared.DEFAULT_PLAYER_DATA = {
	CharacterData = {
		CharacterName = "",
		Class = "",
		Level = 1,
		Experience = 0,
	},
	Equipment = {
		["leftHand"] = nil,
		["rightHand"] = nil,
		["head"] = nil,
		["body"] = nil,
		["legs"] = nil,
		["feet"] = nil,
		["ring1"] = nil,
		["ring2"] = nil,
		["amulet"] = nil,
	},
	Inventory = {},
	Abilities = {
		["Ability1"] = {
			Name = "Default Attack",
			AbilityType = "Attack",
			AbilityTree = {},
			Cooldown = 5,
			Level = 1,
			Unlocked = true,
			Description = "Hit the target with a basic attack.",
			Icon = "rbxassetid://1234567890",
		},
	},
	Quests = {},
	SkillTree = {},
}

export type PlayerSaves = {
	SaveMetaData: { CharacterName: string, DataKey: string, Level: number, Class: string },
	LastUsedSave: string?,
}

export type PlayerData = {
	CharacterData: {
		CharacterName: string,
		Class: string,
		Level: number,
		Experience: number,
	},
	Equipment: { [string]: any },
	Inventory: { [string]: any },
	Abilities: { [string]: any },
	Quests: { [string]: any },
	SkillTree: { [string]: any },
}

function CreateNewSaveData(CharacterName: string, class: string): PlayerData
	return {
		CharacterData = {
			CharacterName = CharacterName,
			Class = class,
			Level = 1,
			Experience = 0,
		},
		Equipment = {},
		Inventory = {},
		Abilities = {},
		Quests = {},
		SkillTree = {},
	}
end
return Shared
