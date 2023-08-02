local cam = nil
local vehicle_selected = nil
local model_selected = nil
local is_spawned = false
local vehicle_stats = {}

function spawnPed(model, position, animation)
    hash = GetHashKey(model)
        
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(1)
    end

    local npc = CreatePed(5, hash, position.x, position.y, position.z, position.w, false, true)

    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    TaskPlayAnim(npc,"rcmnigel1a","basee", 1.0, 1.0, -1, 1, 0, true, true, true)

    return npc
end

function createNewBlip(blip, sprite, position, text)
    local blip = AddBlipForCoord(position)
    SetBlipSprite (blip, 380)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.8) 
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(i)
    EndTextCommandSetBlipName(blip)
end

function createNewCamera(position, entity, type_camera)
    cam = nil

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
    local offset = GetOffsetFromEntityInWorldCoords(entity, 0, 1.7, 0.4)

    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, true)
    SetCamCoord(cam, offset.x, offset.y, offset.z)
    PointCamAtCoord(cam, Shared.Npc.position.x, Shared.Npc.position.y, Shared.Npc.position.z + 1.3)
end

function destroyCamera()
    SetCamActive(cam, false)
    RenderScriptCams(false, true, 600, true, true)
    cam = nil
end

function createNewMenu(title, items)
    exports['olv_context']:createContextMenu(title, items, function(value)
        destroyCamera()
        if(value == 'exit') then
            stateMenu(false)
        end

        if(value == 'default') then
            openMenuConce(Shared.Types[1])
        end

        if(value == 'vip') then
            openMenuConce(Shared.Types[2])
        end
    end)
end

function openMenuConce(category)
    ESX.TriggerServerCallback('jav_conce:getAllVehicles', function(data)
        if(next(data) ~= nil) then

            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'show:interfaz:conce',
                type = 'list',
                data_conce = data,
            })

        end
    end, category)
end

RegisterNUICallback('spawn_vehicle', function(data, cb)
    model_selected = data.model
    spawnVehicle(model_selected, data.price)
end)

function spawnVehicle(model, price)
    vehicle_stats = {}

    if(vehicle_selected ~= nil) then
        DeleteEntity(vehicle_selected)
    end

    ESX.Game.SpawnLocalVehicle(model, Shared.Points.spawn_vehicle, Shared.Points.heading, function(vehicle)

        vehicle_selected = vehicle

        table.insert(vehicle_stats, {
            model = model,
            speed = GetVehicleEstimatedMaxSpeed(vehicle) / 80 * 100,
            acceleration = GetVehicleModelAcceleration(GetEntityModel(vehicle)) * 200,
            brake = GetVehicleMaxBraking(vehicle) * 80,
            price = price
        })

        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetModelAsNoLongerNeeded(model)
        SetVehRadioStation(vehicle, 'OFF')
        RequestCollisionAtCoord(Shared.Points.spawn_vehicle) 
        SetVehicleOnGroundProperly(vehicle)
        
    end)

    Wait(400)

    if(not is_spawned) then
        cam = nil
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        is_spawned = true
        
        local offset = GetOffsetFromEntityInWorldCoords(vehicle_selected, -1.0, 5.0, 0.8)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 1000, true, true)
        SetCamCoord(cam, offset.x, offset.y, offset.z)
        PointCamAtCoord(cam, Shared.Points.spawn_vehicle.x, Shared.Points.spawn_vehicle.y, Shared.Points.spawn_vehicle.z + 1.3)
    end

    SendNUIMessage({
        action = 'show:interfaz:conce',
        type = 'stats',
        data_stats = vehicle_stats
    })

end

RegisterNUICallback('exit', function()
    closeMenu()
end)

function closeMenu()
    stateMenu(false)

    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hide'
    })

    Wait(200)

    DeleteEntity(vehicle_selected)

    vehicle_selected = nil
    model_selected = nil
    is_spawned = false

    destroyCamera()
end

local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function GetRandomNumber(length)
	Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GetRandomLetter(length)
	Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end

RegisterNUICallback('buy_vehicle', function(data)
    local plate = string.upper(GetRandomLetter(3) .. ' ' .. GetRandomNumber(3))
    local playerData = ESX.GetPlayerData()
    local money = 0
    local ped = PlayerPedId()

    for k,v in pairs(playerData.accounts) do
        if v.name == 'money' then
            money = v.money
        end
    end
    
    if (money >= data.price) then
        
        exports.olv_bank:appendBankDialog('Concesionario - '..data.price, data.price, function(state)
            if(state) then

                closeMenu()

                ESX.Game.SpawnVehicle(data.model, vector3(-43.29031, -1077.458, 26.66289), 72.0434, function(vehicle)
                    SetVehicleNumberPlateText(vehicle, plate)
                    TaskWarpPedIntoVehicle(ped, vehicle, -1)
                    local propertiesVehicleBuy = json.encode(ESX.Game.GetVehicleProperties(vehicle))

                    Wait(400)

                    ESX.TriggerServerCallback('jav_conce:buyVehicle', function() end, data.model, propertiesVehicleBuy, plate)
                end)
            end

            return
        end)

    else
        ESX.ShowNotification('No tienes suficiente dinero.', 'error')
    end
end)