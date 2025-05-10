-- src/shared/Types.luau

export type ModifierType = "Flat" | "Multi" | "Additive"

export type Modifier = {
	Type: ModifierType,
	Values: { [string]: number },
}

export type AbilityTreeNode = {
	Name: string,
	Description: string,
	MaxPoints: number,
	Modifiers: { [string]: Modifier },
	Icon: string,
	Requires: { [string]: any }?,
}

export type AbilityTree = {
	[string]: AbilityTreeNode,
}

type AbilityModifier = {
	Type: ModifierType,
	Values: { [string]: number },
}
export type Ability = {
	Id: string,
	Name: string,
	Description: string,
	Icon: string,
	Cooldown: number,
	ManaCost: number,
	Class: string,
	DefaultModifiers: { AbilityModifier }?,
	AbilityTree: AbilityTree?,
}

return {}
