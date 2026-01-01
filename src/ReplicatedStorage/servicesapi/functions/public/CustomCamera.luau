local CustomCamera = {}

local plr = game:GetService("Players").LocalPlayer
local camera = game.Workspace.CurrentCamera
local RunS = game:GetService("RunService")

local targetCFrame = nil
local lerpSpeed = 0

if RunS:IsClient() then

    function CustomCamera:_lerpTo(_instance, speed)
        lerpSpeed = speed or 0.1

        -- Determinar targetCFrame una sola vez
        if _instance:IsA("Attachment") then
            targetCFrame = _instance.WorldCFrame
        elseif _instance:IsA("BasePart") then
            targetCFrame = _instance.CFrame
        elseif typeof(_instance) == "CFrame" then
            targetCFrame = _instance
        else
            return
        end

        camera.CameraType = Enum.CameraType.Scriptable
    end

    RunS.RenderStepped:Connect(function()
        if targetCFrame then
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, lerpSpeed)
            if (camera.CFrame.Position - targetCFrame.Position).Magnitude < 0.05 then
                camera.CFrame = targetCFrame
                targetCFrame = nil
            end
        end
    end)

    function CustomCamera:_followPart(instance)
        if not instance then return end

        local camera = workspace.CurrentCamera
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CameraSubject = nil

        if self._conn then
            self._conn:Disconnect()
            self._conn = nil
        end

        self._conn = RunS.RenderStepped:Connect(function()
            if not instance or not instance.Parent then return end

            if instance:IsA("Model") then
                camera.CFrame = instance:GetPivot()
            else
                camera.CFrame = instance.CFrame
            end
        end)
    end

    function CustomCamera:_setCamera(instance)
        camera.CameraType = Enum.CameraType.Scriptable

        if instance:IsA("Model") then
            camera.CFrame = instance:GetPivot()
        else
            camera.CFrame = instance.CFrame
        end
    end


    function CustomCamera:_resetCamera()
        camera.CameraType = Enum.CameraType.Custom
    end

    function CustomCamera:_shake(amount, duration, smoothness, direction, speed, distance, oscillate)
        if duration == 0 or not duration then
            if self._shakeConn then
                self._shakeConn:Disconnect()
                self._shakeConn = nil
            end
            return
        end
        amount = amount or 0.5      
        duration = duration or 0.5   
        smoothness = smoothness or 0.2
        direction = direction or vector.create(0,1,0)
        speed = speed or 1
        distance = distance or 1

        local elapsed = 0
        local currentOffset = 0

        if self._shakeConn then
            self._shakeConn:Disconnect()
            self._shakeConn = nil
        end

        self._shakeConn = RunS.RenderStepped:Connect(function(deltaTime)
            elapsed = elapsed + deltaTime

            if duration ~= math.huge and elapsed >= duration then
                self._shakeConn:Disconnect()
                self._shakeConn = nil
                return
            end

            local baseCFrame = camera.CFrame
            local targetOffsetY = math.sin(elapsed * math.pi * 2 * speed) * amount * distance * direction.Y
            currentOffset = currentOffset + (targetOffsetY - currentOffset) * smoothness
            camera.CFrame = CFrame.new(
                baseCFrame.Position + vector.create(0, currentOffset, 0),
                baseCFrame.Position + baseCFrame.LookVector
            )
        end)
    end

    function CustomCamera:_setFOV(targetFOV, speed)
        speed = speed or 0 

        if self._fovConn then
            self._fovConn:Disconnect()
            self._fovConn = nil
        end

        if speed == 0 then
            camera.FieldOfView = targetFOV
            return
        end

        local currentFOV = camera.FieldOfView
        self._fovConn = RunS.RenderStepped:Connect(function(deltaTime)
            currentFOV = currentFOV + (targetFOV - currentFOV) * math.clamp(speed * deltaTime, 0, 1)
            camera.FieldOfView = currentFOV

            if math.abs(currentFOV - targetFOV) < 0.01 then
                camera.FieldOfView = targetFOV
                if self._fovConn then
                    self._fovConn:Disconnect()
                    self._fovConn = nil
                end
            end
        end)
    end
end
return CustomCamera
