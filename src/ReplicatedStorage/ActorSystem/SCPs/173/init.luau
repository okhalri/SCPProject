--!strict
--[[
	Primary working file for SCP - 173
	
	Implements full SCPModule spec for both client and server.
]]
local RunService = game:GetService("RunService")

return if RunService:IsClient() then require(script.Client) else require(script.Server)
