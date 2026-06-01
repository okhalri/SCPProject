--!strict
--[[
	Primary working file for SCP - 173
	
	Implements ClientSCP spec.
	
	ClientSCP should return an exposed set of functions for loading and unloading the module from the client.
	The module itself should host a non-instanced singleton and state. External access and API calls should be
	handled via *SIGNALs* or ActorUtils. Do not require any external modules within this module.
	
	halri :3
]]

const RunService = game:GetService("RunService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Blink = require(ReplicatedStorage.Blink.Client)

const ActorSystem = ReplicatedStorage.ActorSystem
const Types = require(ActorSystem.Types)

const State = {
	LastMove = 0,
	
}

const Connections: {RBXScriptConnection} = {}
const Instances: {Instance} = {}

const function Update(dt: number)
	
end

const function BuildConnections()
	RunService:BindToRenderStep("173Update", 1, Update)
end

const function BuildInstances()
	
end

const function CleanUp()
	RunService:UnbindFromRenderStep("173Update")
	
	for i, Conn in Connections do
		Conn:Disconnect()
	end
	
	table.clear(Connections)
	
	for i, Inst in Instances do
		Inst:Destroy()
	end
	
	table.clear(Instances)
end

const Public = {} :: Types.ClientSCP

function Public.Load()
	print("loaded 173 controller")
end

function Public.Unload()
	
end

return Public