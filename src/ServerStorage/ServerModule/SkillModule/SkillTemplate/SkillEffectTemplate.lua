local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local SkillsFolder = ServerStorage:WaitForChild("Skills")
local SkillEffectsFolder = SkillsFolder:WaitForChild("Effects")


local SkillEffectTemplate = { 
    Value = {},
}

function SkillEffectTemplate:ValidateSkillEffect(skillEffect)
    -- 추가 검증 여기에 작성
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