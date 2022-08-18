local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local SkillsFolder = ServerStorage:WaitForChild("Skills")
local SkillAnimationsFolder = SkillsFolder:WaitForChild("Animations")
local SkillKeyframeSequencesFolder = SkillsFolder:WaitForChild("KeyframeSequences")

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local SkillAnimationTemplate = { 
    Value = {},
}


function SkillAnimationTemplate:ValidateSkillAnimation(skillAnimation)
    -- 추가 검증 여기에 작성
    return true
end

function SkillAnimationTemplate:ValidateSkillKeyframeSequence(skillKeyframeSequence)
    -- 추가 검증 여기에 작성
    return true
end

function SkillAnimationTemplate:InitializeAllSkillAnimation()
    local allSkillAnimations = SkillAnimationsFolder:GetChildren()
    for _, skillAnimation in pairs(allSkillAnimations) do
        local skillAnimationName = skillAnimation.Name

        if not self:ValidateSkillAnimation(skillAnimation) then
            Debug.Assert(false, "비정상입니다. => " .. skillAnimationName)
            return false
        end

        self.Value[skillAnimationName] = skillAnimation
    end

    return true
end

function SkillAnimationTemplate:InitializeAllSkillKeyframeSequence()
    local allSkillKeyframeSequences = SkillKeyframeSequencesFolder:GetChildren()
    for _, skillKeyframeSequence in pairs(allSkillKeyframeSequences) do
        local skillKeyframeSequenceName = skillKeyframeSequence.Name

        if not self:ValidateSkillKeyframeSequence(skillKeyframeSequenceName) then
            Debug.Assert(false, "비정상입니다. => " .. skillKeyframeSequenceName)
            return false
        end

        local hashId = KeyframeSequenceProvider:RegisterKeyframeSequence(skillKeyframeSequence) 
        if not hashId then
            Debug.Assert(false, "무슨일인지 확인해야합니다.")
            return false
        end

        local createdAnimation = Instance.new("Animation")
        createdAnimation.AnimationId = hashId

        if not self:ValidateSkillAnimation(createdAnimation) then
            Debug.Assert(false, "비정상입니다. => " .. skillKeyframeSequenceName)
            return false
        end

        self.Value[skillKeyframeSequenceName] = createdAnimation
    end

    return true
end

function SkillAnimationTemplate:InitializeAllSkillAnimationTemplates()
    if not self:InitializeAllSkillAnimation() then
        Debug.Assert(false, "InitializeAllSkillAnimation에 실패했습니다.")
        return false
    end

    if not self:InitializeAllSkillKeyframeSequence() then
        Debug.Assert(false, "InitializeAllSkillKeyframeSequence에 실패했습니다.")
        return false
    end

    return true
end


SkillAnimationTemplate:InitializeAllSkillAnimationTemplates()
return SkillAnimationTemplate