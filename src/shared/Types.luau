-- src/shared/Types.luau

export type ModifierType = "Flat" | "Multiplicative" | "Additive"

export type Modifier = {
	Type: ModifierType,
	Values: { [string]: number },
}

export type SkillTree = {
	Name: string,
	Description: string,
	MaxPoints: number,
	Modifiers: { Modifier },
	Icon: string,
}

export type ClassSkillTree = {
	[string]: SkillTree,
}

export type DataModel = {
	ClassSkillTree: ClassSkillTree,
}

export type DataModels = {
	[string]: DataModel,
}

-- Return an empty table to satisfy Lua's require() mechanism
return {}
