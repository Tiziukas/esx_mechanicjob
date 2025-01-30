ESX.RegisterUsableItem('repairkit', function(source)
    local _source <const> = source
    local xPlayer <const> = ESX.Player(_source)
    ESX.TriggerClientCallback(source , "esx_mechanicjob:client:checkForVehicle", function(closeVehicle)
        if not closeVehicle then return end

        xPlayer.removeInventoryItem('repairkit', 1)

        TriggerClientEvent('esx_mechanicjob:client:useRepairKit', source)
    end)
end)