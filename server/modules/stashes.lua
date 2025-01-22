ESX.RegisterServerCallback('esx_mechanicjob:getStockItems', function(source, cb)
    local source <const> = source
    local xPlayer <const> = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name ~= 'mechanic' then
        return DropPlayer(source, "Cheater")
    end

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
        cb(inventory.items)
    end)
end)

RegisterServerEvent('esx_mechanicjob:putStockItems', function(itemName, count)
    local source <const> = source
    local xPlayer <const> = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name ~= 'mechanic' then
        return DropPlayer(source, "Cheater")
    end

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
        local item = inventory.getItem(itemName)
        local playerItemCount = xPlayer.getInventoryItem(itemName).count

        if count <= 0 or count > playerItemCount then
            return xPlayer.showNotification('Invalid quantity or insufficient items.')
        end

        xPlayer.removeInventoryItem(itemName, count)
        inventory.addItem(itemName, count)
        xPlayer.showNotification(string.format("%d %s have been deposited.", count, item.label))
    end)
end)

RegisterServerEvent('esx_mechanicjob:getStockItem', function(itemName, count)
    local source <const> = source
    local xPlayer <const> = ESX.GetPlayerFromId(source)

    if xPlayer.job.name ~= 'mechanic' then
        return DropPlayer(source, "Cheater")
    end

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
        local item = inventory.getItem(itemName)

        if count <= 0 or item.count < count then
            return xPlayer.showNotification('Invalid quantity or not enough items in the stock.')
        end

        if not xPlayer.canCarryItem(itemName, count) then
            return xPlayer.showNotification('You cannot carry this amount of items.')
        end

        inventory.removeItem(itemName, count)
        xPlayer.addInventoryItem(itemName, count)
        xPlayer.showNotification(string.format("%d %s have been withdrawn.", count, item.label))
    end)
end)
