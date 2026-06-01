--!strict

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

if not RunService:IsStudio() then
    return
end

const Blink = require(ReplicatedStorage.Blink.Client)

Blink.ActorSystem.RequestSCP.Fire(173)

return nil