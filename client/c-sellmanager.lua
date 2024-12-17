
-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘 Sell-Manager
-- This module spawns a predefined ped via a custom item that sells listed items.
local Config = {
    SpawnItem = "sell_token", -- Item to spawn the ped
    SellableItems = { -- Items that can be sold
        ["gold"] = { price = 1000, max = 1 },
        ["rolex"] = { price = 300, max = 1 },
        ["diamond"] = { price = 250, max = 3 },
        ["diamond_ring"] = { price = 300, max = 1 },
        ["goldchain"] = { price = 120, max = 5 }
    },
    Notifications = {
        PedSpawned = { type = 'info', description = 'A buyer has been summoned. Approach them to negotiate your deal.' },
        OpenSellUI = { type = 'info', description = 'You are about to sell your shit. Be careful!' }
    },
    PedLocations = { -- Predefined ped spawn locations
        {
            coords = vector3(208.91, -937.77, 23.14), heading = 225.0, model = "s_m_m_ammucountry", freeze = false,
            walkTo = vector3(236.72, -904.2, 27.99), animation = { dict = "move_m@drunk@moderatedrunk", name = "walk" }
        },
        {
            coords = vector3(457.82, -1498.12, 27.19), heading = 112.91, model = "g_m_m_chemwork_01", freeze = false,
            walkTo = vector3(464.67, -1512.7, 33.54), animation = { dict = "move_m@drunk@moderatedrunk", name = "walk" }
        },
        {
            coords = vector3(-258.77, -973.73, 30.22), heading = 203.0, model = "cs_barry", freeze = false,
            walkTo = vector3(-270.75, -959.08, 30.42), animation = { dict = "move_m@drunk@moderatedrunk", name = "walk" }
        },
        {
            coords = vector3(1418.72, -1502.53, 59.35), heading = 155.0, model = "a_m_m_hillbilly_02", freeze = false,
            walkTo = vector3(1409.05, -1487.02, 59.66), animation = { dict = "move_m@drunk@moderatedrunk", name = "walk" }
        },
        {
            coords = vector3(2491.38, -434.79, 91.99), heading = 182.0, model = "cs_prolsec_02", freeze = false,
            walkTo = vector3(2477.49, -421.65, 92.74), animation = { dict = "move_m@drunk@moderatedrunk", name = "walk" }
        }
    }
}

local CurrentPed, CurrentBlip, CurrentZone

-- Function to clean up the NPC with animation and walk to a predefined position
local function cleanupPed(pedConfig)
    if CurrentPed then

        -- Play predefined animation, if any
        if pedConfig.animation then
            RequestAnimDict(pedConfig.animation.dict)
            while not HasAnimDictLoaded(pedConfig.animation.dict) do Wait(100) end
            TaskPlayAnim(CurrentPed, pedConfig.animation.dict, pedConfig.animation.name, 8.0, -8.0, -1, 1, 0, false, false, false)
        end

        -- Make the NPC walk to the predefined position
        if pedConfig.walkTo then
            TaskGoToCoordAnyMeans(CurrentPed, pedConfig.walkTo.x, pedConfig.walkTo.y, pedConfig.walkTo.z, 1.0, 0, 0, 786603, 0)
            local start = GetGameTimer()
            while #(GetEntityCoords(CurrentPed) - pedConfig.walkTo) > 1.0 and GetGameTimer() - start < 10000 do
                Wait(500) -- Wait for the NPC to reach the position
            end
        end

        -- Cleanup NPC
        DeleteEntity(CurrentPed)
        CurrentPed = nil
        RemoveBlip(CurrentBlip)
        exports.ox_target:removeZone(CurrentZone)
    end
end

-- Function to open sell UI
local function openSellUI()
    local itemsForSale = {}

    -- Fetch only relevant items from the inventory
    for name, config in pairs(Config.SellableItems) do
        local count = exports.ox_inventory:Search('count', name)
        if count and count > 0 then
            table.insert(itemsForSale, {
                name = name,
                label = name,
                value = name,
                count = count,
                max = config.max
            })
        end
    end

    if #itemsForSale == 0 then
        exports.ox_lib:notify({
            type = 'error',
            description = 'You have no items to sell.'
        })
        return
    end

    local notification = Config.Notifications.OpenSellUI
    if notification then
        exports.ox_lib:notify(notification)
    end

    local input = exports.ox_lib:inputDialog('Sell Items', {
        { name = 'item', label = 'Item', type = 'select', options = itemsForSale },
        { name = 'quantity', label = 'Quantity', type = 'number', min = 1, default = 1 }
    })

    if input then
        TriggerServerEvent('sell-manager:processSale', input.item, input.quantity)
        cleanupPed(Config.PedLocations[math.random(#Config.PedLocations)]) -- Clean up the NPC after a sale
    end
end

-- Function to spawn ped
local function spawnPed()
    if CurrentPed then
        cleanupPed(Config.PedLocations[math.random(#Config.PedLocations)]) -- Clean up the current NPC
    end

    local pedConfig = Config.PedLocations[math.random(#Config.PedLocations)]
    local model = GetHashKey(pedConfig.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(100) end

    CurrentPed = CreatePed(4, model, pedConfig.coords, pedConfig.heading, false, true)

    -- Set NPC freeze status based on the configuration
    FreezeEntityPosition(CurrentPed, pedConfig.freeze or false)
    SetEntityInvincible(CurrentPed, true)
    SetBlockingOfNonTemporaryEvents(CurrentPed, true)

    CurrentBlip = AddBlipForCoord(pedConfig.coords)
    SetBlipSprite(CurrentBlip, 1)
    SetBlipColour(CurrentBlip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Sell Ped")
    EndTextCommandSetBlipName(CurrentBlip)

    CurrentZone = exports.ox_target:addSphereZone({
        coords = pedConfig.coords,
        radius = 2.0,
        options = {
            {
                name = 'sell_items',
                label = 'Hustle Buyer',
                icon = 'fa-solid fa-money-bill',
                onSelect = function()
                    openSellUI()
                end
            }
        }
    })

    local notification = Config.Notifications.PedSpawned
    if notification then
        exports.ox_lib:notify(notification)
    end
end

-- Listen for item use to spawn ped
AddEventHandler('ox_inventory:usedItem', function(item)
    if item == Config.SpawnItem then
        spawnPed()
    end
end)

--𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘
