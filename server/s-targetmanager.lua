
-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘 Sell-Manager
-- This module allows predefined locations to be targeted and interacted with for reward.

local QBCore = exports['qb-core']:GetCoreObject()

local Config = {
    Rewards = {
        { Item = "gold", Probability = 17 },
        { Item = "rolex", Probability = 13 },
        { Item = "goldchain", Probability = 17 },
        { Item = "diamond", Probability = 15 },
        { Item = "diamond_ring", Probability = 12 },
        { Item = "lockpick", Probability = 22 }
    },
    Cooldown = 60,
    XPForLevels = {
        [1] = 0,
        [2] = 100,
        [3] = 300,
        [4] = 600,
        [5] = 1000
    },
    XPGainPerInteraction = 50
}

local Cooldowns = {}

-- Helper function to calculate level
local function calculateLevel(xp)
    local level = 1
    for lvl, requiredXP in pairs(Config.XPForLevels) do
        if xp >= requiredXP then
            level = lvl
        else
            break
        end
    end
    return level
end

-- Get player XP and level from database
local function getPlayerXP(identifier)
    local result = exports.oxmysql:query_async('SELECT xp, level FROM player_experience WHERE identifier = ?', { identifier })
    if result[1] then
        return result[1].xp, result[1].level
    else
        exports.oxmysql:execute_async('INSERT INTO player_experience (identifier) VALUES (?)', { identifier })
        return 0, 1
    end
end

-- Update player XP and level
local function updatePlayerXP(identifier, xpGain)
    local currentXP, currentLevel = getPlayerXP(identifier)
    local newXP = currentXP + xpGain
    local newLevel = calculateLevel(newXP)
    exports.oxmysql:execute_async('UPDATE player_experience SET xp = ?, level = ? WHERE identifier = ?', { newXP, newLevel, identifier })
    return newXP, newLevel
end

-- Random reward with level modifier
local function getRandomReward(levelModifier)
    local roll = math.random(1, 100) + levelModifier
    print(("[DEBUG] Reward Roll: %d (Modifier: %d)"):format(roll, levelModifier))

    local cumulativeProbability = 0
    for _, reward in ipairs(Config.Rewards) do
        cumulativeProbability = cumulativeProbability + reward.Probability
        if roll <= cumulativeProbability then
            print(("[DEBUG] Reward Found: %s"):format(reward.Item))
            return reward.Item
        end
    end
    print("[DEBUG] No Reward Found")
    return nil
end

-- Handle reward attempts
RegisterNetEvent('target-manager:attemptReward', function(nodeName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not nodeName then return end

    local identifier = Player.PlayerData.citizenid
    local currentTime = os.time()

    Cooldowns[src] = Cooldowns[src] or {}
    Cooldowns[src][nodeName] = Cooldowns[src][nodeName] or 0

    if Cooldowns[src][nodeName] > currentTime then
        local remainingTime = Cooldowns[src][nodeName] - currentTime
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = ('Cooldown: %d seconds'):format(remainingTime) })
        return
    end

    Cooldowns[src][nodeName] = currentTime + Config.Cooldown

    local currentXP, currentLevel = getPlayerXP(identifier)
    local rewardModifier = currentLevel * 2
    local rewardItem = getRandomReward(rewardModifier)

    if rewardItem then
        local success = Player.Functions.AddItem(rewardItem, 1)
        print(("[DEBUG] Adding Item: %s - Success: %s"):format(rewardItem, tostring(success)))
        if success then
            TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = ('Found: %s'):format(rewardItem) })
        else
            TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Inventory full.' })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Found nothing.' })
    end

    local newXP, newLevel = updatePlayerXP(identifier, Config.XPGainPerInteraction)
    TriggerClientEvent('ox_lib:notify', src, { type = 'inform', description = ('XP: %d (Level %d)'):format(newXP, newLevel) })
end)

--𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘
