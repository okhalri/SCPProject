--!strict
const Players = game:GetService("Players")
const ActorSystem = script.Parent
const Types = require(ActorSystem.Types)

const Player = Players.LocalPlayer :: Player

const ActorModules = {
	[173] = require(ActorSystem.SCPs["173"].Client) :: Types.ClientSCP,
}

const function load()
	local Character = Player.Character
	if not Character then
		return
	end
	local Module = ActorModules[Character:GetAttribute("SCP") :: any]
	if not Module then
		return
	end	
	
	for i, v in ActorModules do
		Module.Unload()
	end
	
	Module.Load()
end

Player.CharacterAdded:Connect(function(Character: Model)
	if Character:GetAttribute("SCP") then
		load()
	else
		Character:GetAttributeChangedSignal("SCP"):Connect(function(...) 
			load()
		end)
	end
end)

return ActorModules