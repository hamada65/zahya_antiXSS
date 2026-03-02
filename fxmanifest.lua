fx_version 'cerulean'
game 'gta5'

name 'zahya_antiXSS'
description 'Anti-XSS protection - overrides SendNUIMessage with sanitizer'
version '1.0.0'

files {
    'checker.lua',
}

server_scripts {
    'server/command.js',
}
