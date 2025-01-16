ESX.RegisterUsableItem('tirekit', function(source)
    local source = source
    local xPlayer  = ESX.GetPlayerFromId(source)
    ESX.TriggerClientCallback(source , "esx_mechanicjob:client:checkForVehicle", function(closeVehicle)
        if not closeVehicle then return end
        xPlayer.removeInventoryItem('tire', 1)

        TriggerClientEvent('esx_mechanicjob:client:useTireKit', source)
    end)
end)