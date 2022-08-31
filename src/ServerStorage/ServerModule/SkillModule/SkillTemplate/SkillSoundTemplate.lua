local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ResourceTemplateModule = ServerModuleFacade.ResourceTemplateModule

local ServerEnum = ServerModuleFacade.ServerEnum
--local SkillSoundType = ServerEnum.SkillSoundType


-- OnDestroy는 OnHit를 정의하지 않고 OnDestroy만 정의한다.
-- 충돌에 의해 소멸되지 않는 Skill Collision을 구현하기 위해 OnHit와 OnDestroy를 따로 구분하였다.
local SkillSoundTemplate = Utility:DeepCopy(require(ResourceTemplateModule:WaitForChild("SoundTemplate")))

function SkillSoundTemplate:Initialize()
    local SoundsFolder = ServerStorage:WaitForChild("Sounds")
    local SkillSounds = SoundsFolder:WaitForChild("SkillSounds")

    if not self:LoadAllSoundFolders(SkillSounds) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end


SkillSoundTemplate:Initialize()
return SkillSoundTemplate