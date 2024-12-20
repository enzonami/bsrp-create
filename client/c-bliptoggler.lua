-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘 Blip-Toggler
-- This module spawns an NPC that toggles several predefined blips / map markers.
local npcEntity
local markers = {}
local markersActive = false

local Config = {
    BLIP_ID = 280,
    BLIP_COLOR = 3,
    BLIP_SIZE = 1.0,
    BLIP_NAME = "blip-manager",
    PREDEFINED_BLIPS = {
        {coords = vector3(1559.15, 6651.86, 1.61), name = "Point A", blipId = 353, blipColor = 3, blipSize = 0.8},
        {coords = vector3(1795.24, 6583.31, 53.48), name = "Point B", blipId = 353, blipColor = 3, blipSize = 0.8}
    }
}

local function toggleMarkers()
    if markersActive then
        for _, marker in ipairs(markers) do RemoveBlip(marker) end
        markers = {}
    else
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
end

local function setupInteraction(npc)
    exports.ox_target:addEntity(NetworkGetNetworkIdFromEntity(npc), {
        {
            name = "toggle_map_markers",
            label = "Toggle Blips",
            icon = "fa-map-marker-alt",
            onSelect = toggleMarkers
        }
    })
end

local function spawnNPC(data)
    RequestModel(data.model)
    while not HasModelLoaded(data.model) do Wait(100) end

    npcEntity = CreatePed(4, data.model, data.coords.x, data.coords.y, data.coords.z, data.heading, true, true)
    SetEntityAsMissionEntity(npcEntity, true, true)
    SetPedCanRagdoll(npcEntity, false)
    FreezeEntityPosition(npcEntity, true)
    SetEntityInvincible(npcEntity, true)
    SetBlockingOfNonTemporaryEvents(npcEntity, true)
    SetPedCanBeTargetted(npcEntity, false)

    local blip = AddBlipForEntity(npcEntity)
    SetBlipSprite(blip, Config.BLIP_ID)
    SetBlipColour(blip, Config.BLIP_COLOR)
    SetBlipScale(blip, Config.BLIP_SIZE)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BLIP_NAME)
    EndTextCommandSetBlipName(blip)

    setupInteraction(npcEntity)
end

RegisterNetEvent("blipToggler:spawnNPC")
AddEventHandler("blipToggler:spawnNPC", function(data)
    if npcEntity then DeleteEntity(npcEntity) end
    spawnNPC(data)
end)

Citizen.CreateThread(function()
    TriggerServerEvent("blipToggler:requestNPC")
end)
-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘
