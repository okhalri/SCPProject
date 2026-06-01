--!strict

-- TODO: Implement proper serverId generation.
local function GeneratedServerId()
    return "Busted Orihime"
end

-- TODO: Implement proper serverregion fetching.
local function GetServerRegion()
    return "Yo Mama's House, Earth"
end


return {
    ServerId = GeneratedServerId(),
    Region = GetServerRegion(),
    ServerInitTime = os.time()
}