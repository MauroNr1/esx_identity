fx_version 'adamant'

game 'gta5'

description 'ESX Identity'
lua54 'yes'
version '1.9.3'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'@ox_lib/init.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'locales/*.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}

dependency 'es_extended'