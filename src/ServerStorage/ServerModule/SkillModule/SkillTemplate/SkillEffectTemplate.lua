local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug


local EffectTemplate = {
    Value = {},
}

function EffectTemplate:Get(EffectName)
    if not EffectName then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.Value[EffectName]
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

function EffectTemplate:InitializeAllEffectTemplates()
    local EffectsFolder = ServerStorage:WaitForChild("Effects")
    local SkillEffects = EffectsFolder:WaitForChild("SkillEffects")

    if not self:InitializeAllEffects(SkillEffects) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end


EffectTemplate:InitializeAllEffectTemplates()
return EffectTemplate