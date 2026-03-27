local laundPed = nil

local function loadModel(model)
    if type(model) == 'string' then
        model = joaat(model)
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    return model
end

local function createPed()
    local model = loadModel(Config.Ped.model)
    local coords = Config.Ped.coords

    laundPed = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
    FreezeEntityPosition(laundPed, true)
    SetEntityInvincible(laundPed, true)
    SetBlockingOfNonTemporaryEvents(laundPed, true)

    exports.ox_target:addLocalEntity(laundPed, {
        {
            name = 'boney_launder_start',
            icon = 'fa-solid fa-money-bill-wave',
            label = Config.Text.startWash,
            distance = 2.0,
            onSelect = function()
                local input = lib.inputDialog('Boney Launder', {
                    {
                        type = 'number',
                        label = 'Amount to wash',
                        description = ('Min: %s | Max: %s'):format(Config.MinWash, Config.MaxWash),
                        required = true,
                        min = Config.MinWash,
                        max = Config.MaxWash
                    }
                })

                if not input then return end
                local amount = tonumber(input[1])
                if not amount then return end

                TriggerServerEvent('boney_launder:server:startWash', amount)
            end
        },
        {
            name = 'boney_launder_collect',
            icon = 'fa-solid fa-sack-dollar',
            label = Config.Text.collectWash,
            distance = 2.0,
            onSelect = function()
                TriggerServerEvent('boney_launder:server:collectWash')
            end
        }
    })
end

CreateThread(function()
    createPed()
end)