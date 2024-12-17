
-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘 Sell-Manager
-- This module allows predefined locations to be targeted and interacted with for reward.
local QBCore = exports['qb-core']:GetCoreObject()

local Config = {
    Rewards = {
        { Item = "gold", Probability = 17 }, -- 17% chance
        { Item = "rolex", Probability = 13 }, -- 13% chance
        { Item = "goldchain", Probability = 17 }, -- 17% chance
        { Item = "diamond", Probability = 15 }, -- 15% chance
        { Item = "diamond_ring", Probability = 12 }, -- 15% chance
        { Item = "lockpick", Probability = 22 } -- 15% chance
    },
    Cooldown = 60 -- Cooldown in seconds
}

local Cooldowns = {} -- Table to store cooldowns per player and interaction point

-- Helper function to get a random reward
local function getRandomReward()
    local roll = math.random(1, 100)
    local cumulativeProbability = 0

    for _, reward in ipairs(Config.Rewards) do
        cumulativeProbability = cumulativeProbability + reward.Probability
        if roll <= cumulativeProbability then
            return reward.Item
        end
    end

    return nil -- No reward if something goes wrong
end

-- Handle the reward attempt after minigame success
RegisterNetEvent('target-manager:attemptReward', function(nodeName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        return
    end

    -- Validate input
    if not nodeName then
        return
    end

    -- Initialize player cooldowns if not already set
    Cooldowns[src] = Cooldowns[src] or {}

    -- Check cooldown for the specific node
    local currentTime = os.time()
    Cooldowns[src][nodeName] = Cooldowns[src][nodeName] or 0 -- Ensure default value

    if Cooldowns[src][nodeName] > currentTime then
        local remainingTime = Cooldowns[src][nodeName] - currentTime
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = ('This node is on cooldown. Try again in %d seconds.'):format(remainingTime)
        })
        return
    end

    -- Set cooldown for this node
    Cooldowns[src][nodeName] = currentTime + Config.Cooldown

    -- Reward logic
    local rewardItem = getRandomReward()
    if rewardItem then
        -- Check if the player can carry the item
        if Player.Functions.AddItem(rewardItem, 1) then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = ('You found a %s!'):format(rewardItem)
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = 'You cannot carry more items.'
            })
        end
    else
        -- Notify the player that they found nothing
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'You found nothing.'
        })
    end
end)

--𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