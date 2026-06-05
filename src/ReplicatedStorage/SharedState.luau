--!strict
--[[
    Shared State module for handling client stuff. It utilizes Charm as a state management option, so kawaiiiiiiiiiiii.

    information on charm can be found at the link below!
    > https://github.com/littensy/charm

    halri :3
]]
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Charm = require(ReplicatedStorage.Dependencies.Charm)

return {
    IsSCP = Charm.atom(false),
    SpawnedIn = Charm.atom(false),
    Level = Charm.atom(0),
    Team = Charm.atom("None"),
    SubTeam = Charm.atom("None")    
}


