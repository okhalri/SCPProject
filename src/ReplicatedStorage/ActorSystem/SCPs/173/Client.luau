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
const UserInputService = game:GetService("UserInputService")

const Blink = require(ReplicatedStorage.Blink.Client)
const ClientUtils = require(ReplicatedStorage.ClientUtils)

const ActorSystem = ReplicatedStorage.ActorSystem
const Types = require(ActorSystem.Types)

const Assets = ReplicatedStorage.Assets :: Folder
const SCP173Assets = Assets:FindFirstChild("173") :: Folder
const Observation = SCP173Assets:FindFirstChild("Observation") :: Attachment

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

const SharedUtils = require(script.Parent.SharedUtils)

const TeleportParams = RaycastParams.new()
TeleportParams.FilterType = Enum.RaycastFilterType.Exclude
TeleportParams.FilterDescendantsInstances = {CharacterFolder, NPCFolder, SCPFolder}

const DisplayPersistence: {[Model]: Attachment} = {}

const function GetSCPModel()
	return Player.Character :: Model & {HumanoidRootPart: BasePart}
end

const function MakeDisplay(character: Model)
	const head = character:FindFirstChild("Head") :: BasePart
	if not head then
		return
	end

	DisplayPersistence[character] = Observation:Clone()
	DisplayPersistence[character].Parent = head
end

const function GetTeleportPosition()
	const MouseHit = ClientUtils.GetMouseRaycastResult(100, TeleportParams)

	return MouseHit and MouseHit.Position
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


const function Iterate(LookingAt173: {Model}, Children: {Instance})
	for i, CharacterModel in Children do
		if not CharacterModel:IsA("Model") then
			continue
		end

		const Head = CharacterModel:FindFirstChild("Head") :: BasePart
		if not Head then
			continue
		end

		const SCPModel = GetSCPModel()
		const DisplacementVector = (SCPModel.HumanoidRootPart.Position - Head.Position)
		if DisplacementVector.Magnitude > 200 then
			continue
		end

		const HeadLookVector = Head.CFrame.LookVector
		const LookVector = DisplacementVector.Unit
		if HeadLookVector:Dot(LookVector) < .3 then
			continue
		end

		if SharedUtils.ObservationRaycast(Head.Position, LookVector, SCPModel.HumanoidRootPart) then
			table.insert(LookingAt173, CharacterModel)
		end
	end
end

const function Update(dt: number)
	const LookingAt173: {Model} = {}

	Iterate(LookingAt173, CharacterFolder:GetChildren())
	Iterate(LookingAt173, NPCFolder:GetChildren())
	Iterate(LookingAt173, SCPFolder:GetChildren())

	State.BeingObserved = #LookingAt173 ~= 0
	UpdateDisplay(LookingAt173)
end

const function ProcessInput(InputObject: InputObject, gpe: boolean)
	if gpe then return end
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		if State.BeingObserved then
			return
		end
		const Goal = GetTeleportPosition()
		if Goal then
			Blink.ActorSystem.RequestMove.Fire({Move = "Move", Data = Goal})
		end
	end
end

const function BuildConnections()
	RunService:BindToRenderStep("173Update", 1, Update)
	table.insert(Connections, UserInputService.InputBegan:Connect(ProcessInput))
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