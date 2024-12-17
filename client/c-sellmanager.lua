
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
    PedLocations = { -- Predefined ped spawn locations
        {
            coords = vector3(208.91, -937.77, 23.14), --Location
            heading = 225.0, --Rotation
            model = "s_m_m_ammucountry", --Ped Model
            freeze = false, --Freeze Ped
            walkTo = vector3(236.72, -904.2, 27.99), --Cleanup Sell
            animation = { dict = "move_m@drunk@moderatedrunk", name = "walk" } --Ped Animation
        },
        {
            coords = vector3(457.82, -1498.12, 27.19), --Location
            heading = 112.91, --Rotation
            model = "g_m_m_chemwork_01", --Ped Model
            freeze = false, --Freeze Ped
            walkTo = vector3(464.67, -1512.7, 33.54), --Cleanup Sell
            animation = { dict = "move_m@drunk@moderatedrunk", name = "walk" } --Ped Animation
        },
        {
            coords = vector3(-258.77, -973.73, 30.22), --Location
            heading = 203.0, --Rotation
            model = "cs_barry", --Ped Model
            freeze = false, --Freeze Ped
            walkTo = vector3(-270.75, -959.08, 30.42), --Cleanup Sell
            animation = { dict = "move_m@drunk@moderatedrunk", name = "walk" } --Ped Animation
        },
        {
            coords = vector3(1418.72, -1502.53, 59.35), --Location
            heading = 155.0, --Rotation
            model = "a_m_m_hillbilly_02", --Ped Model
            freeze = false, --Freeze Ped
            walkTo = vector3(1409.05, -1487.02, 59.66), --Cleanup Sell
            animation = { dict = "move_m@drunk@moderatedrunk", name = "walk" } --Ped Animation
        },
        {
            coords = vector3(2491.38, -434.79, 91.99), --Location
            heading = 182.0, --Rotation
            model = "cs_prolsec_02", --Ped Model
            freeze = false, --Freeze Ped
            walkTo = vector3(2477.49, -421.65, 92.74), --Cleanup Sell
            animation = { dict = "move_m@drunk@moderatedrunk", name = "walk" } --Ped Animation
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
        TriggerEvent('ox_lib:notify', { type = 'error', description = 'You have no items to sell.' })
        return
    end

    local input = exports.ox_lib:inputDialog('Sell Items', {
        { name = 'item', label = 'Item', type = 'select', options = itemsForSale },
        { name = 'quantity', label = 'Quantity', type = 'number', min = 1, default = 1 }
    })

    -- Updated validation for input
    if input and #input == 2 then
        local selectedItem = input[1] -- First value is the item
        local selectedQuantity = tonumber(input[2]) -- Second value is the quantity

        if selectedItem and selectedQuantity and selectedQuantity > 0 then
            TriggerServerEvent('sell-manager:processSale', selectedItem, selectedQuantity)
            cleanupPed(Config.PedLocations[math.random(#Config.PedLocations)]) -- Clean up the NPC after a sale
            return
        end
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
end

-- Listen for item use to spawn ped
AddEventHandler('ox_inventory:usedItem', function(item)
    if item == Config.SpawnItem then
        spawnPed()
    end
end)

--𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘
