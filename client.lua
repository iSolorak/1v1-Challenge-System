Config  = {}

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local ingame = false

local decline = false 
local team1 = {}
local team2 = {}
local oldcoords = {}
local id1 
local id2 
local kills1 = 0 
local kills2 = 0 
local leave = false
local eneymid = nil





RegisterCommand('chall',function(source, args, rawCommand) -- This command triggers server side actions 
    if ingame == false then
        if tostring(GetPlayerServerId(PlayerId())) ~= args[1] then 
    TriggerServerEvent('newstartgame',GetPlayerServerId(PlayerId()),args[1],GetEntityCoords(GetPlayerPed(-1))) -- If the gamestate is false
        else ESX.ShowHelpNotification("You cannot challenge yourself") 
    end 
    else ESX.ShowHelpNotification("Currently In Game")   
    end

end,false)
RegisterCommand('id',function(source, args, rawCommand) -- This command triggers server side actions 
    if ingame == false then
       -- --print(GetPlayerServerId(PlayerId()))
    
    else ESX.ShowHelpNotification("Currently In Game")    
    end

end,false)

RegisterNetEvent('newgamestateclient')
AddEventHandler('newgamestateclient',function(id)
ingame=true
eneymid = id
kills1 = 0
kills2 = 0
----print(eneymid)
TriggerEvent('timer420',20)

end)
Citizen.CreateThread(function() -- This is the game logic
    while true do 
    Citizen.Wait(0)
    while ingame do 
        Citizen.Wait(0)
        Citizen.Wait(1000)
        if IsEntityDead(GetPlayerPed(-1)) == 1 then 
           Citizen.Wait(500)
            kills1 = kills1 + 1
            ----print(kills1)
          
            TriggerServerEvent('newaddkill',eneymid)
            if coords == nil then 
                coords =   GetEntityCoords(GetPlayerPed(-1))
                tp(coords.x,coords.y)
                 oldcoords = coords
                --print(json.encode(oldcoords))
                else
                   tp(oldcoords.x,oldcoords.y)
                    --print(json.encode(oldcoords))
                end
            Citizen.Wait(1000)
            TriggerEvent('esx_ambulancejob:revive')
           -- Citizen.Wait(1000)
        end
    end
end



end)
RegisterNetEvent('newaddkillc')
AddEventHandler('newaddkillc',function()
Citizen.Wait(1000)
kills2 = kills2 + 1 
--print("This is your kills "..kills2)


end)



RegisterCommand('noplay',function(source, args, rawCommand)  -- This is the command for autodecline


   if args[1] == 'true' then 
    decline = true
   elseif args[1] =='false' then 
    decline = false
   end



end,false)

local coords =nil
local oldcoords 
RegisterCommand('gg',function(source, rawCommand)  -- This is the command for autodecline
    --print("GG")
    
    if coords == nil then 
    coords =   GetEntityCoords(GetPlayerPed(-1))
    tp(coords.x,coords.y)
     oldcoords = coords
    --print(json.encode(oldcoords))
    else
       tp(oldcoords.x,oldcoords.y)
        --print(json.encode(oldcoords))
    end
    
   

end,false)


function tp(x,y) -- TP to the ground  
    local newx = math.random(-5,5)
    local newy = math.random(-5,5)
    local divx = x - newx
    local divy = y - newy

    
    for height = 1, 1000 do 
        SetPedCoordsKeepVehicle(PlayerPedId(),divx,divy,height+0.0)
        
        local ztouch ,makis= GetGroundZFor_3dCoord(divx,divy,height+0.0)
        --print(ztouch,makis)
        if ztouch == 1 then 
            --print(ztouch,makis)
        SetPedCoordsKeepVehicle(PlayerPedId(),divx,divy,height+0.0)
        break
        end
        end
    
    
end









function contains(list, x)  -- check if the player has joined the gamemode 
	for _, v in pairs(list) do
		if v == x then  return true end
	end
	return false
end






RegisterNetEvent('request')
AddEventHandler('request',function(id1,id2,coords)
    if decline == false then       
                mymenu(id1,id2,coords)
                --print(id1.." ID1")
                --print(id2.." ID2")

    elseif decline == true then 
        ESX.ShowNotification('Someone Tried to challenge you but you have autodecline ON')
end

end)


