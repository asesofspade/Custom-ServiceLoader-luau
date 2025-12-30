local ServicesLoader = {}
local self = ServicesLoader

local RunService = game:GetService("RunService")

local CustomService = Instance.new("Folder")
CustomService.Name = "CustomService"
CustomService.Parent = game

local ObjectOrientedEvent = Instance.new("BindableEvent")
ObjectOrientedEvent.Name = "ObjectOriented"
ObjectOrientedEvent.Parent = CustomService

local DataStoreEvent = Instance.new("BindableEvent")
DataStoreEvent.Name = "DataStore"
DataStoreEvent.Parent = CustomService

function ServicesLoader:Create(data)
    if not data or not data.modules then
        warn("No modules passed to ServicesLoader:Create")
        return
    end

    self.Modules = data.modules

    if self.Modules.ObjectOrientedAPI then
        self.ObjectOrientedAPI = self.Modules.ObjectOrientedAPI
        self.ObjectOrientedAPI:Init(
            self.Modules.Animations,
            self.Modules._pathFinding
        )
    end

    if RunService:IsServer() and self.Modules.DataStoreAPI and self.Modules.DataStorage then
        self.DataStoreAPI = self.Modules.DataStoreAPI
        self.DataStoreAPI:Init(self.Modules.DataStorage)
    end

    if self.DataStoreAPI then
        DataStoreEvent.Event:Connect(function(action, eventData)
            self.DataStoreAPI:HandleEvent(action, eventData)
        end)
    end

    if self.ObjectOrientedAPI then
        ObjectOrientedEvent.Event:Connect(function(instances, eventData)
            self.ObjectOrientedAPI:HandleEvent(instances, eventData)
        end)
    end
end

return ServicesLoader
