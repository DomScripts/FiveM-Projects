fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
	"@ox_lib/init.lua",
	'config.lua',
	"language.lua"
}

client_scripts {
	'cl-groups.lua',
    'client.lua',
}

server_scripts {
	'sv-groups.lua',
	'server.lua',
}