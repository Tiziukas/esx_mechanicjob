local mechanicZones <const> = Config.MechanicZones
local stashPoints = {}

local function OpenPutStocksMenu()
    ESX.TriggerServerCallback('esx_mechanicjob:getPlayerInventory', function(inventory)
        local elements = {
            { label = 'Inventory', icon = 'fas fa-box', value = nil, type = 'header' }
        }

        for _, item in ipairs(inventory.items) do
            if item.count > 0 then
                table.insert(elements, {
                    label = item.label .. ' x' .. item.count,
                    value = item.name,
                    type = 'item_standard'
                })
            end
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'put_stock_items', {
            title = 'Put Items in Stash',
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            local itemName = data.current.value

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'put_stock_amount', {
                title = 'Amount to Deposit'
            }, function(data2, menu2)
                local count = tonumber(data2.value)

                if count == nil or count <= 0 then
                    ESX.ShowNotification('Bad Quantity')
                else
                    ESX.CloseMenu()
                    TriggerServerEvent('esx_mechanicjob:putStockItems', itemName, count)
                    Wait(1000)
                    OpenPutStocksMenu()
                end
            end, function(data2, menu2)
                menu2.close()
            end)

        end, function(data, menu)
            menu.close()
        end)
    end)
end

local function OpenGetStocksMenu()
    ESX.TriggerServerCallback('esx_mechanicjob:getStockItems', function(items)
        local elements = {
            { unselectable = true, icon = 'fas fa-box', title = 'Mech stock' }
        }

        for _, item in ipairs(items) do
            table.insert(elements, {
                icon = 'fas fa-box',
                title = 'x' .. item.count .. ' ' .. item.label,
                value = item.name
            })
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
    end)
end

local function OpenMechanicStashMenu()
    local elements = {
        {label = 'Place Item', value = 'put_stash'},
        {label = 'Get Item', value = 'get_stash'}
    }

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'cloakroom_menu',
        {
            title    = 'Cloakroom',
            align    = 'top-right',
            elements = elements
        },
        function(data, menu)
            menu.close()
            if data.current.value == 'put_stash' then
                OpenPutStocksMenu()
            elseif data.current.value == 'get_stash' then
                OpenGetStocksMenu()
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

Citizen.CreateThread(function()
    for zoneName, zoneData in pairs(mechanicZones) do
        local stashConfig <const> = zoneData.mechanicStash
        local stashLocation <const> = stashConfig.location
        local stashMarker <const> = stashConfig.marker

        stashPoints[#stashPoints + 1] = ESX.Point:new({
            coords = stashLocation,
            distance = 2.0,
            leave = function()
                ESX.HideUI()
            end,
            inside = function(point)
                ESX.TextUI('Press [E] to open mechanic stash')
                DrawMarker(
                    stashMarker.type or 1,
                    stashLocation.x, stashLocation.y, stashLocation.z,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    stashMarker.scale[1], stashMarker.scale[2], stashMarker.scale[3],
                    stashMarker.colour[1], stashMarker.colour[2], stashMarker.colour[3], stashMarker.colour[4],
                    false, false, 2, stashMarker.rotate or false
                )
                if IsControlJustReleased(0, 38) then
                    OpenMechanicStashMenu()
                end
            end
        })
    end
end)
