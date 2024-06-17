local ox_inventory = exports.ox_inventory

lib.callback.register('tiz_meth:server:cookthisbitchup', function(source)
    if ox_inventory:GetItemCount(source, 'acetone') >= 1 and ox_inventory:GetItemCount(source, 'sacid') >= 1 and ox_inventory:GetItemCount(source, 'lithium') >=1 then
        TriggerClientEvent('tiz-meth:client:startprod', source)
        
        if Config.Debug then print("Production Started") end
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = Config.Language.notifyTitle,
            description = Config.Language.wrongIngredients,
            type = 'error'
        })
    end
end)

-- Callback to get item count from the player's inventory
lib.callback.register('tiz-meth:server:getItemCount', function(source, item)
    local count = ox_inventory:GetItemCount(source, item)
    if Config.Debug then print("User has: " .. count .. " of item: " .. item) end
    return count
end)

-- Callback to remove an item from the player's inventory
lib.callback.register('tiz-meth:server:removeItem', function(source, item)
    ox_inventory:RemoveItem(source, item, 1)
    if Config.Debug then print("Removed item: " .. item) end
    return true
end)
lib.callback.register('tiz_meth:server:awaitsmoke', function(source)
    local xPlayers = GetPlayers()
    local pos = lib.callback.await('tiz_meth:client:getpos', source)
    for i = 1, #xPlayers do
        TriggerClientEvent('tiz_meth:client:smoke', xPlayers[i], pos.x, pos.y, pos.z, 'a')
    end
    return true
end)

-- Callback to finish the production and give the player the resulting meth
lib.callback.register('tiz-meth:server:FinishThisShit', function(source, qual)
    local methName
    if qual == 1 then
        methName = Config.MethNames.lowqual
    elseif qual == 2 then
        methName = Config.MethNames.midqual
    elseif qual == 3 then
        methName = Config.MethNames.highqual
    else
        return  TriggerClientEvent('ox_lib:notify', source, {
            title = Config.Language.notifyTitle,
            description = Config.Language.batchMessed,
            type = 'error'
        })
    end
    -- Add the meth to the player's inventory
    ox_inventory:AddItem(source, methName, Config.HowMuchMeth)
    if Config.Debug then print("Added meth of quality: " .. qual) end
end)
