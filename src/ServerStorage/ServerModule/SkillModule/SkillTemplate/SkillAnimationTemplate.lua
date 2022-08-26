local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ResourceTemplateModule = ServerModuleFacade.ResourceTemplateModule


local SkillAnimationTemplate = Utility:DeepCopy(require(ResourceTemplateModule:WaitForChild("AnimationTemplate")))

function SkillAnimationTemplate:Initialize()
    local RootAnimationsFolder = ServerStorage:WaitForChild("Animations")
    local SkillAnimationsFolder = RootAnimationsFolder:WaitForChild("SkillAnimations")
    local AnimationsFolder = SkillAnimationsFolder:WaitForChild("Animations")
    local KeyframeSequencesFolder = SkillAnimationsFolder:WaitForChild("KeyframeSequences")

    if not self:InitializeAllAnimationTemplates(AnimationsFolder, KeyframeSequencesFolder) then
        Debug.Assert(false, "InitializeAllAnimations에 실패했습니다.")
        return false
    end

    return true
end


SkillAnimationTemplate:Initialize()
return SkillAnimationTemplate