ESX = nil

--[[
	Sn-Scripts
        Made by NICK#8338
	All rights reserved
]]

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)    




RegisterCommand("requestsearch", function(source ,args)
    if IsPedArmed(PlayerPedId(), 4) then
        local players = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 5)
        local data = {}
        local own_id = GetPlayerServerId(PlayerId())
        for k,v in pairs(players) do 
            if GetPlayerServerId(v) ~= own_id then 
                table.insert(data, {
                    label = GetPlayerServerId(v),
                    id = GetPlayerServerId(v)
                })
            end
        end
        if #data < 1 then return end
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'request_search', {
            title = "Fouilleer verzoek",
            align = "top-right",
            elements = data
        }, function(data, menu)
            TriggerServerEvent("sendrequest", data.current.id)
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    else
        exports["skeexsNotify"]:TriggerNotification({
            ['type'] = "info",
            ['message'] = "Je moet bewapend zijn voor deze functie.."
        })
    end
end)


RegisterNetEvent("getrequest")
AddEventHandler("getrequest", function(sender)
    being_asked()
    exports["skeexsNotify"]:TriggerNotification({
        ['type'] = "info",
        ['message'] = "De persoon met id " .. sender .. " wilt u doorzoeken, druk de k spier om het te accepteren en de h spier om het verzoek te weigeren"
    })
end)


RegisterNetEvent("requestaccepted")
AddEventHandler("requestaccepted", function(inventory , loadout, money, target)
    invData = {}

    table.insert(invData, {
        label = "Contant: " .. money,
        amount = money,
        type = "money"
    })

    for k,v in pairs(loadout) do 
        table.insert(invData, {
            label = v.name,
            ammo = v.ammo,
            weaponData = v,
            type = "weapon"
        })
    end

    for k,v in pairs(inventory) do 
        if v.count > 0 then
            table.insert(invData, {
                label = v.label .. " | " .. v.count .. "x",
                count = v.count,
                itemname = v.name,
                itemData = v,
                type = "item"
            })
        end
    end


    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'request_search', {
        title = "Fouilleer verzoek",
        align = "top-right",
        elements = invData
    }, function(data, menu)
        local type = data.current.type
        if type == "money" or type == "item" then
            dialog(function(x)
                TriggerServerEvent("request_pakaf", data.current, target, x)
            end)
        else
            TriggerServerEvent("request_pakaf", data.current, target, x)
        end
       
        menu.close()
    end, function(data, menu)
        menu.close()
    end)

end)


being_asked = function()
    Citizen.CreateThread(function()
        while true do 
            Wait(0)
            if IsControlJustReleased(0,311) then 
                TriggerServerEvent("acceptrequest")
                return
            end


            if IsControlJustReleased(0, 304) then 
                TriggerServerEvent("revokerequest")
                return
            end
        end
    end)
end

dialog = function(cb)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'model', {
        title = 'Aantal'
    }, function(data2, menu)

        local price = tonumber(data2.value)
        if price == nil then
            menu.close()
        elseif tonumber(price) <= 0 then 
            menu.close()
        else
            menu.close()
            cb(price)
        end
    end, function(data2,menu)
        menu.close()
    end)
end
