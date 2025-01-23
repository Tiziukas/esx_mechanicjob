local mechanicZones <const> = Config.MechanicZones
local stashPoints = {}

local function OpenPutStocksMenu()
    local inventory = ESX.AwaitServerCallback('esx_mechanicjob:getPlayerInventory')
    local elements = {}

    -- Add a header element
    table.insert(elements, {
        unselectable = true,
        icon = 'fas fa-box',
        title = 'Inventory'
    })

    for _, item in ipairs(inventory.items) do
        if item.count > 0 then
            table.insert(elements, {
                icon = '',
                title = string.format("%s x%d", item.label, item.count),
                name = item.name
            })
        end
    end

    ESX.OpenContext('right', elements, function(menu, element)
        local itemName = element.name

        local inputElements = {
            {
                icon = '',
                title = 'Amount to Deposit',
                input = true,
                inputType = 'number',
                inputPlaceholder = 'Enter amount...',
                name = 'deposit_amount'
            },
            {
                icon = 'fas fa-check',
                title = 'Submit',
                name = 'submit'
            }
        }

        ESX.OpenContext('right', inputElements, function(inputMenu, inputElement)
            if inputElement.name == 'submit' then
                local count = tonumber(inputMenu.eles[1].inputValue)

                if count == nil or count <= 0 then
                    ESX.ShowNotification('Bad Quantity')
                else
                    ESX.CloseContext()
                    TriggerServerEvent('esx_mechanicjob:putStockItems', itemName, count)
                    Wait(1000)
                    OpenPutStocksMenu()
                end
            end
        end, function()
            
        end)
    end, function()
        
    end)
end


local function OpenGetStocksMenu()
    local items = ESX.AwaitServerCallback('esx_mechanicjob:getStockItems')
    local elements = {
        { unselectable = true, icon = 'fas fa-box', title = 'Mech stock' }
    }

    for _, item in ipairs(items) do
        elements[#elements + 1] = {
            icon = 'fas fa-box',
            title = string.format("x%d %s", item.count, item.label),
            value = item.name
        }
    end

    ESX.OpenContext("right", elements, function(menu, element)
        local itemName = element.value

        local elements2 = {
            { unselectable = true, icon = 'fas fa-box', title = element.title },
            { title = 'Amount', input = true, inputType = 'number', inputMin = 1, inputMax = 100, inputPlaceholder = 'Amount to withdraw..' },
            { icon = 'fas fa-check-double', title = 'Confirm', value = 'confirm' }
        }

        ESX.OpenContext("right", elements2, function(menu2, element2)
            local count = tonumber(menu2.eles[2].inputValue)

            if count == nil then
                ESX.ShowNotification('Invalid quantity')
            else
                ESX.CloseContext()
                TriggerServerEvent('esx_mechanicjob:getStockItem', itemName, count)

                Wait(1000)
                OpenGetStocksMenu()
            end
        end)
    end)
end

local function OpenMechanicStashMenu()
    local elements = {
        {
            icon = 'fas fa-box',
            title = 'Place Item',
            value = 'put_stash'
        },
        {
            icon = 'fas fa-box-open',
            title = 'Get Item',
            value = 'get_stash'
        }
    }

    ESX.OpenContext('right', elements, function(menu, element)
        if element.value == 'put_stash' then
            OpenPutStocksMenu()
        elseif element.value == 'get_stash' then
            OpenGetStocksMenu()
        end
    end, function()
    end)
end

local canInteract = false
CreateThread(function()
    for zoneName, zoneData in pairs(mechanicZones) do
        local stashConfig <const> = zoneData.mechanicStash
        local stashLocation <const> = stashConfig.location
        local stashMarker <const> = stashConfig.marker

        stashPoints[#stashPoints + 1] = ESX.Point:new({
            coords = stashLocation,
            distance = 2.0,
            enter = function()
                canInteract = true
                local key = ESX.GetInteractKey()
                ESX.TextUI(string.format("Press [%s] to open mechanic stash", key))                
            end,
            leave = function()
                canInteract = false
                ESX.HideUI()
            end,
            inside = function()
                DrawMarker(
                    stashMarker.type or 1,
                    stashLocation.x, stashLocation.y, stashLocation.z,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    stashMarker.scale[1], stashMarker.scale[2], stashMarker.scale[3],
                    stashMarker.colour[1], stashMarker.colour[2], stashMarker.colour[3], stashMarker.colour[4],
                    false, false, 2, stashMarker.rotate or false
                )
            end
        })
    end
end)

ESX.RegisterInteraction('stashInteraction', function()
    if canInteract then
        OpenMechanicStashMenu()
    end
end)
