local DataStorage = {}
local DataService = game:GetService("DataStoreService")

DataStorage._dataStores = {}
DataStorage._initialized = false

local function initialize()
    if DataStorage._initialized then return end
    DataStorage._initialized = true

    game.Players.PlayerAdded:Connect(function(player)
        for storeName, _ in pairs(DataStorage._dataStores) do
            DataStorage:Load(player, storeName)
        end

        player.CharacterAdded:Connect(function()
            local coins = DataStorage:GetValue(player, "PlayerData", "Coins") or 0
            print(player.Name, "revived with", coins, "coins")
        end)
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        -- Limpiar valores blacklisted al salir
        for storeName, ds in pairs(DataStorage._dataStores) do
            local pdata = ds.Players[player.UserId]
            if pdata and ds.Options.blacklist then
                for _, blackKey in pairs(ds.Options.blacklist) do
                    if pdata[blackKey] ~= nil then
                        pdata[blackKey] = nil
                        print(player.Name, "removed blacklisted", blackKey, "from runtime memory")
                    end
                end
            end
        end

        for storeName, _ in pairs(DataStorage._dataStores) do
            DataStorage:Save(player, storeName)
        end
    end)
end

function DataStorage:Create(storeName, defaultData, options)
    initialize()
    if not storeName or storeName == "" then
        error("DataStorage:Create requires a storeName")
    end
    if self._dataStores[storeName] then
        warn("DataStore already exists:", storeName)
        return
    end

    local ds = {
        Store = DataService:GetDataStore(storeName),
        Default = defaultData or {},
        Players = {},
        Locks = {},
        Options = options or {blacklist = {}}
    }

    self._dataStores[storeName] = ds
    print("[DataStorage] Created DataStore:", storeName)
end

function DataStorage:Load(player, storeName)
    local ds = self._dataStores[storeName]
    if not ds then warn("DataStore not found:", storeName) return end

    if not ds.Players[player.UserId] then
        ds.Players[player.UserId] = table.clone(ds.Default)
    end

    local key = "Player_" .. player.UserId
    if ds.Locks[player.UserId] then
        warn("Load in progress for", player.Name, "in store", storeName)
        return ds.Players[player.UserId]
    end

    ds.Locks[player.UserId] = true
    local success, data = pcall(function()
        return ds.Store:GetAsync(key)
    end)
    if success and data then
        ds.Players[player.UserId] = data
    end
    ds.Locks[player.UserId] = nil

    return ds.Players[player.UserId]
end

function DataStorage:Save(player, storeName)
    local ds = self._dataStores[storeName]
    if not ds then warn("DataStore not found:", storeName) return end

    local key = "Player_" .. player.UserId
    local data = ds.Players[player.UserId]
    if not data then return end

    if ds.Locks[player.UserId] then
        warn("Save in progress for", player.Name, "in store", storeName)
        return
    end
    ds.Locks[player.UserId] = true

    -- Eliminar valores en blacklist antes de guardar
    if ds.Options.blacklist then
        for _, blackKey in pairs(ds.Options.blacklist) do
            data[blackKey] = nil
        end
    end

    local success, err = pcall(function()
        ds.Store:SetAsync(key, data)
    end)
    if not success then
        warn("Error saving data for", player.Name, ":", err)
    end

    ds.Locks[player.UserId] = nil
end

function DataStorage:GetValue(player, storeName, key)
    local ds = self._dataStores[storeName]
    if not ds then return nil end
    local pdata = ds.Players[player.UserId]
    if not pdata then return nil end
    return pdata[key]
end

function DataStorage:SetValue(player, storeName, key, value, options)
    options = options or {}
    local ds = self._dataStores[storeName]
    if not ds then return end
    if not ds.Players[player.UserId] then
        ds.Players[player.UserId] = table.clone(ds.Default)
    end

    local pdata = ds.Players[player.UserId]

    -- Si es blacklisted, solo runtime, no persiste
    if ds.Options.blacklist then
        for _, blackKey in pairs(ds.Options.blacklist) do
            if key == blackKey then
                pdata[key] = value
                return
            end
        end
    end

    if options.stackable then
        pdata[key] = pdata[key] or {}
        pdata[key][value] = (pdata[key][value] or 0) + 1
    elseif options.unique then
        pdata[key] = pdata[key] or {}
        if pdata[key][value] then return end
        pdata[key][value] = 1
    else
        pdata[key] = value
    end
end

function DataStorage:FindValue(player, value)
    local results = {}
    for storeName, ds in pairs(self._dataStores) do
        local pdata = ds.Players[player.UserId]
        if pdata then
            for k, v in pairs(pdata) do
                if v == value then
                    table.insert(results, {Store = storeName, Key = k, Value = v})
                end
            end
        end
    end
    return results
end

initialize()
return DataStorage
