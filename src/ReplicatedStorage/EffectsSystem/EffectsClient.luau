--!strict
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const EffectsSystem = ReplicatedStorage.EffectsSystem
const Types = require(EffectsSystem.Types)

const Blink = require(ReplicatedStorage.Blink.Client)

const Effects: {[string]: Types.Effect}  = {}

for _, ModuleScript in EffectsSystem.Effects:GetChildren() do
    if not ModuleScript:IsA("ModuleScript") then
        warn(ModuleScript.Name .. "is not an effect and is placed into the effects table.")
        continue
    end

    Effects[ModuleScript.Name] = (require)(ModuleScript)
end

const EffectsClient = {}

function EffectsClient.RunEffect(Effect: string, Targets: {Model})
    const EffectModule = Effects[Effect]
    assert(EffectModule, `{Effect} is not a valid Effect`)
    for _, Target in Targets do
        EffectModule.Run(Target)
    end
end

function EffectsClient.StopEffect(Effect: string, Targets: {Model})
    const EffectModule = Effects[Effect]
    assert(EffectModule, `{Effect} is not a valid Effect`)
    for _, Target in Targets do
        EffectModule.Run(Target)
    end
end

Blink.EffectsSystem.RunEffect.On(function(Value: { Effect: string, Targets: {Model} })  EffectsClient.RunEffect(Value.Effect, Value.Targets)  end)
Blink.EffectsSystem.StopEffect.On(function(Value: { Effect: string, Targets: {Model} }) EffectsClient.StopEffect(Value.Effect, Value.Targets) end)

return EffectsClient