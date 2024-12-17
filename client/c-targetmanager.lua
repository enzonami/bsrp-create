
-- 𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘 Sell-Manager
-- This module allows predefined locations to be targeted and interacted with for reward.
local Config = {
    InteractionPoints = {
        {
            Interaction = {
                Position = vector3(1559.15, 6651.86, 1.61), --Location
                Radius = 3.0, --Target radius
                InteractionName = "1" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@heists@prison_heistig1_p1_guard_checks_bus",
                Name = "loop",
                Duration = 5000
            },
            Minigame = {
                Keys = {38, 47, 311},
                Timeout = 5000
            }
        },
        {
            Interaction = {
                Position = vector3(1795.24, 6583.31, 53.48), --Location
                Radius = 4.0, --Target radius
                InteractionName = "2" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@mp_player_intmenu@key_fob@",
                Name = "fob_click",
                Duration = 4000
            },
            Minigame = {
                Keys = {45, 49, 19},
                Timeout = 7000
            }
        },
        {
            Interaction = {
                Position = vector3(2157.97, 6371.01, 184.29), --Location
                Radius = 4.0, --Target radius
                InteractionName = "3" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@mp_player_intmenu@key_fob@",
                Name = "fob_click",
                Duration = 4000
            },
            Minigame = {
                Keys = {45, 49, 19},
                Timeout = 7000
            }
        },
        {
            Interaction = {
                Position = vector3(2751.84, 6543.07, 0.72), --Location
                Radius = 4.0, --Target radius
                InteractionName = "4" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@mp_player_intmenu@key_fob@",
                Name = "fob_click",
                Duration = 4000
            },
            Minigame = {
                Keys = {45, 49, 19},
                Timeout = 7000
            }
        },
        {
            Interaction = {
                Position = vector3(2828.03, 5979.24, 347.15), --Location
                Radius = 4.0, --Target radius
                InteractionName = "5" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@mp_player_intmenu@key_fob@",
                Name = "fob_click",
                Duration = 4000
            },
            Minigame = {
                Keys = {45, 49, 19},
                Timeout = 7000
            }
        },
        {
            Interaction = {
                Position = vector3(2909.53, 5474.84, 184.65), --Location
                Radius = 4.0, --Target radius
                InteractionName = "6" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@mp_player_intmenu@key_fob@",
                Name = "fob_click",
                Duration = 4000
            },
            Minigame = {
                Keys = {45, 49, 19},
                Timeout = 7000
            }
        },
        {
            Interaction = {
                Position = vector3(3444.38, 5175.65, 3.76), --Location
                Radius = 4.0, --Target radius
                InteractionName = "7" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@mp_player_intmenu@key_fob@",
                Name = "fob_click",
                Duration = 4000
            },
            Minigame = {
                Keys = {45, 49, 19},
                Timeout = 7000
            }
        },
        {
            Interaction = {
                Position = vector3(3612.79, 5024.97, 10.35), --Location
                Radius = 4.0, --Target radius
                InteractionName = "8" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@mp_player_intmenu@key_fob@",
                Name = "fob_click",
                Duration = 4000
            },
            Minigame = {
                Keys = {45, 49, 19},
                Timeout = 7000
            }
        },
        {
            Interaction = {
                Position = vector3(3197.62, 4602.26, 174.79), --Location
                Radius = 4.0, --Target radius
                InteractionName = "9" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@mp_player_intmenu@key_fob@",
                Name = "fob_click",
                Duration = 4000
            },
            Minigame = {
                Keys = {45, 49, 19},
                Timeout = 7000
            }
        },
        {
            Interaction = {
                Position = vector3(3937.93, 4387.37, 15.49), --Location
                Radius = 4.0, --Target radius
                InteractionName = "10" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@mp_player_intmenu@key_fob@",
                Name = "fob_click",
                Duration = 4000
            },
            Minigame = {
                Keys = {45, 49, 19},
                Timeout = 7000
            }
        },
        {
            Interaction = {
                Position = vector3(3287.04, 3140.41, 252.53), --Location
                Radius = 4.0, --Target radius
                InteractionName = "11" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@mp_player_intmenu@key_fob@",
                Name = "fob_click",
                Duration = 4000
            },
            Minigame = {
                Keys = {45, 49, 19},
                Timeout = 7000
            }
        },
        {
            Interaction = {
                Position = vector3(3464.03, 2592.33, 18.34), --Location
                Radius = 4.0, --Target radius
                InteractionName = "12" --Each interaction name must be unique
            },
            Animation = {
                Dict = "anim@mp_player_intmenu@key_fob@",
                Name = "fob_click",
                Duration = 4000
            },
            Minigame = {
                Keys = {45, 49, 19},
                Timeout = 7000
            }
        }
    }
}

local function getControlName(control)
    local controlNames = {
        [38] = "E",
        [47] = "G",
        [311] = "K",
        [45] = "R",
        [49] = "G",
        [19] = "Alt"
    }
    return controlNames[control] or "Unknown"
end

if not exports.ox_target then
    return
end

for _, point in ipairs(Config.InteractionPoints) do
    exports.ox_target:addSphereZone({
        name = point.Interaction.InteractionName,
        coords = point.Interaction.Position,
        radius = point.Interaction.Radius,
        debug = false,
        options = {
            {
                name = point.Interaction.InteractionName,
                onSelect = function()
                    local interactionName = point.Interaction.InteractionName or "Unknown Interaction"
                    TriggerServerEvent('target-manager:attemptReward', interactionName)
                end,
                icon = 'fa-solid fa-treasure-chest', --Target icon
                label = 'Search Node' --Target text
            }
        }
    })
end

RegisterNetEvent('target-manager:playInteractionAnimation', function(point)
    local ped = PlayerPedId()
    RequestAnimDict(point.Animation.Dict)
    while not HasAnimDictLoaded(point.Animation.Dict) do
        Wait(0)
    end
    TaskPlayAnim(ped, point.Animation.Dict, point.Animation.Name, 8.0, -8.0, point.Animation.Duration, 1, 0, false, false, false)
    Wait(point.Animation.Duration)
    ClearPedTasksImmediately(ped)
end)

RegisterNetEvent('target-manager:playInteractionMinigame', function(point)
    local success = false
    local startTime = GetGameTimer()
    local keyToPress = point.Minigame.Keys[math.random(#point.Minigame.Keys)]
    local keyName = getControlName(keyToPress)

    TriggerEvent('ox_lib:notify', {
        type = 'inform',
        description = ('Press %s within %.1f seconds!'):format(keyName, point.Minigame.Timeout / 1000)
    })

    while GetGameTimer() - startTime < point.Minigame.Timeout do
        if IsControlJustPressed(1, keyToPress) then
            success = true
            break
        end
        Wait(0)
    end

    if success then
        TriggerEvent('target-manager:playInteractionAnimation', point)
        TriggerServerEvent('target-manager:attemptReward', point.Interaction.InteractionName)
    else
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            description = 'You failed to search the treasure.'
        })
    end
end)

--𝕭𝖑𝖆𝖈𝖐 𝕾𝖍𝖆𝖉𝖊𝖘