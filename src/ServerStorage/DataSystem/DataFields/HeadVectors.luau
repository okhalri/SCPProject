--!strict
--[[
	DataServer - HeadVectors
	
	This module impliments the DataField<HeadVectors> type.
	
	halri
]]

const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerStorage = game:GetService("ServerStorage")

const Dependencies = ReplicatedStorage.Dependencies
const Scheduler = require(Dependencies.Scheduler)

const DataSystem = ServerStorage.DataSystem
const Types = require(DataSystem.Types)
const NPCFolder = workspace.NPCs
const SchedulerId = "DataServer.HeadVector.Update"

const HeadVectors = {
	Data = {
		Players = {},
		NPCs = {}
	}
} :: Types.DataField<Types.HeadVectors>

const function Update()
	const PlayerList = Players:GetPlayers()
	table.clear(HeadVectors.Data.Players)
	for _, Player in PlayerList do
		if not Player.Character then
			continue
		end
		
		const Head = Player.Character:FindFirstChild("Head") :: BasePart
		if not Head then
			return
		end
		
		HeadVectors.Data.Players[Player] = {LookVector = Head.CFrame.LookVector, Position = Head.Position}
	end
	
	const NPCList = NPCFolder:GetChildren()
	table.clear(HeadVectors.Data.NPCs)
	for _, NPC in NPCList do
		if not NPC:IsA("Model")  then
			continue
		end
		const Head = NPC.Character:FindFirstChild("Head") :: BasePart
		if not Head then
			return
		end

		HeadVectors.Data.NPCs[NPC] = {LookVector = Head.CFrame.LookVector, Position = Head.Position}
	end
end

function HeadVectors.load()
	Scheduler.add(SchedulerId, 1/20, Update)
end

function HeadVectors.unload()
	Scheduler.remove(SchedulerId)
end

return HeadVectors