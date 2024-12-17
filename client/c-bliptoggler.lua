-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘 Blip-Toggler
-- This module spawns an NPC that toggles several predefined blips / map markers.

local Config = {
    NPC_MODEL = "cs_omega", -- NPC model (https://docs.fivem.net/docs/game-references/ped-models/)
    NPC_COORDS = vector3(1465.26, 6557.28, 12.93), -- NPC spawn location
    NPC_HEADING = 90.0, -- Rotation
    BLIP_NAME = "blip-manager", -- Blip name displayed on the map
    BLIP_ID = 280, -- Blip sprite ID (https://docs.fivem.net/docs/game-references/blips/)
    BLIP_ENABLED = true, -- Toggle for NPC blip visibility
    BLIP_COLOR = 3, -- Blip color (https://docs.fivem.net/docs/game-references/blips/#blip-colors)
    BLIP_SIZE = 1.0, -- Blip scale/size (default is 1.0)
    POLYZONE_RADIUS = 2.0, -- Interaction radius
    PREDEFINED_BLIPS = {
        -- Cache Hunting
        {coords = vector3(1559.15, 6651.86, 1.61), name = "Point A", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(1795.24, 6583.31, 53.48), name = "Point B", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(2157.97, 6371.01, 184.29), name = "Point C", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(2751.84, 6543.07, 0.72), name = "Point D", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(2828.03, 5979.24, 347.15), name = "Point E", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(2909.53, 5474.84, 184.65), name = "Point F", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(3444.38, 5175.65, 3.76), name = "Point G", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(3612.79, 5024.97, 10.35), name = "Point H", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(3197.62, 4602.26, 174.79), name = "Point I", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(3937.93, 4387.37, 15.49), name = "Point J", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(3287.04, 3140.41, 252.53), name = "Point K", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(3464.03, 2592.33, 18.34), name = "Point L", blipId = 353, blipColor = 3, blipSize = 0.8}
    }
}

local markersActive = false
local markers = {}
local isTogglingMarkers = false -- Guard variable to prevent re-entry

-- Function to load a model into memory
function loadModel(model)
    if not IsModelInCdimage(model) or not IsModelValid(model) then
        return false
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end

    return true
end

-- Function to spawn the NPC
function spawnNPC()
    if not loadModel(Config.NPC_MODEL) then return nil end

    local npc = CreatePed(4, Config.NPC_MODEL, Config.NPC_COORDS.x, Config.NPC_COORDS.y, Config.NPC_COORDS.z, Config.NPC_HEADING, true, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetPedCanRagdoll(npc, false)
    FreezeEntityPosition(npc, true)

    -- Create a blip for the NPC if enabled
    if Config.BLIP_ENABLED then
        local blip = AddBlipForEntity(npc)
        SetBlipSprite(blip, Config.BLIP_ID)
        SetBlipColour(blip, Config.BLIP_COLOR) -- Apply configured color
        SetBlipScale(blip, Config.BLIP_SIZE) -- Apply configured size
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.BLIP_NAME)
        EndTextCommandSetBlipName(blip)
    end

    return npc
end

-- Function to toggle map markers
function toggleMarkers()
    if isTogglingMarkers then
        return
    end

    isTogglingMarkers = true -- Prevent re-entry

    if markersActive then
        -- Deactivate markers
        for _, marker in ipairs(markers) do
            RemoveBlip(marker)
        end
        markers = {}
    else
        -- Activate markers
        for _, blipData in ipairs(Config.PREDEFINED_BLIPS) do
            local blip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)
            SetBlipSprite(blip, blipData.blipId or 1) -- Default to 1 if not set
            SetBlipColour(blip, blipData.blipColor or 1) -- Default to 1 if not set
            SetBlipScale(blip, blipData.blipSize or 1.0) -- Default to 1.0 if not set
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blipData.name)
            EndTextCommandSetBlipName(blip)
            table.insert(markers, blip)
        end
    end

    markersActive = not markersActive -- Toggle state
    isTogglingMarkers = false -- Allow re-entry
end

-- Function to set up interaction with the NPC
function setupInteraction(npc)
    exports.ox_target:addEntity(NetworkGetNetworkIdFromEntity(npc), {
        {
            name = 'toggle_map_markers', -- Do not change
            label = 'Toggle Blips', -- Target text
            icon = 'fa-map-marker-alt', -- Target icon
            onSelect = function()
                toggleMarkers()
            end
        }
    })
end

-- Main script logic
Citizen.CreateThread(function()
    -- Spawn the NPC
    local npc = spawnNPC()
    if npc then
        setupInteraction(npc)
    else
        return
    end

    while true do
        Wait(500) -- Reduce loop frequency to prevent performance issues
    end
end)

-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘

