--!strict
--[[
    general purpose utility library for solving problems once and never again

    -- written by halri :3
]]

const UserInputService = game:GetService("UserInputService")

const Camera = workspace.CurrentCamera :: Camera
const Utils = {}

function Utils.GetMouseRaycastResult(dist: number?, raycastParams: RaycastParams?): RaycastResult
    const MousePosition = UserInputService:GetMouseLocation()
    const Ray = Camera:ViewportPointToRay(MousePosition.X, MousePosition.Y)

    return workspace:Raycast(Ray.Origin, Ray.Direction * (dist or 100), raycastParams)
end

return Utils