function mymenu(id1,id2,coords)
   
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'teamselect',
        {
            title    = ('Accept Challenge??'),
            align = 'top-left',
            elements = {
                {label = 'Accept', value = 'accept'},
                {label = 'Decline', value = 'decline'},
            }
        },
        function(data, menu)
    
            if data.current.value == "accept" then
                if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),coords) < 5 then
                TriggerServerEvent('newgamestate',id1,id2)              
                 --   ingame = true
                else ESX.ShowHelpNotification('You got too far! getback')
                end
            
                --print("ok")
          
           
            
            
            ESX.UI.Menu.CloseAll()
    
           
          
            elseif data.current.value == 'back' then 
    
            ESX.UI.Menu.CloseAll()
            --ridemenu()
            end
            if data.current.value == "decline" then
            
                --TriggerServerEvent('checkitem',data.current.value) -- Send the team to the server
              --  ESX.TriggerServerCallback('teamcheck',data.current.value)
              ESX.TriggerServerCallback('teamcheck', function(ans)
                  
                if ans == "full" then 
                    ESX.ShowNotification(data.current.value .." team is full")
                elseif ans == "already" then 
                      ESX.ShowNotification("you already in team")
                    elseif ans == "join" then 
                    ESX.ShowNotification("You joined team ".. data.current.value)
                    local id = GetPlayerServerId(PlayerId())
                    table.insert(blue,id)
               
                end
        
        end, data.current.value)
                
                
                ESX.UI.Menu.CloseAll()
        
               -- ridemenu()
               
              
                elseif data.current.value == 'back' then 
        
                ESX.UI.Menu.CloseAll()
                --ridemenu()
                end
        
            menu.close()
            end,
        function(data, menu)
            menu.close()
        end
        )
    end






RegisterNetEvent('timer420')
AddEventHandler('timer420',function(timer)

   local time
        function setcountdown(x)
          time = GetGameTimer() + x*1000
        end
        function getcountdown()
          return math.floor((time-GetGameTimer())/1000)
        end
        setcountdown(10)
        
        while getcountdown() > 0 do
            Citizen.Wait(1)
            SetEntityInvincible(GetPlayerPed(-1),true)  
            DrawHudText("Cover Time: "..getcountdown(), {0,255,0,180},0.015,0.670,0.4,0.5)
           	
           
	   end
       SetEntityInvincible(GetPlayerPed(-1),false)  

        setcountdown(timer)
	
        while getcountdown() > 0 do
            Citizen.Wait(1)
            DrawHudText("Timer: "..getcountdown(), {0,255,0,180},0.015,0.670,0.4,0.5)
            DrawHudText("Enemy Kills "..kills1, {0,0,255,180},0.015,0.255,0.4,0.5)
            DrawHudText("Your Kills "..kills2, {255,0,0,180},0.9,0.255,0.4,0.5)
		
		
           
	   end
       setcountdown(5)
       while getcountdown() > 0 do
        Citizen.Wait(1)
        DrawHudText("Match Ended", {255,191,0,255},0.5,0.4,4.0,4.0)    
        SetEntityInvincible(GetPlayerPed(-1),true)      
   end
   SetEntityInvincible(GetPlayerPed(-1),false)  
   
    ingame = false
    --TriggerServerEvent('anticheat',eneymid,kills2)
    Citizen.Wait(500)
    if leave == true then 
        ShowAdvNotification("CHAR_MINOTAUR", "Match", "Winner", '~r~Match Cancelled')
       
    elseif leave == false then 
    if kills1 == kills2 then
    ShowAdvNotification("CHAR_MINOTAUR", "Match", "Winner", '~r~DRAW~o~ ')
    elseif kills2 > kills1 then 
        ShowAdvNotification("CHAR_MINOTAUR", "Match", "Winner", '~r~You~s~ WON.Kills:~o~ '..kills2.." Enemy kills:"..kills1)
    elseif kills2 < kills1 then 
        ShowAdvNotification("CHAR_MINOTAUR", "Match", "Winner", '~r~You~s~ LOST.Kills:~o~ '..kills2.." Enemy kills:"..kills1)
   
    end
end
    kills1 = 0 
    kills2 =0
    eneymid = nil
    id1 = nil 
    id2 = nil
    leave = false
    TriggerServerEvent('newclearlist2',GetPlayerServerId(PlayerId()))
    --print(eneymid)

end)
RegisterNetEvent('anticheatc')
AddEventHandler('anticheatc',function(kills)
    if kills ~= kills1 then 
        --print('Cheated')
    else --print('not cheated')
    end



end)
--Handles Leavers
RegisterNetEvent('droppedplayer')
AddEventHandler('droppedplayer',function(id)
    --print("dropped")
    if tostring(id) == tostring(eneymid) then 
        ShowAdvNotification("CHAR_MINOTAUR", "Match", "Winner", '~r~EnemyLeft you won the challenge~s~ ')        
        leave = true
        TriggerEvent('timer420',1)
        TriggerServerEvent('newclearlist2',GetPlayerServerId(PlayerId()))
        
    end


end)

function ShowAdvNotification(image, title, subtitle, text)
    SetNotificationTextEntry("STRING");
    AddTextComponentString(text);
    SetNotificationMessage(image, image, false, 0, title, subtitle);
    DrawNotification(false, true);
end





function DrawHudText(text,colour,coordsx,coordsy,scalex,scaley) --courtesy of driftcounter
    SetTextFont(7)
    SetTextProportional(7)
    SetTextScale(scalex, scaley)
    local colourr,colourg,colourb,coloura = table.unpack(colour)
    SetTextColour(colourr,colourg,colourb, coloura)
    SetTextDropshadow(0, 0, 0, 0, coloura)
    SetTextEdge(1, 0, 0, 0, coloura)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(coordsx,coordsy)
end



