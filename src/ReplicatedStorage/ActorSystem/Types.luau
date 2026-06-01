--!strict
export type ServerSCP = {
	CanPlayAs: (Player: Player) -> (boolean),
	LoadCharacter: (Player: Player, ActorProfile: ActorData) -> (),
	UnloadCharacter: (Player: Player, ActorProfile: ActorData) -> ()
}

export type ClientSCP = {
	Load: () -> (),
	Unload: () -> ()
}

export type SCPConfig = {
	MaxSCP: number,
	RequiredRank: number,
	SpecialAuth: {boolean},
	Cooldowns: {[string]: number}
}

export type ActorData = {
	PlayingAs: number,
	Cooldowns: {[string]: number},
	Connections: {RBXScriptConnection},
	Instances: {Instance},
}

return nil