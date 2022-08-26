local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ResourceTemplateModule = ServerModuleFacade.ResourceTemplateModule


local SkillEffectTemplate = Utility:DeepCopy(require(ResourceTemplateModule:WaitForChild("EffectTemplate")))

function SkillEffectTemplate:Initialize()
    local EffectsFolder = ServerStorage:WaitForChild("Effects")
    local SkillEffects = EffectsFolder:WaitForChild("SkillEffects")

    if not self:InitializeAllEffects(SkillEffects) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end


SkillEffectTemplate:Initialize()
return SkillEffectTemplate