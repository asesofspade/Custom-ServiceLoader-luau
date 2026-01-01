local GroundImpact = {}
local TweenService = game:GetService("TweenService")

GroundImpact.DefaultSize = Vector3.new(1,1,1)
GroundImpact.DefaultColor = Color3.fromRGB(120, 120, 120)
GroundImpact.DefaultMaterial = Enum.Material.Slate
GroundImpact.DefaultDuration = 2 

function GroundImpact:SpawnPart(cframe, options)
    options = options or {}

    local size = options.size or self.DefaultSize
    local color = options.color or self.DefaultColor
    local material = options.material or self.DefaultMaterial
    local duration = options.duration or self.DefaultDuration
    local anchored = options.anchored
    if anchored == nil then anchored = true end

    local part = Instance.new("Part")
    part.Size = size
    part.Anchored = anchored
    part.CanCollide = false
    part.Material = material
    part.Color = color
    part.CFrame = cframe
    part.Parent = workspace

    return part, duration
end

function GroundImpact:SpawnAroundCFrame(cframe, count, radius, options)
    options = options or {}
    count = count or 8
    radius = radius or 2

    local parts = {}
    local centerPos = Vector3.new(cframe.Position.X, 0, cframe.Position.Z) -- fuerza Y=0

    for i = 1, count do
        local angle = (i-1) * (360 / count)
        local rad = math.rad(angle)
        local offset = Vector3.new(math.cos(rad)*radius, 0, math.sin(rad)*radius)
        local finalPos = centerPos + offset
        local partCFrame = CFrame.new(finalPos)
        local newPart, duration = self:SpawnPart(partCFrame, options)

        newPart.CFrame = CFrame.new(finalPos.X, -2, finalPos.Z)

        local upTween = TweenService:Create(newPart, TweenInfo.new(duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(finalPos)})
        upTween:Play()

        upTween.Completed:Connect(function()
            local downPos = finalPos - Vector3.new(0, 2, 0)
            local downTween = TweenService:Create(newPart, TweenInfo.new(duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = CFrame.new(downPos)})
            downTween:Play()
            downTween.Completed:Connect(function()
                if newPart and newPart.Parent then
                    newPart:Destroy()
                end
            end)
        end)

        table.insert(parts, newPart)
    end

    return parts
end

function GroundImpact:SpawnAroundPartWithOffset(part, offset, count, radius, options)
    if not part then return end
    local cframe = part.CFrame * CFrame.new(offset or Vector3.new(0,0,0))
    return self:SpawnAroundCFrame(cframe, count, radius, options)
end

return GroundImpact
