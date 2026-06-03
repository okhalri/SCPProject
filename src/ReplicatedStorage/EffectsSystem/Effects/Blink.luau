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
const ColorCorrection = Lighting:FindFirstChild("ColorCorrection")
const Camera = workspace.CurrentCamera :: Camera

const EffectTweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true)

const LightingGoal = {
    Brightness = -2,
    Ambient = Color3.new(0,0,0),
    ColorShift_Bottom = Color3.new(0,0,0),
    ColorShift_Top = Color3.new(0,0,0),
    OutdoorAmbient = Color3.new(0,0,0)
}

const AtmosphereGoal = {
    Density = 1,
    Offset = 0,
    Color = Color3.new(0,0,0),
    Decay = Color3.new(0,0,0)
}

const ColorCorrectionGoal = {
    Brightness = -.4,
    Contrast = -.4,
    TintColor = Color3.new(0,0,0)
}

const CameraGoal = {
    FieldOfView = 60
}

local db = false

const BlinkEffect: Types.Effect = {
    Run = function(target: Model)
        if db then return end
        db = true
        
        const LightingTween= TweenService:Create(Lighting, EffectTweenInfo, LightingGoal)
        const AtmosphereTween = TweenService:Create(Atmosphere, EffectTweenInfo, AtmosphereGoal)
        const ColorCorrectionEffect = TweenService:Create(ColorCorrection, EffectTweenInfo, ColorCorrectionGoal)
        const CameraTween = TweenService:Create(Camera, EffectTweenInfo, CameraGoal)
        
        LightingTween:Play()
        AtmosphereTween:Play()
        ColorCorrectionEffect:Play()
        CameraTween:Play()
        
        task.wait(.15)
        db = false
    end,
    Stop = function(target: Model)
        
    end
}

return BlinkEffect