ESX.RegisterServerCallback('esx_mechanicjob:getStockItems', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name ~= 'mechanic' then
        return DropPlayer(source, "Cheater")
    end

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
        cb(inventory.items)
    end)
end)

RegisterServerEvent('esx_mechanicjob:putStockItems')
AddEventHandler('esx_mechanicjob:putStockItems', function(itemName, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name ~= 'mechanic' then
        return DropPlayer(source, "Cheater")
    end

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
        local item = inventory.getItem(itemName)
        local playerItemCount = xPlayer.getInventoryItem(itemName).count

        if count <= 0 or count > playerItemCount then
            xPlayer.showNotification('Invalid quantity or insufficient items.')
            return
        end

        xPlayer.removeInventoryItem(itemName, count)
        inventory.addItem(itemName, count)
        xPlayer.showNotification(count .. ' ' .. item.label .. ' have been deposited.')
    end)
end)

RegisterServerEvent('esx_mechanicjob:getStockItem')
AddEventHandler('esx_mechanicjob:getStockItem', function(itemName, count)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.job.name ~= 'mechanic' then
        return DropPlayer(source, "Cheater")
    end

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
        local item = inventory.getItem(itemName)

        if count <= 0 or item.count < count then
            xPlayer.showNotification('Invalid quantity or not enough items in the stock.')
            return
        end

        if not xPlayer.canCarryItem(itemName, count) then
            xPlayer.showNotification('You cannot carry this amount of items.')
            return
        end

        inventory.removeItem(itemName, count)
        xPlayer.addInventoryItem(itemName, count)
        xPlayer.showNotification(count .. ' ' .. item.label .. ' have been withdrawn.')
    end)
end)
