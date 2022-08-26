local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))


local EffectTemplate = {
    Value = {},
}


function EffectTemplate:Get(effectName)
    if not effectName then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.Value[effectName]
end

function EffectTemplate:ValidateEffect(effect)
    if effect.Anchored then
        Debug.Print("Effect의 Anchored가 켜져있습니다. 자동으로 꺼집니다. => " .. effect.Name)
        effect.Anchored = false
    end

    if effect.CanTouch then
        Debug.Print("Effect의 CanTouch가 켜져있습니다. 자동으로 꺼집니다. => " .. effect.Name)
        effect.CanTouch = false
    end

    if effect.CanCollide then
        Debug.Print("Effect의 CanCollide가 켜져있습니다. 자동으로 꺼집니다. => " .. effect.Name)
        effect.CanCollide = false
    end

    if effect.CanQuery then
        Debug.Print("Effect의 CanQuery가 켜져있습니다. 자동으로 꺼집니다. => " .. effect.Name)
        effect.CanQuery = false
    end
    
    return true
end

function EffectTemplate:InitializeAllEffects(effectsFolder)
    local allEffects = effectsFolder:GetChildren()
    for _, effect in pairs(allEffects) do
        local effectName = effect.Name
        self.Value[effectName] = effect

        if not self:ValidateEffect(effect) then
            Debug.Assert(false, "비정상입니다. => " .. effectName)
            return false
        end
    end

    return true
end


return EffectTemplate