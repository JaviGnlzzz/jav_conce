ESX = exports["es_extended"]:getSharedObject()

Shared = {}

Shared.Npc = {
    model = 'cs_carbuyer',
    position = vector4(-56.79629, -1099.218, 25.42233, 23.77363)
}

Shared.Blip = {
    position = vector3(-56.79629, -1099.218, 26.42233),
    sprite = 380,
    color = 1,
    text = 'Concesionario'
}

Shared.Points = {
    spawn_vehicle = vector3(-41.23799, -1100.107, 25.42235),
    spawn_heading = 136.4193
}

Shared.Types = {
    {
        label = 'default',
        categorys = {
            'vans',
            'sports'
        }
    },
    {
        label = 'vip',
        categorys = {
            'super'   
        }
    }
}