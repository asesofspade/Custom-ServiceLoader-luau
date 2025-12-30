local ModuleLoader = {}
local self = ModuleLoader

local RunService = game:GetService("RunService")

self._modules_folder = script.Parent
self._cached_modules = {}
self.Modules = {}
self.is_server = RunService:IsServer()
self.is_client = RunService:IsClient()
local extraFolder = nil

if self.is_server then
    extraFolder = game.ServerStorage
end

function self:GetModule(name)
    return self.Modules[name]
end

function self:_init()
    local folders_to_scan = {self._modules_folder}
    if self.is_server and extraFolder then
        table.insert(folders_to_scan, extraFolder)
    end

    for _, parent_folder in ipairs(folders_to_scan) do
        if parent_folder then
            for _, folder in pairs(parent_folder:GetChildren()) do
                if folder:IsA("Folder") then
                    local folder_type
                    local folderNameLower = folder.Name:lower()
                    if folderNameLower == "shared" or folderNameLower == "helpers" then
                        folder_type = "Both"
                    elseif parent_folder == extraFolder or folderNameLower == "server" then
                        folder_type = "Server"
                    elseif folderNameLower == "client" then
                        folder_type = "Client"
                    else
                        folder_type = "Both"
                    end

                    if folder_type == "Both" or (self.is_server and folder_type == "Server") or (self.is_client and folder_type == "Client") then
                        for _, module_script in pairs(folder:GetDescendants()) do
                            if module_script:IsA("ModuleScript") then
                                local success, module_obj = pcall(require, module_script)
                                if success then
                                    local key = module_script.Name
                                    self._cached_modules[key] = module_obj
                                    self.Modules[key] = module_obj 
                                else
                                    warn("Failed to require module:", module_script:GetFullName(), module_obj)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function self:ScanFolder(folder)
    local scannedModules = {}

    if not folder then
        warn("No folder provided to ScanFolder")
        return scannedModules
    end

    for _, descendant in pairs(folder:GetDescendants()) do
        if descendant:IsA("ModuleScript") then
            local success, module_obj = pcall(require, descendant)
            if success then
                scannedModules[descendant.Name] = module_obj
            else
                warn("Failed to require module:", descendant:GetFullName(), module_obj)
            end
        end
    end

    return scannedModules
end


self:_init()
return self
