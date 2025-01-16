fx_version 'adamant'

game 'gta5'

description 'Mechanic job'
lua54 'yes'
version '1.0'

shared_scripts {
    '@es_extended/imports.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'server/main.lua',
    'server/modules/billing.lua',
    'server/modules/npcJob.lua',
    'server/modules/repairKit.lua',
    'server/modules/tyreKit.lua',
    'server/modules/props.lua',
    'npcLocations.lua'

}

client_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'client/main.lua',
    'client/modules/billing.lua',
    'client/modules/cloakroom.lua',
    'client/modules/npcJob.lua',
    'client/modules/repairKit.lua',
    'client/modules/tyreKit.lua',
    'client/modules/props.lua',
}

dependencies {
    'es_extended',
    'esx_billing'
}
