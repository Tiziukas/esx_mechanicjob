local mechanicZones <const> = Config.MechanicZones
local cloakroomPoints = {}

local function SetMechanicOutfit()
    local skin = ESX.AwaitServerCallback('esx_skin:getPlayerSkin')
    local jobGrade = LocalPlayer.state.job.grade
    local outfit = Config.MechanicOutfits[jobGrade]
    if not outfit then
        ESX.ShowNotification('No outfit configured for your grade.')
        return
    end

    local gender = skin.sex == 0 and "male" or "female"
    TriggerEvent('skinchanger:loadClothes', skin, outfit[gender])
end


local function ResetToCivilianClothes()
    local skin = ESX.AwaitServerCallback('esx_skin:getPlayerSkin')
    TriggerEvent('skinchanger:loadSkin', skin)
    ESX.ShowNotification('You changed back into your civilian clothes.')
end


local function OpenCloakroomMenu()
    local elements = {
        {label = 'Work Clothes', value = 'work_clothes'},
        {label = 'Civilian Clothes', value = 'civilian_clothes'}
    }

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'cloakroom_menu',
        {
            title    = 'Cloakroom',
            align    = 'right',
            elements = elements
        },
        function(data, menu)
            if data.current.value == 'work_clothes' then
                SetMechanicOutfit()
            elseif data.current.value == 'civilian_clothes' then
                ResetToCivilianClothes()
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

CreateThread(function()
    for zoneName, zoneData in pairs(mechanicZones) do
        local cloakroomConfig <const> = zoneData.cloakroom
        local location <const>  = cloakroomConfig.location
        local markerConfig <const> = cloakroomConfig.marker

        cloakroomPoints[#cloakroomPoints + 1] = ESX.Point:new({
            coords = location,
            distance = 2.0,
            enter = function()
                ESX.TextUI('Press [E] to open cloakroom', 'info')
            end,
            leave = function()
                ESX.HideUI()
            end,
            inside = function(point)
                DrawMarker(
                    markerConfig.type or 20, -- Default to cylinder marker
                    location.x, location.y, location.z, -- Position
                    0.0, 0.0, 0.0, -- Direction
                    0.0, 0.0, 0.0, -- Rotation
                    markerConfig.scale[1], markerConfig.scale[2], markerConfig.scale[3], -- Scale
                    markerConfig.colour[1], markerConfig.colour[2], markerConfig.colour[3], markerConfig.colour[4], -- RGBA
                    false, -- Not bobbing
                    false, -- No face camera
                    2, -- P19
                    markerConfig.rotate or false, -- Rotation enabled/disabled
                    nil, -- Texture dictionary
                    nil, -- Texture name
                    false -- Draw on entities
                )
                if IsControlJustReleased(0, 38) then
                    OpenCloakroomMenu()
                end
            end
        })
    end

end)
