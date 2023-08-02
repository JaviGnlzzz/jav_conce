ESX.RegisterServerCallback('jav_conce:getAllVehicles', function(source, cb, category)

    local result = getAllVehicles(category)

    Wait(100)

    cb(result)

end)

ESX.RegisterServerCallback('jav_conce:buyVehicle', function(source, cb, model, properties, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate ', {
        ['plate'] = plate
    }, function(result)
        if not result[1] then
            MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, properties) VALUES (?, ?, ?)', {xPlayer.getIdentifier(), plate, properties}, function(result) end)
        end
    end)
end)