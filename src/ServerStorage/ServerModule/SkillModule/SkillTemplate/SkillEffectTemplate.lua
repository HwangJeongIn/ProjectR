local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local SkillsFolder = ServerStorage:WaitForChild("Skills")
local SkillEffectsFolder = SkillsFolder:WaitForChild("SkillEffects")


local SkillEffectTemplate = {
    Value = {},
}

function SkillEffectTemplate:Get(skillEffectName)
    if not skillEffectName then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.Value[skillEffectName]
end

function SkillEffectTemplate:ValidateSkillEffect(skillEffect)
    if skillEffect.Anchored then
        Debug.Print("Effect의 Anchored가 켜져있습니다. 자동으로 꺼집니다. => " .. skillEffect.Name)
        skillEffect.Anchored = false
    end
    
    return true
end

function SkillEffectTemplate:InitializeAllSkillEffectTemplates()
    local allSkillEffects = SkillEffectsFolder:GetChildren()
    for _, skillEffect in pairs(allSkillEffects) do
        local skillEffectName = skillEffect.Name
        self.Value[skillEffectName] = skillEffect

        if not self:ValidateSkillEffect(skillEffect) then
            Debug.Assert(false, "비정상입니다. => " .. skillEffectName)
            return false
        end
    end

    return true
end


SkillEffectTemplate:InitializeAllSkillEffectTemplates()
return SkillEffectTemplate