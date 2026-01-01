local Trail = {}
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local trailRigTemplate = game:GetService("ReplicatedStorage").Assets.Trail
local SpeedParticle = game:GetService("ReplicatedStorage").Assets.Speed

local function isValidPart(part)
    return part and part:IsA("BasePart") and part.Name ~= "HumanoidRootPart"
end

local function createTrailInstance(player, options)
    local transparency = options.value or 0.5
    local color = options.color or Color3.new(1,1,1)
    local fadeTime = options.fadeTime or 0.3
    local backOffset = options.backOffset or -2

    local character = player
    if not character or not character.PrimaryPart then return end

    local clone = trailRigTemplate:Clone()
    clone.Name = player.Name.."_Trail"
    clone.Parent = workspace

    cloneSpeed = SpeedParticle:Clone()
    cloneSpeed.Parent = player
    cloneSpeed.CFrame = player.PrimaryPart.CFrame

local baseCFrame = character.PrimaryPart.CFrame * CFrame.new(0, 0, -backOffset)
    
    for _, part in ipairs(clone:GetDescendants()) do
        if isValidPart(part) then
            part.Anchored = false
            part.CanCollide = false
            part.Massless = true
            part.Transparency = transparency
            part.Color = color
            part.Material = Enum.Material.Plastic

            TweenService:Create(part, TweenInfo.new(fadeTime), {Transparency = 1}):Play()
        end
    end

    if clone.PrimaryPart then
        clone:SetPrimaryPartCFrame(baseCFrame)
    end

    task.delay(fadeTime, function()
        if clone and clone.Parent then
            clone:Destroy()
        end
    end)
end

function Trail.RigTrail(player, options)
    options = options or {}
    local duration = options.duration or 1
    local interval = options.interval or 0.05

    task.spawn(function()
        local elapsed = 0
        while elapsed < duration do
            createTrailInstance(player, options)
            task.wait(interval)
            elapsed = elapsed + interval
        end
    end)
end

return Trail
