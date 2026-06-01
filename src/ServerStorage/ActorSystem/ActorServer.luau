--!strict
const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerStorage = game:GetService("ServerStorage")

const ActorSystem = ReplicatedStorage.ActorSystem
const Types = require(ActorSystem.Types)

const MessageProvider = require(ReplicatedStorage.Dependencies.MessageProvider)

const Blink = require(ServerStorage.Blink.Server)
const ServerConstants = require(ServerStorage.DataSystem.ServerConstants)

const SCPNumbers: {number} = {}
const CurrentActors: {[Player]: Types.ActorData} = {}
const ActorServer = {}
const SCPData = {
	[173] = {
		Server = require(ActorSystem.SCPs["173"].Server) :: Types.ServerSCP,
		Config = require(ActorSystem.SCPs["173"].Config) :: Types.SCPConfig,
	}
}

for i, v in SCPData do
	SCPNumbers[i] = 0
end

const function RemoveFromCurrentActors(player: Player)
	const actorProfile = CurrentActors[player]

	if not actorProfile then
		return
	end
	
	CurrentActors[player] = nil
	SCPNumbers[actorProfile.PlayingAs] -= 1
end

const function AddToCurrentActors(player: Player, scp: number)
	CurrentActors[player] = {
		PlayingAs = scp,
		Cooldowns = {},
		Instances = {},
		Connections = {}
	}

	SCPNumbers[scp] += 1

	SCPData[scp].Server.LoadCharacter(player, CurrentActors[player])
end

function ActorServer.Validate(player: Player, scp: number)
	const module = SCPData[scp]
	if not module then
		return false
	end

	return module.Server.CanPlayAs(player)
end

function ActorServer.RequestCharacter(player: Player, scp: number)
	if not ActorServer.Validate(player, scp) then
		Players:BanAsync({
			UserIds = {player.UserId},
			Duration = 60*60,
			DisplayReason = "You attempted to access an SCP without proper authentication.\n This has been logged and you have been banned for one hour.",
			PrivateReason = `Attempted to access: SCP-{scp} at {os.date("!%c")} UTC in {ServerConstants.ServerId}`
		})
		return
	end

	if CurrentActors[player] then
		Blink.ActorSystem.ResponseSCP.Fire(player, {
			Allowed = false,
			Reason = "You already have an active Actor Profile. Change teams and try again."
		})
		return
	end

	if SCPNumbers[scp] >= SCPData[scp].Config.MaxSCP then
		Blink.ActorSystem.ResponseSCP.Fire(player, {
			Allowed = false,
			Reason = "This already has the max amount of Actors playing it."
		})
		return
	end

	AddToCurrentActors(player, scp)
	Blink.ActorSystem.ResponseSCP.Fire(player, {
		Allowed = true,
	})
end

MessageProvider.playerRemoving:connect(RemoveFromCurrentActors)
MessageProvider.characterDied:connect(RemoveFromCurrentActors)
Blink.ActorSystem.RequestSCP.On(ActorServer.RequestCharacter)

return ActorServer 