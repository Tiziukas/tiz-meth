lib.callback.register('tiz_meth:server:cookthisbitchup', function(source)
    if GetItemCount(source, 'acetone') >= 1 and GetItemCount(source, 'sacid') >= 1 and GetItemCount(source, 'lithium') >=1 then
        if Config.Debug then print("Production Started") end
        return TriggerClientEvent('tiz-meth:client:startprod', source)
    else
        return TriggerClientEvent('ox_lib:notify', source, {
            title = Config.Language.notifyTitle,
            description = Config.Language.wrongIngredients,
            type = 'error'
        })
    end
end)

-- Callback to get item count from the player's inventory
lib.callback.register('tiz-meth:server:getItemCount', function(source, item)
    local count = GetItemCount(source, item)
    if Config.Debug then print("User has: " .. count .. " of item: " .. item) end
    return count
end)
lib.callback.register('tiz_meth:server:checkIngredients', function(source)
    local acetone1 = GetItemCount(source, Config.ItemNames.acetone)
    local acid1 = GetItemCount(source, Config.ItemNames.acid)
    local lithium = GetItemCount(source, Config.ItemNames.lithium)
    if acetone1 >= 1 and acid1 >= 1 and lithium >= 1 then
        return true
    else
        return false
    end
end)

-- Callback to remove an item from the player's inventory
lib.callback.register('tiz-meth:server:removeItem', function(source, item)
    if Config.Debug then print("Removed item: " .. item) end
    return RemoveItem(source, item, 1)
end)
lib.callback.register('tiz_meth:server:awaitsmoke', function(source, pos, var)
    if var then
        return TriggerClientEvent('tiz_meth:client:smoke', -1, pos.x, pos.y, pos.z, 'a')
    else
        return TriggerClientEvent('tiz_meth:client:smoke', -1, pos.x, pos.y, pos.z, var)
    end
end)

-- Callback to finish the production and give the player the resulting meth
lib.callback.register('tiz-meth:server:FinishThisShit', function(source, qual)
    if qual ~= 1 and qual ~= 2 and qual ~= 3 then return DropPlayer(source, 'Executor') end
    local methName
    if qual == 1 then
        methName = Config.MethNames.lowqual
    elseif qual == 2 then
        methName = Config.MethNames.midqual
    elseif qual == 3 then
        methName = Config.MethNames.highqual
    else
        return TriggerClientEvent('ox_lib:notify', source, {
            title = Config.Language.notifyTitle,
            description = Config.Language.batchMessed,
            type = 'error'
        })
    end
    -- Add the meth to the player's inventory
    if Config.Debug then print("Added meth of quality: " .. qual) end
    return AddItem(source, methName, Config.HowMuchMeth)
end)
