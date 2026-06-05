--!strict
--[[
	Primary working file for SCP - 173
	
	Implements ServerSCP spec.
	
	ServerSCP should return an exposed set of functions for loading and unloading the module from the server.
	The module itself should host a non-instanced singleton and state. External access and API calls should be
	handled via *SIGNALs* or ActorUtils. Do not require any gameplay modules from within this module.
	
	halri :3
]]
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerStorage = game:GetService("ServerStorage")

const HeadVectors = require(ServerStorage.DataSystem.DataFields.HeadVectors)
const Assets = ReplicatedStorage.Assets["173"]

const ActorSystem = ReplicatedStorage.ActorSystem
const Types = require(ActorSystem.Types)
const Public = {} :: Types.ServerSCP

const Config = require(script.Parent.Config)
const SharedUtils = require(script.Parent.SharedUtils)

const Moves = {
	Move = function (Player: Player, ActorProfile: Types.ActorData, Goal: Vector3): (boolean, string?)
		const Character = Player.Character :: Model & {HumanoidRootPart: BasePart}
		if not Character then
			return false, "How did we get here?"
		end

		if typeof(Goal) ~= "Vector3" and typeof(Goal) ~= "vector" then
			--TODO: Integrate into a shared weird behavior logging system.
			Player:Kick("baka~!")
			return false, "Stinkin' cheater."
		end

		if IsBeingObserved(Character) then 
			return false, "You're being observed!"
		end

		const Ground = workspace:Raycast(Goal+Vector3.new(0, 2, 0), Vector3.new(0, -10, 0), SharedUtils.ObservationParams)
		if not Ground then
			return false, "Who's neck you tryna break up there? 🤣🤣🤣🤣🤣"
		end

		const Rotation = CFrame.new(Character.HumanoidRootPart.Position * Vector3.new(1, 0, 1), Goal * Vector3.new(1, 0, 1)).Rotation
		Character:PivotTo(CFrame.new(Goal + Vector3.new(0, 3.5, 0)) * Rotation)

		return true
	end
}

const function iterate(HRP: BasePart, Iter: {[any]: {Position: Vector3, LookVector: Vector3}}): boolean
	for i, Vectors in Iter do
		const DisplacementVector = (HRP.Position - Vectors.Position)
		if DisplacementVector.Magnitude > 200 then
			continue
		end

		const HeadLookVector = Vectors.LookVector
		const LookVector = DisplacementVector.Unit
		if HeadLookVector:Dot(LookVector) < .3 then
			continue
		end

		if SharedUtils.ObservationRaycast(Vectors.Position, LookVector, HRP) then
			return true
		end
	end

	return false
end

const function IsBeingObserved(SCPModel: Model & {HumanoidRootPart: BasePart}): (boolean)
	const HumanoidRootPart = SCPModel.HumanoidRootPart

	return iterate(HumanoidRootPart, HeadVectors.Data.NPCs) or iterate(HumanoidRootPart, HeadVectors.Data.Players)
end



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

const function SetCooldownOnPass<T...>(ActorProfile: Types.ActorData, Move: string, fn: (T...) -> (boolean, string?), ...: T...): (boolean, string?)
	const accepted, notice = fn(...)

	if accepted then
		ActorProfile.Cooldowns[Move] = os.clock() + Config.Cooldowns[Move]
	end

	return accepted, notice
end


function Public.UseMove(Player: Player, ActorProfile: Types.ActorData, DesiredMove: string, ...): (boolean, string?)
	const OnCDUntil = ActorProfile.Cooldowns[DesiredMove] or 0

	if OnCDUntil >= os.clock() then
		return false, "Move is on CD."
	end

	const Move = Moves[DesiredMove]
	
	if Move then
		return SetCooldownOnPass(ActorProfile, DesiredMove, Move, Player, ActorProfile, ...)
	end

	--TODO: Integrate into a shared weird behavior logging system.
	Player:Kick("It's not like I like you or anything...")

	return false, "Stinker."
end

return Public