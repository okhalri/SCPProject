--!strict
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local signal = require(replicatedStorage.Dependencies.Signal)

local messageSent: signal.Signal<Player, string, Player?> = signal.new()
local playerAdded: signal.Signal<Player> = signal.new()
local playerRemoving: signal.Signal<Player> = signal.new()
local characterAdded: signal.Signal<Player, Model> = signal.new()
local characterDied: signal.Signal<Player, Model, boolean> = signal.new()
local teamChanged: signal.Signal<Player, Team, Team> = signal.new()

local function PlayerAdded(player: Player) 	
	playerAdded:fire(player)
	
	player.Chatted:Connect(function(message: string, recipient: Player?)
		messageSent:fire(player, message, recipient)
	end)

	local currentTeam: Team? = nil
	
	player:GetPropertyChangedSignal("Team"):Connect(function(...: any) 
		if not player.Team then
			return
		end
		
		teamChanged:fire(player, player.Team :: Team, currentTeam :: any)
		currentTeam = player.Team
	end)
	
	if player.Character then
		characterAdded:fire(player, player.Character)	
		const Humanoid = player.Character:WaitForChild("Humanoid") :: Humanoid
		Humanoid.Died:Connect(function()
			characterDied:fire(player, player.Character, true)
		end)

		const character = player.Character
		character:GetPropertyChangedSignal("Parent"):Connect(function(...)
			if character.Parent == nil then
				characterDied:fire(player, character, false)
			end
		end)
	end
	
	player.CharacterAdded:Connect(function(character: Model) 
		characterAdded:fire(player, character)
		const Humanoid = character:WaitForChild("Humanoid") :: Humanoid
		Humanoid.Died:Connect(function()
			characterDied:fire(player, character, true)
		end)
		character:GetPropertyChangedSignal("Parent"):Connect(function(...)
			if character.Parent == nil then
				characterDied:fire(player, character, false)
			end
		end)
	end)
	
end

task.delay(1, function()
	for i, v in players:GetPlayers() do
		task.spawn(PlayerAdded, v)
	end

	players.PlayerAdded:Connect(PlayerAdded)
	players.PlayerRemoving:Connect(function(player: Player) 
		playerRemoving:fire(player)
	end)
end)

return {
	playerAdded = playerAdded,
	playerRemoving = playerRemoving,
	characterAdded = characterAdded,
	characterDied = characterDied,
	messageSent = messageSent,
	teamChanged = teamChanged
}

