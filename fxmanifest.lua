fx_version 'cerulean'
game 'gta5'
lua54 'yes'


client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua',
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}
--https://github.com/Byte-Labs-Studio/bl_ui
--https://github.com/d3MBA/d3MBA-lib/