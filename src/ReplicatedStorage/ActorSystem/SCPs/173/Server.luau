--!strict
--[[
	Primary working file for SCP - 173
	
	Implements ServerSCP spec.
	
	ServerSCP should return an exposed set of functions for loading and unloading the module from the client.
	The module itself should host a non-instanced singleton and state. External access and API calls should be
	handled via *SIGNALs* or ActorUtils. Do not require any external modules within this module.
	
	halri :3
]]

const RunService = game:GetService("RunService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Assets = ReplicatedStorage.Assets["173"]

const ActorSystem = ReplicatedStorage.ActorSystem
const Types = require(ActorSystem.Types)
const Public = {} :: Types.ServerSCP

function Public.CanPlayAs(Player: Player): boolean
	return true
end

function Public.LoadCharacter(Player: Player, ActorData: Types.ActorData)
	const Model: Model = Assets.CharacterModel:Clone()
	Model.Parent = workspace
	Player.Character = Model
end

function Public.UnloadCharacter(Player: Player)
	
end

return Public