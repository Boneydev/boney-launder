local ActiveWashes = {}

local function notify(src, description, nType)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Boney Launder',
        description = description,
        type = nType or 'inform'
    })
end

local function getCleanAmount(amount)
    local tax = Config.TaxPercent / 100
    local cleaned = math.floor(amount * (1 - tax))
    if cleaned < 0 then cleaned = 0 end
    return cleaned
end

local function getWash(src)
    return ActiveWashes[src]
end

RegisterNetEvent('boney_launder:server:startWash', function(amount)
    local src = source
    local wash = getWash(src)

    if wash then
        return notify(src, Config.Text.alreadyWashing, 'error')
    end

    amount = tonumber(amount)
    if not amount then
        return notify(src, Config.Text.invalidAmount, 'error')
    end

    amount = math.floor(amount)

    if amount < Config.MinWash then
        return notify(src, Config.Text.tooLittle, 'error')
    end

    if amount > Config.MaxWash then
        return notify(src, Config.Text.tooMuch, 'error')
    end

    local count = exports.ox_inventory:Search(src, 'count', Config.DirtyItem) or 0
    if count < amount then
        return notify(src, Config.Text.noDirtyMoney, 'error')
    end

    local removed = exports.ox_inventory:RemoveItem(src, Config.DirtyItem, amount)
    if not removed then
        return notify(src, Config.Text.noDirtyMoney, 'error')
    end

    local cleanAmount = getCleanAmount(amount)
    local readyAt = os.time() + (Config.WashTimeMinutes * 60)

    ActiveWashes[src] = {
        dirtyAmount = amount,
        cleanAmount = cleanAmount,
        readyAt = readyAt
    }

    notify(src, ('%s (%s in, %s out)'):format(Config.Text.handedOver, amount, cleanAmount), 'success')
end)

RegisterNetEvent('boney_launder:server:collectWash', function()
    local src = source
    local wash = getWash(src)

    if not wash then
        return notify(src, Config.Text.noWashReady, 'error')
    end

    if os.time() < wash.readyAt then
        return notify(src, Config.Text.waitLonger, 'error')
    end

    if Config.CleanItem == 'money' then
        local player = exports.qbx_core:GetPlayer(src)
        if not player then return end

        player.Functions.AddMoney('cash', wash.cleanAmount, 'boney-launder')
    else
        if not exports.ox_inventory:CanCarryItem(src, Config.CleanItem, wash.cleanAmount) then
            return notify(src, 'Not enough inventory space', 'error')
        end

        exports.ox_inventory:AddItem(src, Config.CleanItem, wash.cleanAmount)
    end

    ActiveWashes[src] = nil
    notify(src, ('%s ($%s)'):format(Config.Text.collected, wash.cleanAmount), 'success')
end)

lib.callback.register('boney_launder:server:getWashData', function(source)
    return ActiveWashes[source]
end)

AddEventHandler('playerDropped', function()
    local src = source
    -- keeps nothing after leave, simple version
    ActiveWashes[src] = nil
end)