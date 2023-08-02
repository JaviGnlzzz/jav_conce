local in_menu = false
local npc_model = nil

CreateThread(function()
    npc_model = spawnPed(Shared.Npc.model, Shared.Npc.position)

    createNewBlip(Shared.Blip.sprite, Shared.Blip.color, Shared.Blip.position, Shared.Blip.text)

    while (true) do
        time = 300

        local ped = PlayerPedId()
        local ped_coords = GetEntityCoords(ped)
        local distance = #(ped_coords - vector3(Shared.Npc.position.x, Shared.Npc.position.y, Shared.Npc.position.z))

        if(distance < 2.5) then

            time = 0

            if(not in_menu) then
                ESX.ShowHelpNotification('~INPUT_CONTEXT~ para hablar con Mike')
            end

            if(IsControlJustReleased(0, 38) and not in_menu) then

                local items = {
                    {
                        title = 'Apartado vehículos',
                        description = 'Vehículos sin restricciones',
                        value = 'default'
                    },
                    {
                        title = 'Apartado importados',
                        description = 'Vehículos por suscripción',
                        value = 'vip'
                    },
                    {
                        title = 'Salir',
                        description = 'Cerrar este apartado',
                        value = 'exit'
                    }
                }

                Wait(100)

                createNewCamera(Shared.Npc.position, npc_model)
                createNewMenu('Concesionario', items)

                in_menu = true
            end

            if(in_menu) then
                DisableAllControlActions(0)
            end

            if (IsEntityDead(PlayerPedId())) then
                closeMenu()
            end

        end

        Wait(time)
    end
end)

function stateMenu(state)
    in_menu = state
end