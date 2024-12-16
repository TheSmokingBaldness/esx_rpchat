fx_version 'adamant'

game 'gta5'
author 'ESX-Framework and Baldne55'

description 'Integrates the text roleplay chat.'
lua54 'yes'

version '1.0'
legacyversion '1.9.1'

shared_script '@es_extended/imports.lua'

server_scripts {
	'config.lua',
	'server/server.lua'
}

client_scripts {
	'config.lua',
	'client/client.lua'
}

dependency 'es_extended'
