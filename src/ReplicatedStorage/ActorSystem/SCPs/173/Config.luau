--!strict
--[[
	Configuration file for SCP - 173
]]
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const ActorSystem = ReplicatedStorage.ActorSystem
const Types = require(ActorSystem.Types)

return {
	MaxSCP = 1,
	RequiredRank = 1,
	SpecialAuth = {},
	Cooldowns = {
		Move = 1,
		ForceBlink = 15
	}
} :: Types.SCPConfig