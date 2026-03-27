fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'boney-launder'
description 'Simple money wash script for Qbox'
author 'Boney'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'ox_inventory'
}