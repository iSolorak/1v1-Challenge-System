ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local currentlyplaying = {}
local challengerid = {}
local challengedid = {}
local selectedmaps = {}
local newcompareid = {}
local id1 = nil
local id2 = nil




ESX.RegisterServerCallback('checkplayer', function(src,cb,targetid,coords) 
 
 
 if contains(GetPlayers(),targetid) == true then  
  
  if contains(currentlyplaying,targetid) == true then 
    cb('ingame') 
  else 
    table.insert(challengerid,src)
    table.insert(challengedid,targetid)
    cb('outgame')   
    TriggerClientEvent('request',targetid,coords,src)    
  end
else print("player not online") -- Add it to elseif so I can put parameter if the target id is the same as the source id  (elseif targetid == src then ShowNotif('You cannot challenge yourself'))
end
 
 
 
 end)
--Handles the state of the player playing or not
RegisterServerEvent('newstartgame') -- Get the player ID's challenged and challenger 
AddEventHandler('newstartgame',function(id1,id2,coords)  --id1 source , id2 targeted
  print("This is the id's "..id1,id2)
 if contains(GetPlayers(),id2) == true then   
  if contains(newcompareid,id2)  == false then 
 --code for when not playing
   -- TriggerEvent('newgamestate',id1,id2)
    TriggerClientEvent('request',id2,id1,id2,coords)
  else print("currently playing")
  end
else TriggerClientEvent('esx:showNotification', source,"Player not online") -- If the player is not found get notified
end
end)


--Handles the creation of the match enviroment 
RegisterServerEvent('newgamestate') --Triggers after the check function in order to create the enviroment for the beggining of the match
AddEventHandler('newgamestate',function(id1,id2)  
  table.insert(newcompareid,tostring(id1))
  table.insert(newcompareid,id2) 
  TriggerClientEvent('esx:showNotification', id1,"Challenge Accepted")
  TriggerClientEvent('esx:showNotification', id2,"Challenge Accepted")
  TriggerClientEvent('newgamestateclient',tonumber(id1),id2)
  TriggerClientEvent('newgamestateclient',tonumber(id2),id1)
  

end)
--Handles kills
RegisterServerEvent('newaddkill') --Triggers after the check function in order to create the enviroment for the beggining of the match
AddEventHandler('newaddkill',function(id)  
  TriggerClientEvent('newaddkillc',id)
  

end)

--Handles clearlist
RegisterServerEvent('newclearlist2')
AddEventHandler('newclearlist2',function(id)  
  
for k,v in pairs (newcompareid) do 
  print(v.." This is the V")

  if v == tostring(source) then  
  table.remove(newcompareid,k)
  print(v)
end
end


end)
--Handles anticheat
RegisterServerEvent('anticheat')
AddEventHandler('anticheat',function(id,kills)
TriggerClientEvent('anticheatc',id,kills)

end)

--Handles Player Left

AddEventHandler('playerDropped', function (reason)
  local _source = source
  print('Player ' .. GetPlayerName(_source) .. ' dropped (Reason: ' .. reason .. ')')
  TriggerEvent('newclearlist2',_source)
  for k,v in pairs(newcompareid) do 
    TriggerClientEvent('droppedplayer',v,_source)
    end




end)


RegisterServerEvent('far')
AddEventHandler('far',function(id,text)

  TriggerClientEvent('esx:showNotification', id, text)
  

end)


function indexcheck(list1,list2,value1,value2) --Function created to check if the values have the same indexes
  local index1 = 0
  local index2  = 0 
  for k,v in pairs(list1)do
    if v == value1 then 
         index1 = k 
        -- print(k)
    end 
  end

  for k,v in pairs(list2)do
    if v == value2 then 
        index2 = k
        print(k)
    end 
  end

  if index1 == index2 then 
    return true
  else print(index1)
    print(index2)
    return false
  end


end


 

ESX.RegisterServerCallback('mapselector', function(src,cb,id) -- Checks what maps are available 
  local freegame = {}  
 for k,v in pairs (Config.Zones)do     
   if v.ingame == false then 
    table.insert(freegame,v)
    print(contains(currentlyplaying,src))
    
    freegame[1].ingame = true 
   
  
  end
end
  if #freegame > 0 then 
    TriggerEvent('idgame',freegame[1].id)
    cb('ok')
    
  else cb('nogame')
  end

 
 
 end)
 RegisterServerEvent('idgame')
 AddEventHandler('idgame',function(game)
table.insert(selectedmaps,game)
print(json.encode(selectedmaps))
  for k,v in pairs(challengedid) do 
    for i,j in pairs(challengerid) do 
      if indexcheck(challengedid,challengerid,v,j) then 
        TriggerClientEvent('setgame',v,v)
        TriggerClientEvent('setgame',j,v)
        print(j.." This is the J ")
        print(v.." This is the V")
        
        
      end
    end
  end


end)






ESX.RegisterServerCallback('teamcheck', function(src,cb,team)

  -- Check if player already in team
  local teamcheck1 = contains(allplayers,src)
  if teamcheck1 == false  then   -- If player not found check the team if full then add him 
 
    if team == "red" and #red < 2  then 
      cb("join")
      table.insert(red,src)
      table.insert(allplayers,src)
      
    elseif team =="red" and #red ==1 then 
      cb("full")
    elseif team == "blue" and #blue < 2  then 
        cb("join")
        table.insert(blue,src)
        table.insert(allplayers,src)
     
      elseif team =="blue" and #blue ==1 then 
        cb("full")
   
    end 
  elseif teamcheck1 == true then  -- If player found already in team don't add him anywhere display the message to the client 
    cb("already")
 
  end



    

end)

