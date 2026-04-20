fx_version 'cerulean'
game 'gta5'

name        'cocaine_script'
description 'drug system'
author      'al1qzx'
version     '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory',
}
