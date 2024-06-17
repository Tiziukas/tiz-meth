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
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/**.lua',
}

dependencies {
    'clm_ProgressBar',
    'ox_lib',
    'ox_inventory'
}