RegisterServerEvent('clearlist')
AddEventHandler('clearlist',function()
  print("Cleared")
  local _source = source

  if redkills > bluekills then 
    TriggerClientEvent('esx:showNotification', _source, 'Red Team Won')
  elseif redkills <bluekills then 
    TriggerClientEvent('esx:showNotification', _source, 'Blue Team Won')
  elseif redkills == bluekills then 
    TriggerClientEvent('esx:showNotification', _source, 'Draw')
  end


  for k,v in pairs (blue) do 
    
    table.remove(blue,k)
  end
  for k,v in pairs (red) do 
    
    table.remove(red,k)
  end 

  for k,v in pairs (allplayers) do 
    
    table.remove(allplayers,k)
  end 
  redkills = 0 
  bluekills = 0 

end)

RegisterServerEvent('addkillserver')
AddEventHandler('addkillserver',function(team)
if team == "red" then 
  redkills = redkills +1 
elseif team == "blue" then 
  bluekills = bluekills + 1 
end



end)


function contains(list, x)  -- check if the player has joined the gamemode 
	for _, v in pairs(list) do
		if v == x then  return true end
	end
	return false
end





RegisterServerEvent('debugg')
AddEventHandler('debugg',function()

print(#jplayersb.."This is the blue team players")
print(#jplayersr.."This is the read team players")
print(#allplayers.."This is all players joined")



end)

RegisterServerEvent('checkmatch')
AddEventHandler('checkmatch',function()
print(#jplayersr)
  
  if #allplayers==1 then --and  #jplayersb ==1 then 
      print("Match started")
      print(redkills)
      print(bluekills)
      for m,v in pairs (jplayersr) do
        TriggerClientEvent('teleportsteams', v, "red",true)
      end

      for k,j in pairs (jplayersb) do
        TriggerClientEvent('teleportsteams', j, "blue",true)
      end
      
      TriggerEvent('startmatch')
     -- xPlayer.addWeapon("weapon_raycarbine", 100)
  
  else TriggerClientEvent('drawhud',source,"Wait for the match to begin")
    end
  

end)



RegisterServerEvent('checkkills')
AddEventHandler('checkkills',function (id)
 
local ttb = contains(jplayersb,id)
local ttr = contains(jplayersr,id)
local _source = source
local xPlayer = ESX.GetPlayerFromId(_source)
  if  ttr == true then
    redkills = redkills +1
    print(redkills.."Blue Kills")
    TriggerClientEvent("respawn",id,"red")


  elseif ttb == true then 
   
    bluekills = bluekills +1
    print(bluekills.."Red Kills")
    TriggerClientEvent("respawn",id,"blue")
  end



end)


--[[RegisterServerEvent('teamaddred')   --TEAM ADD
AddEventHandler('teamaddred',function(id)
  local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

local tt =contains(jplayersr,id)

if tt == true then 
  TriggerClientEvent('esx:showNotification', _source, 'Already in a team')

elseif tt == false then 
  print("Player Joined the gamemode"..id)
  TriggerClientEvent('esx:showNotification', _source, 'You have been added to team Red')
  table.insert(jplayersr,id)
  table.insert(allplayers,id)
  TriggerEvent('checkmatch')
--  TriggerClientEvent('teleportsteams', _source, "red",true)
end







end)


RegisterServerEvent('teamaddblue')
AddEventHandler('teamaddblue',function(id)
  local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

local tt =contains(jplayersb,id)

if tt == true then 
  TriggerClientEvent('esx:showNotification', _source, 'Already in a team')

elseif tt == false then 
  print("Player Joined the gamemode"..id)
  TriggerClientEvent('esx:showNotification', _source, 'You have been added to team Blue')
 
  table.insert(jplayersb,id)
  table.insert(allplayers,id)
  TriggerEvent('checkmatch')
 -- TriggerClientEvent('teleportsteams', _source, "blue",true)
  
end







end)]]









function ExtractIdentifiers() --Function to get the license 

  for k,v in pairs(GetPlayerIdentifiers(source))do
    --print(v)
        
      if string.sub(v, 1, string.len("license:")) == "license:" then
        license = v
        local identifier = string.gsub(license, 'license:', '')
       -- print(identifier)
        return identifier
      end
    end
    
end

RegisterServerEvent('matchend')
AddEventHandler('matchend',function()
 --[[ for i, v in ipairs(allplayers) do allplayers[i] = 0 end
  for i, v in ipairs(jplayersb) do TriggerClientEvent('teleportsteams', i, "blue",false) jplayersb[i] = 0 print(json.encode(jplayersb)) end
  for i, v in ipairs(jplayersr) do TriggerClientEvent('teleportsteams', i, "red",false) jplayersr[i] = 0 print(json.encode(jplayersr))end]]
  print("Match ended")
  for k,v in pairs (allplayers) do 

    print(v.."THIS IS THE ALL ENDED PLAYERS")
    if redkills > bluekills then 
      TriggerClientEvent('esx:showNotification', v, 'Red team won')
      redkills = 0
      bluekills =0
    elseif redkills < bluekills then 
      TriggerClientEvent('esx:showNotification',v, 'Blue teamwon team won')
      redkills = 0
      bluekills =0
    end
  
    table.remove(allplayers,k)
  end
  for k,v in pairs (jplayersr) do 
    TriggerClientEvent('teleportsteams', v, "red",false)
    table.remove(jplayersr,k)
  end
  for k,v in pairs (jplayersb) do 
    TriggerClientEvent('teleportsteams', v, "blue",false)
    table.remove(jplayersb,k)
  end
 



end)



RegisterServerEvent('startmatch')
AddEventHandler('startmatch',function()
  local _source = source
  for k,v in pairs(allplayers) do 
   
  print("THE MATCH HAS STARTED")
    print(v)
  TriggerClientEvent('timer420',v)

  end
end) 