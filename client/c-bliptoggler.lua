-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘 Blip-Toggler
-- This module spawns an NPC that toggles several predefined blips / map markers.
local npcEntity = nil
local markers = {}
local markersActive = false
local isTogglingMarkers = false

local Config = {
    BLIP_ID = 280,
    BLIP_COLOR = 3,
    BLIP_SIZE = 1.0,
    BLIP_NAME = "blip-manager",
    PREDEFINED_BLIPS = {
        {coords = vector3(1559.15, 6651.86, 1.61), name = "Point A", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(1795.24, 6583.31, 53.48), name = "Point B", blipId = 353, blipColor = 3, blipSize = 0.8}
        -- Add more predefined blips as needed...
    }
}

-- Toggle predefined markers
local function toggleMarkers()
    if isTogglingMarkers then return end
    isTogglingMarkers = true

    if markersActive then
        -- Deactivate markers
        for _, marker in ipairs(markers) do RemoveBlip(marker) end
        markers = {}
    else
        -- Activate markers
        for _, blipData in ipairs(Config.PREDEFINED_BLIPS) do
            local blip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)
            SetBlipSprite(blip, blipData.blipId)
            SetBlipColour(blip, blipData.blipColor)
            SetBlipScale(blip, blipData.blipSize)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blipData.name)
            EndTextCommandSetBlipName(blip)
            table.insert(markers, blip)
        end
    end

    markersActive = not markersActive
    isTogglingMarkers = false
end

-- Set up interaction with the NPC
local function setupInteraction(npc)
    exports.ox_target:addEntity(NetworkGetNetworkIdFromEntity(npc), {
        {
            name = "toggle_map_markers",
            label = "Toggle Blips",
            icon = "fa-map-marker-alt",
            onSelect = function()
                toggleMarkers()
            end
        }
    })
end

-- Load a model into memory
local function loadModel(model)
    if not IsModelInCdimage(model) or not IsModelValid(model) then return false end
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(500) end
    return true
end

-- Spawn the NPC
local function spawnNPC(data)
    if not data or not loadModel(data.model) then return end

    -- Spawn the NPC as a networked entity
    npcEntity = CreatePed(4, data.model, data.coords.x, data.coords.y, data.coords.z, data.heading, true, true)
    SetEntityAsMissionEntity(npcEntity, true, true)
    SetPedCanRagdoll(npcEntity, false)
    FreezeEntityPosition(npcEntity, true)

    -- Make the NPC invincible
    SetEntityInvincible(npcEntity, true) -- Prevent all damage
    SetBlockingOfNonTemporaryEvents(npcEntity, true) -- Prevent reactions to player actions
    SetPedCanBeTargetted(npcEntity, false) -- Prevent targeting by players

    -- Ensure the NPC is networked
    if not NetworkGetNetworkIdFromEntity(npcEntity) then
        NetworkRegisterEntityAsNetworked(npcEntity)
        while not NetworkGetNetworkIdFromEntity(npcEntity) do Wait(100) end
    end

    -- Create a blip for the NPC (if needed)
    local blip = AddBlipForEntity(npcEntity)
    SetBlipSprite(blip, Config.BLIP_ID)
    SetBlipColour(blip, Config.BLIP_COLOR)
    SetBlipScale(blip, Config.BLIP_SIZE)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BLIP_NAME)
    EndTextCommandSetBlipName(blip)

    setupInteraction(npcEntity) -- Set up interaction with the NPC
end

-- Listen for NPC spawn event from the server
RegisterNetEvent("blipToggler:spawnNPC")
AddEventHandler("blipToggler:spawnNPC", function(data)
    if npcEntity then DeleteEntity(npcEntity) end -- Prevent multiple NPCs
    spawnNPC(data)
end)

-- Request NPC data when the client joins
Citizen.CreateThread(function()
    TriggerServerEvent("blipToggler:requestNPC")
end)
-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘
