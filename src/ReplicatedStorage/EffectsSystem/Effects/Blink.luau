--!strict
--[[
	Implements the blink effect in the Effect Type
]]

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const TweenService = game:GetService("TweenService")
const Lighting = game:GetService("Lighting")

const EffectsSystem = ReplicatedStorage.EffectsSystem
const Types = require(EffectsSystem.Types)

const Atmosphere = Lighting:FindFirstChild("Atmosphere")

const EffectTweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true)

const LightingGoal = {
    Brightness = -2,
    OutdoorAmbiet = Color3.new(0,0,0)
}
const AtmosphereGoal = {
    Density = 1,
    Offset = 0,
    Color = Color3.new(0,0,0),
    Decay = Color3.new(0,0,0)
}

const BlinkEffect: Types.Effect = {
    Run = function(target: Model)
        const LightingTween, AtmosphereTween = TweenService:Create(Lighting, EffectTweenInfo, LightingGoal), TweenService:Create(Atmosphere, EffectTweenInfo, AtmosphereGoal)
        LightingTween:Play()
        AtmosphereTween:Play()
    end,
    Stop = function(target: Model)
        
    end
}

return BlinkEffect