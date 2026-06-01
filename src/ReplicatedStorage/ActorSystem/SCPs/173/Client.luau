--!strict
--[[
	Primary working file for SCP - 173
	
	Implements ClientSCP spec.
	
	ClientSCP should return an exposed set of functions for loading and unloading the module from the client.
	The module itself should host a non-instanced singleton and state. External access and API calls should be
	handled via *SIGNALs* or ActorUtils. Do not require any external modules within this module.
	
	halri :3
]]
const Players = game:GetService("Players")
const RunService = game:GetService("RunService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Blink = require(ReplicatedStorage.Blink.Client)

const ActorSystem = ReplicatedStorage.ActorSystem
const Types = require(ActorSystem.Types)

const Assets = ReplicatedStorage.Assets :: Folder
const SCP173Assets = Assets["173"] :: Folder

const State = {
	BeingObserved = false,
	Cooldowns = {
		
	}
}

const Player = Players.LocalPlayer :: Player

const CharacterFolder = workspace.Characters :: Folder
const NPCFolder = workspace.NPCs :: Folder
const SCPFolder = workspace.SCPs :: Folder

const Connections: {RBXScriptConnection} = {}
const Instances: {Instance} = {}

const DisplayPersistence: {[Model]: Attachment} = {}

const function GetSCPModel()
	return Player.Character :: Model & {HumanoidRootPart: BasePart}
end

const function MakeDisplay(character: Model)
	const head = character:FindFirstChild("Head") :: BasePart
	if not head then
		return
	end
	--TODO: get head visual name and type this properly.
	DisplayPersistence[character] = (SCP173Assets :: any).Thing:Clone()
	DisplayPersistence[character].Parent = head
end

const function UpdateDisplay(Characters: {Model})
	for i, character in Characters do
		if DisplayPersistence[character] then
			continue
		end
		MakeDisplay(character)
	end

	for character, Attachment in DisplayPersistence do
		if table.find(Characters, character) then
			continue
		end

		Attachment:Destroy()
		DisplayPersistence[character] = nil
	end
end

const function Update(dt: number)
	const LookingAt173: {Model} = {}

	for i, CharacterModel in CharacterFolder:GetChildren() do
		if not CharacterModel:IsA("Model") then
			continue
		end

		const Head = CharacterModel:FindFirstChild("Head") :: BasePart
		if not Head then
			continue
		end

		const HeadLookVector = Head.CFrame.LookVector
		const SCPModel = GetSCPModel()
		const LookVector = (SCPModel.HumanoidRootPart.Position - Head.Position).Unit
		if HeadLookVector:Dot(LookVector) < .3 then
			continue
		end

		const RayResult = workspace:Raycast(Head.Position, LookVector * 100)
		if not RayResult or RayResult.Instance ~= SCPModel.HumanoidRootPart then
			continue
		end

		table.insert(LookingAt173, CharacterModel)
	end

	State.BeingObserved = #LookingAt173 ~= 0
	UpdateDisplay(LookingAt173)
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
	BuildConnections()
end

function Public.Unload()
	CleanUp()
end

return Public