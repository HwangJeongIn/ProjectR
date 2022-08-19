local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local SkillsFolder = ServerStorage:WaitForChild("Skills")
local CharacterAnimationsFolder = SkillsFolder:WaitForChild("CharacterAnimations")
local AnimationsFolder = CharacterAnimationsFolder:WaitForChild("Animations")
local KeyframeSequencesFolder = CharacterAnimationsFolder:WaitForChild("KeyframeSequences")

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local SkillAnimationTemplate = { 
    Value = {},
}


function SkillAnimationTemplate:Get(skillAnimationName)
    if not skillAnimationName then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.Value[skillAnimationName]
end

function SkillAnimationTemplate:ValidateSkillAnimation(skillAnimation)
    -- 추가 검증 여기에 작성
    return true
end

function SkillAnimationTemplate:ValidateSkillKeyframeSequence(skillKeyframeSequence)
    -- 추가 검증 여기에 작성
    return true
end

-- 로블록스에서 완전히 애니메이션트랙을 만들어서 완전히 로드하기전까지 길이를 확인할 수 없다.
-- 직접 트랙을 만들어서 애니메이션을 재생하기보다 키프레임을 확인하면서 가장 마지막에 있는 키프레임을 찾아내는 방식을 사용한다.
function SkillAnimationTemplate:LoadAnimationLengthFromKeyframes(keyframes)
    local animationLength = 0
    local keyFrameCount = #keyframes
    for i = 1, keyFrameCount do
        local currentTime = keyframes[i].Time
        if currentTime > animationLength then
            animationLength = currentTime
        end
    end
    return animationLength
end

function SkillAnimationTemplate:InitializeAllSkillAnimation()
    local allSkillAnimations = AnimationsFolder:GetChildren()
    for _, skillAnimation in pairs(allSkillAnimations) do
        local skillAnimationName = skillAnimation.Name

        if not self:ValidateSkillAnimation(skillAnimation) then
            Debug.Assert(false, "비정상입니다. => " .. skillAnimationName)
            return false
        end

        local tempSequence = KeyframeSequenceProvider:GetKeyframeSequenceAsync(skillAnimation.AnimationId)
        local keyframes = tempSequence:GetKeyframes()
        local animationLength = self:LoadAnimationLengthFromKeyframes(keyframes)
        tempSequence:Destroy()

        self.Value[skillAnimationName] = {}
        self.Value[skillAnimationName].Animation = skillAnimation
        self.Value[skillAnimationName].AnimationLength = animationLength
    end

    return true
end

function SkillAnimationTemplate:InitializeAllSkillKeyframeSequence()
    local allSkillKeyframeSequences = KeyframeSequencesFolder:GetChildren()
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

        local keyframes = skillKeyframeSequence:GetKeyframes()
        local animationLength = self:LoadAnimationLengthFromKeyframes(keyframes)

        self.Value[skillKeyframeSequenceName] = {}
        self.Value[skillKeyframeSequenceName].Animation = createdAnimation
        self.Value[skillKeyframeSequenceName].AnimationLength = animationLength
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