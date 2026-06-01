--!strict
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local _ActorSystem = require(ReplicatedStorage.ActorSystem.ActorClient)
local _Testing = require(ReplicatedStorage.Testing)
