
-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘 Sell-Manager
-- This module spawns a predefined ped via a custom item that sells listed items.
local Config = {
    SellableItems = { -- Items that can be sold
        ["gold"] = { price = 1000, max = 1 },
        ["rolex"] = { price = 300, max = 1 },
        ["diamond"] = { price = 250, max = 3 },
        ["diamond_ring"] = { price = 300, max = 1 },
        ["goldchain"] = { price = 120, max = 5 }
    },
    MoneyItem = "money" -- Item used for rewards
}

RegisterNetEvent('sell-manager:processSale', function(itemName, quantity)
    local source = source
    local itemConfig = Config.SellableItems[itemName]

    -- Validate item and quantity
    if not itemConfig then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Invalid item selected.' })
        return
    end

    if quantity < 1 or quantity > itemConfig.max then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Invalid quantity selected.' })
        return
    end

    -- Check player's inventory
    local playerItem = exports.ox_inventory:Search(source, 'count', itemName)
    if not playerItem or playerItem < quantity then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Not enough items to sell.' })
        return
    end

    -- Process sale
    exports.ox_inventory:RemoveItem(source, itemName, quantity)
    local totalPayment = itemConfig.price * quantity
    exports.ox_inventory:AddItem(source, Config.MoneyItem, totalPayment)

    -- Notify success
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = string.format('Sold %d %s for $%d.', quantity, itemName, totalPayment)
    })
end)

--𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘
