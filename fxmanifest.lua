fx_version 'cerulean'
games { 'gta5' }

author 'Tizas'

description 'Meth Van'

version '1.0.0'

lua54 'yes'

client_scripts {
    'client/client.lua'
}
server_script {
    'server/server.lua',
    'server/functions.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/**.lua',
}

escrow_ignore {
    'shared/**.lua',
    'client/client.lua',
    'server/server.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory'
}