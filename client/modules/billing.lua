local function IssueBill()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'billing_amount',
        {
            title = 'Enter bill amount'
        },
        function(data, menu)
            local amount = tonumber(data.value)
            if not amount or amount <= 0 then
                ESX.ShowNotification('Invalid amount')
                menu.close()
                return
            end

            menu.close() 

            ESX.UI.Menu.Open(
                'dialog', GetCurrentResourceName(), 'billing_reason',
                {
                    title = 'Enter billing reason'
                },
                function(reasonData, reasonMenu)
                    local reason = tostring(reasonData.value)
                    if not reason or reason == '' then
                        ESX.ShowNotification('Reason cannot be empty')
                        reasonMenu.close()
                        return
                    end

                    local player, distance = ESX.Game.GetClosestPlayer()

                    if player ~= -1 and distance <= 3.0 then
                        local playerId = GetPlayerServerId(player)
                        TriggerServerEvent('esx_billing:sendBill', playerId, 'society_mechanic', reason, amount)
                        ESX.ShowNotification('Bill issued successfully with reason: ' .. reason)
                    else
                        ESX.ShowNotification('No player nearby')
                    end

                    reasonMenu.close()
                end,
                function(reasonData, reasonMenu)
                    reasonMenu.close()
                end
            )
        end,
        function(data, menu)
            menu.close()
        end
    )
end


local function ViewUnpaidBills()
    local bills = ESX.AwaitServerCallback('esx_mechanicjob:server:getSocietyBillsWithNames', 'society_mechanic')
    local elements = {}
    for i=1, #bills, 1 do
        table.insert(elements, {
            label = bills[i].fullName .. ' - $' .. bills[i].amount,
            value = bills[i].id
        })
    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'unpaid_bills',
        {
            title    = 'Unpaid Bills',
            align    = 'right',
            elements = elements
        },
        function(data, menu)
            ESX.ShowNotification('Selected Bill ID: ' .. data.current.value)

        end,
        function(data, menu)
            menu.close()
        end
    )
end


function OpenBillingMenu()
    local elements = {
        {label = 'Issue Bill', value = 'issue_bill'},
        {label = 'View Unpaid Bills', value = 'view_bills'}
    }

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'billing_menu',
        {
            title    = 'Billing Menu',
            align    = 'right',
            elements = elements
        },
        function(data, menu)
            if data.current.value == 'issue_bill' then
                IssueBill()
            elseif data.current.value == 'view_bills' then
                ViewUnpaidBills()
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end
