--!strict

export type DataField<DATA = {}> = {
	load: () -> (),
	unload: () -> (),
	
	Data: DATA
}

export type HeadVectors = {Players: {[Player]: Vector3}, NPCs: {[Model]: Vector3}}

return nil