--!strict
--[[
    SCP 173 specific utils
    - halri!!
]]
const CharacterFolder = workspace.Characters :: Folder
const NPCFolder = workspace.NPCs :: Folder
const SCPFolder = workspace.SCPs :: Folder


const SharedUtils = {}

SharedUtils.ObservationParams = RaycastParams.new()
SharedUtils.ObservationParams.FilterType = Enum.RaycastFilterType.Exclude
SharedUtils.ObservationParams.FilterDescendantsInstances = {CharacterFolder, NPCFolder, SCPFolder}

function SharedUtils.ObservationRaycast(origin: Vector3, LookVector: Vector3, lookingFor: BasePart)
	const RayResult = workspace:Raycast(origin, LookVector * 100, SharedUtils.ObservationParams)

	if RayResult then
		if RayResult.Instance == lookingFor then
			return true
		elseif RayResult.Instance.Transparency >= .1 then
			table.insert(SharedUtils.ObservationParams.FilterDescendantsInstances, RayResult.Instance)
			return SharedUtils.ObservationRaycast(origin, LookVector, lookingFor)
		end
	end

	return false
end

return SharedUtils