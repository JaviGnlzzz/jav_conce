function getAllVehicles(category)
    local vehicles_selected = {}
    
    for k, v in pairs(category.categorys) do
        local result = MySQL.query.await('SELECT * FROM vehicles WHERE category = ?', {v})
        
        if (#result > 0) then
            for j, h in pairs(result) do
                table.insert(vehicles_selected, {
                    model = h.model,
                    name = h.name,
                    price = h.price,
                    category = h.category
                })
            end
        end
    end

    return vehicles_selected
end

