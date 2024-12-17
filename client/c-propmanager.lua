
-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘 Prop-Manager
-- This module spawns a list of predefined props / models at predefined locations.
local PropManager = {}

local Config = {
    Props = { -- List of props to spawn

    --Cache Hunting
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(1559.15, 6651.86, 1.61), --Location
            Heading = 0.0 --Rotation
        },
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(1795.24, 6583.31, 53.48), --Location
            Heading = 0.0 --Rotation
        },
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(2157.97, 6371.01, 184.29), --Location
            Heading = 0.0 --Rotation
        },
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(2751.84, 6543.07, 0.72), --Location
            Heading = 0.0 --Rotation
        },
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(2828.03, 5979.24, 347.15), --Location
            Heading = 0.0 --Rotation
        },
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(2909.53, 5474.84, 184.65), --Location
            Heading = 0.0 --Rotation
        },
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(3444.38, 5175.65, 3.76), --Location
            Heading = 0.0 --Rotation
        },
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(3612.79, 5024.97, 10.35), --Location
            Heading = 0.0 --Rotation
        },
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(3197.62, 4602.26, 174.79), --Location
            Heading = 0.0 --Rotation
        },
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(3937.93, 4387.37, 15.49), --Location
            Heading = 0.0 --Rotation
        },
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(3287.04, 3140.41, 252.53), --Location
            Heading = 0.0 --Rotation
        },
        {
            Model = "xm_prop_x17_chest_closed", --https://gta-objects.xyz/objects
            Position = vector3(3464.03, 2592.33, 18.34), --Location
            Heading = 0.0 --Rotation
        }
    }
}

-- Table to store references to spawned props
local SpawnedProps = {}

-- Function to spawn a prop
function PropManager.spawnProp(model, position, heading)
    local modelHash = GetHashKey(model)

    -- Verify model existence
    if not IsModelInCdimage(modelHash) then
        return
    end

    -- Load the model
    RequestModel(modelHash)
    local waitCounter = 0
    while not HasModelLoaded(modelHash) and waitCounter < 500 do
        Wait(10)
        waitCounter = waitCounter + 1
    end

    if not HasModelLoaded(modelHash) then
        return
    end

    -- Create the object
    local prop = CreateObject(modelHash, position.x, position.y, position.z, false, false, false)
    if not DoesEntityExist(prop) then
        return
    end

    SetEntityHeading(prop, heading)
    FreezeEntityPosition(prop, true)

    -- Store reference for cleanup
    table.insert(SpawnedProps, prop)
end

-- Function to cleanup all spawned props
function PropManager.cleanupProps()
    for _, prop in ipairs(SpawnedProps) do
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
    end
    SpawnedProps = {}
end

-- Initialize Props
function PropManager.initialize()
    for _, prop in ipairs(Config.Props) do
        PropManager.spawnProp(prop.Model, prop.Position, prop.Heading)
    end
end

-- Cleanup props on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PropManager.cleanupProps()
    end
end)

-- Automatically initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PropManager.initialize()
    end
end)

return PropManager

--𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