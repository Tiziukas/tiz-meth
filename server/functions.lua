

if Config.Inventory == 'ox' then
    local ox_inventory = exports.ox_inventory

    function GetItemCount(source, item)
        return ox_inventory:GetItemCount(source, item)
    end

    function RemoveItem(source, item, quantity)
        return ox_inventory:RemoveItem(source, item, quantity)
    end

    function AddItem(source, item, quantity)
        return ox_inventory:AddItem(source, item, quantity)
    end
elseif Config.Inventory == 'qs' then
    function GetItemCount(source, item)
        return exports['qs-inventory']:GetItemTotalAmount(source, item)
    end

    function RemoveItem(source, item, quantity)
        return exports['qs-inventory']:RemoveItem(source, item, quantity)
    end

    function AddItem(source, item, quantity)
        return exports['qs-inventory']:AddItem(source, item, quantity)
    end
elseif Config.Inventory == 'qb' then
    function GetItemCount(source, item)
        return exports['qb-inventory']:GetItemCount(source, item)
    end

    function RemoveItem(source, item, quantity)
        return exports['qb-inventory']:RemoveItem(source, item, quantity)
    end
    
    function AddItem(source, item, quantity)
        return exports['qb-inventory']:AddItem(source, item, quantity)
    end
end

