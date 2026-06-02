--!strict

export type DataField<DATA = {}> = {
	load: () -> (),
	unload: () -> (),
	
	Data: DATA
}

export type HeadVectors = {Players: {[Player]: {Position: Vector3, LookVector: Vector3}}, NPCs: {[Model]: {Position: Vector3, LookVector: Vector3}}}

return nil