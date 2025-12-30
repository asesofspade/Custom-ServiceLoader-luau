local DataStoreAPI = {}
local self = DataStoreAPI

function DataStoreAPI:Init(dataStorage)
    self.DataStore = dataStorage
end

function DataStoreAPI:HandleEvent(action, data)
    if not action or not self.DataStore then return end

    if action == "Create" then
        self.DataStore:Create(data.storeName, data.defaultData)

    elseif action == "Load" then
        if data.player and data.storeName then
            self.DataStore:Load(data.player, data.storeName)
        end

    elseif action == "Save" then
        if data.player and data.storeName then
            self.DataStore:Save(data.player, data.storeName)
        end

    elseif action == "GetValue" then
        if data.player and data.storeName and data.key then
            if not self.DataStore._dataStores[data.storeName].Players[data.player.UserId] then
                self.DataStore:Load(data.player, data.storeName)
            end
            local value = self.DataStore:GetValue(data.player, data.storeName, data.key)
            if data.callback then
                data.callback(value)
            end
        end

    elseif action == "SetValue" then
        if data.player and data.storeName and data.key then
            self.DataStore:SetValue(
                data.player,
                data.storeName,
                data.key,
                data.value,
                data.options
            )
        end

    elseif action == "FindValue" then
        if data.player and data.value then
            local results = self.DataStore:FindValue(data.player, data.value)
        end
    end
end

return DataStoreAPI
