local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local AnimationTemplate = { 
    Value = {},
}


function AnimationTemplate:Get(animationName)
    if not animationName then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.Value[animationName]
end

function AnimationTemplate:ValidateAnimation(animation)
    -- 추가 검증 여기에 작성
    return true
end

function AnimationTemplate:ValidateKeyframeSequence(keyframeSequence)
    -- 추가 검증 여기에 작성
    return true
end

-- 로블록스에서 완전히 애니메이션트랙을 만들어서 완전히 로드하기전까지 길이를 확인할 수 없다.
-- 직접 트랙을 만들어서 애니메이션을 재생하기보다 키프레임을 확인하면서 가장 마지막에 있는 키프레임을 찾아내는 방식을 사용한다.
function AnimationTemplate:LoadAnimationLengthFromKeyframes(keyframes)
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

function AnimationTemplate:InitializeAllAnimations(animationFolder)
    local allAnimations = animationFolder:GetChildren()
    for _, animation in pairs(allAnimations) do
        local animationName = animation.Name

        if not self:ValidateAnimation(animation) then
            Debug.Assert(false, "비정상입니다. => " .. animationName)
            return false
        end

        local tempSequence = KeyframeSequenceProvider:GetKeyframeSequenceAsync(animation.AnimationId)
        local keyframes = tempSequence:GetKeyframes()
        local animationLength = self:LoadAnimationLengthFromKeyframes(keyframes)
        tempSequence:Destroy()

        self.Value[animationName] = {}
        self.Value[animationName].Animation = animation
        self.Value[animationName].AnimationLength = animationLength
    end

    return true
end

function AnimationTemplate:InitializeAllKeyframeSequences(keyframeSequencesFolder)
    local allKeyframeSequences = keyframeSequencesFolder:GetChildren()
    for _, KeyframeSequence in pairs(allKeyframeSequences) do
        local KeyframeSequenceName = KeyframeSequence.Name

        if not self:ValidateKeyframeSequence(KeyframeSequenceName) then
            Debug.Assert(false, "비정상입니다. => " .. KeyframeSequenceName)
            return false
        end

        local hashId = KeyframeSequenceProvider:RegisterKeyframeSequence(KeyframeSequence) 
        if not hashId then
            Debug.Assert(false, "무슨일인지 확인해야합니다.")
            return false
        end

        local createdAnimation = Instance.new("Animation")
        createdAnimation.AnimationId = hashId

        if not self:ValidateAnimation(createdAnimation) then
            Debug.Assert(false, "비정상입니다. => " .. KeyframeSequenceName)
            return false
        end

        local keyframes = KeyframeSequence:GetKeyframes()
        local animationLength = self:LoadAnimationLengthFromKeyframes(keyframes)

        self.Value[KeyframeSequenceName] = {}
        self.Value[KeyframeSequenceName].Animation = createdAnimation
        self.Value[KeyframeSequenceName].AnimationLength = animationLength
    end

    return true
end

function AnimationTemplate:InitializeAllAnimationTemplates()

    -- 더쓰는 곳이 나오면 이 파일을 공통 코드로 대체할 예정이다.
    local RootAnimationsFolder = ServerStorage:WaitForChild("Animations")
    local SkillAnimationsFolder = RootAnimationsFolder:WaitForChild("SkillAnimations")
    local AnimationsFolder = SkillAnimationsFolder:WaitForChild("Animations")
    local KeyframeSequencesFolder = SkillAnimationsFolder:WaitForChild("KeyframeSequences")

    if not self:InitializeAllAnimations(AnimationsFolder) then
        Debug.Assert(false, "InitializeAllAnimations에 실패했습니다.")
        return false
    end

    if not self:InitializeAllKeyframeSequences(KeyframeSequencesFolder) then
        Debug.Assert(false, "InitializeAllKeyframeSequences에 실패했습니다.")
        return false
    end

    return true
end


AnimationTemplate:InitializeAllAnimationTemplates()
return AnimationTemplate