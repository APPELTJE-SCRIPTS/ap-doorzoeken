ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


request_data = {}

RegisterServerEvent("sendrequest")
AddEventHandler("sendrequest", function(id)
    local src = source

    if request_data[id] ~= nil then return end 

    request_data[id] = {
        target = id,
        sender = src
    }
    TriggerClientEvent("getrequest", id, src)
end)



RegisterServerEvent("acceptrequest")
AddEventHandler("acceptrequest", function()
    if request_data[source] then 
        TriggerClientEvent("requestaccepted", request_data[source].sender, ESX.GetPlayerFromId(source).getInventory(), ESX.GetPlayerFromId(source).getLoadout(), ESX.GetPlayerFromId(source).getMoney(), request_data[source].target)
        request_data[source] = nil
    else
        print("er is iets misgegaan...")
    end
end)


RegisterServerEvent("request_pakaf")
AddEventHandler("request_pakaf", function(data, id, amount)
    local type = data.type 
    local user = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(id)
    if not target then return end
    if type == "money" then 
        target.removeMoney(amount)
        user.addMoney(amount)
        TriggerClientEvent("notify:sendnotify", id, {
            ['type'] = "error",
            ['message'] = "De persoon naast u heeft ".. amount .. "euro van u afgenomen"
        })
        TriggerClientEvent("notify:sendnotify", source, {
            ['type'] = "error",
            ['message'] = "U heeft ".. amount .."euro afgenomen van " .. GetPlayerName(id)
        })
    elseif type == "item" then 
        local item = target.getInventoryItem(data.itemname)
        if item then 
            if item.count >= amount then 
                target.removeInventoryItem(data.itemname, amount)
                user.addInventoryItem(data.itemname, amount)
                TriggerClientEvent("notify:sendnotify", id, {
                    ['type'] = "error",
                    ['message'] = "De persoon naast u heeft ".. data.itemname .. " " .. amount .."x van u afgenomen"
                })
                TriggerClientEvent("notify:sendnotify", source, {
                    ['type'] = "error",
                    ['message'] = "U heeft ".. data.itemname .. " " .. amount .."x afgenomen van " .. GetPlayerName(id)
                })
            else
                TriggerClientEvent("notify:sendnotify", source, {
                    ['type'] = "error",
                    ['message'] = "Zoveel heeft persoon niet bij zich"
                })
            end
        end
    elseif type == "weapon" then
        if target.hasWeapon(data.label) then 
            target.removeWeapon(data.label)
            user.addWeapon(data.label, data.ammo)
            local x = data.weaponData.components
            for k,v in pairs(x) do 
                user.addWeaponComponent(data.label, v)
            end
            TriggerClientEvent("notify:sendnotify", id, {
                ['type'] = "error",
                ['message'] = "De persoon naast u heeft ".. data.label .." van u afgenomen"
            })
            TriggerClientEvent("notify:sendnotify", source, {
                ['type'] = "error",
                ['message'] = "U heeft ".. data.label .. " met " .. data.ammo .." kogels afgenomen van " .. GetPlayerName(id)
            })
        else
            TriggerClientEvent("notify:sendnotify", source, {
                ['type'] = "error",
                ['message'] = "Dit wapen is al afgepakt..."
            })
        end
    end
end)


RegisterServerEvent("revokerequest")
AddEventHandler("revokerequest", function()
    TriggerClientEvent("notify:sendnotify", request_data[source].sender, {
        ['type'] = "error",
        ['message'] = "Uw verzoek voor het fouilleren van " .. GetPlayerName(source) .." is afgewezen..."
    })
    request_data[source] = nil
end)