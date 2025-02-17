fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script {
	"@ox_lib/init.lua",
	"shared/*.lua"
}
server_script {
	"esx/esx_server.lua",
	"qb/qb_server.lua",
	"main/sv_main.lua",
}
client_script {
	"esx/esx_client.lua",
	"qb/qb_client.lua",
	"main/cl_main.lua",
}

-- escrow_ignore {
-- 	"shared/config.lua",
-- 	"shared/language.lua",
--   }