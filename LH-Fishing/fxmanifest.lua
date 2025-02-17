fx_version "cerulean"
game "gta5"
version "0.0.1"
lua54 "yes"
author "github.com/DomScripts"

shared_script {
    "@ox_lib/init.lua",
    "config.lua",
    "language.lua"
}

client_script {
    "cl-functions.lua",
    "client.lua"
}

server_script {
    "@mysql-async/lib/MySQL.lua",
    "@oxmysql/lib/MySQL.lua",
    "sv-functions.lua",
    "server.lua",
}