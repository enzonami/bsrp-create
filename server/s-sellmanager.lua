
-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘 Sell-Manager
-- Handles selling logic and inventory validation
local Config = {
    SellableItems = {
        ["gold"] = { price = 1000, max = 1 },
        ["rolex"] = { price = 300, max = 1 },
        ["diamond"] = { price = 250, max = 3 },
        ["diamond_ring"] = { price = 300, max = 1 },
        ["goldchain"] = { price = 120, max = 5 }
    },
    MoneyItem = "money",
    Notifications = {
        SaleProcessing = { type = 'info', description = 'Processing your sale...' },
        SaleCompleted = function(itemName, quantity, total)
            return {
                type = 'success',
                description = string.format('Sold %d %s for $%d.', quantity, itemName, total)
            }
        end,
        InsufficientItems = { type = 'error', description = 'Not enough items to sell.' },
        InvalidItem = { type = 'error', description = 'Invalid item selected.' },
        InvalidQuantity = { type = 'error', description = 'Invalid quantity selected.' }
    }
}

RegisterNetEvent('sell-manager:processSale', function(itemName, quantity)
    local source = source
    local itemConfig = Config.SellableItems[itemName]

    -- Notify invalid item
    if not itemConfig then
        local invalidItemNotification = Config.Notifications.InvalidItem
        if invalidItemNotification then
            TriggerClientEvent('ox_lib:notify', source, invalidItemNotification)
        end
        return
    end

    -- Notify invalid quantity
    if quantity < 1 or quantity > itemConfig.max then
        local invalidQuantityNotification = Config.Notifications.InvalidQuantity
        if invalidQuantityNotification then
            TriggerClientEvent('ox_lib:notify', source, invalidQuantityNotification)
        end
        return
    end

    -- Notify sale processing
    local processingNotification = Config.Notifications.SaleProcessing
    if processingNotification then
        TriggerClientEvent('ox_lib:notify', source, processingNotification)
    end

    -- Validate inventory and process sale
    local playerItem = exports.ox_inventory:Search(source, 'count', itemName)
    if not playerItem or playerItem < quantity then
        local insufficientItemsNotification = Config.Notifications.InsufficientItems
        if insufficientItemsNotification then
            TriggerClientEvent('ox_lib:notify', source, insufficientItemsNotification)
        end
        return
    end

    exports.ox_inventory:RemoveItem(source, itemName, quantity)
    local totalPayment = itemConfig.price * quantity
    exports.ox_inventory:AddItem(source, Config.MoneyItem, totalPayment)

    -- Notify sale completion
    local successNotification = Config.Notifications.SaleCompleted(itemName, quantity, totalPayment)
    if successNotification then
        TriggerClientEvent('ox_lib:notify', source, successNotification)
    end
end)

--𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘
