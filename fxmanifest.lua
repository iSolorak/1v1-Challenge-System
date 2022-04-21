-- Resource Metadata
fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'Challenge'
description '1v1 challenge'
version '1.0.0'

-- What to run
client_scripts {
    'client.lua',
    '@es_extended/locale.lua',
    '@simplepassive',
	'config.lua'
   
}
server_script {
    '@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
    
    'server.lua',
    '@simplepassive',
	'config.lua'
    
}

