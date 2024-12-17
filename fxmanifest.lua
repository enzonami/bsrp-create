
fx_version 'cerulean'
games { 'gta5' }

lua54 'yes' -- Enables Lua 5.4 features

author 'Enzonami'
description 'Modular and feature-rich script package.'
version '1.0.0'

client_scripts {
    'client/c-propmanager.lua',
    'client/c-bliptoggler.lua',
    'client/c-targetmanager.lua',
    'client/c-sellmanager.lua'
}

server_scripts {
    'server/s-targetmanager.lua',
    'server/s-sellmanager.lua'
}
