fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script {
	"@ox_lib/init.lua",
	"language.lua",
	'config.lua'
}
shared_script '@ox_lib/init.lua'
server_script 'server/*.lua'
client_script 'client/*.lua'