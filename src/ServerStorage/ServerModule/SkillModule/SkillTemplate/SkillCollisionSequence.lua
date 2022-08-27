local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility

local ServerEnum = ServerModuleFacade.ServerEnum

local SkillCollisionParameterType = ServerEnum.SkillCollisionParameterType
local SkillCollisionParameterTypeConverter = SkillCollisionParameterType.Converter
local SkillCollisionSequenceTrackParameterType = ServerEnum.SkillCollisionSequenceTrackParameterType
local SkillCollisionSequenceTrackParameterTypeConverter = SkillCollisionSequenceTrackParameterType.Converter


local SkillEffectTemplate = require(script.Parent:WaitForChild("SkillEffectTemplate"))
local SkillSoundTemplate = require(script.Parent:WaitForChild("SkillSoundTemplate"))
local SkillCollisionSequenceTrack = require(script.Parent:WaitForChild("SkillCollisionSequenceTrack"))

local SkillCollisionSequence = {
    SkillCollisionData = {},
    SkillCollisionSequenceTracks = {},
    SkillCollisionSequenceTrackCount = 0
}


function SkillCollisionSequence:ValidateSkillCollisionParameter(skillCollisionParameter)
    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionSize] then
        Debug.Assert(false, "SkillCollisionSize 가 없습니다.")
        return false
    end

    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOffset] then
        Debug.Assert(false, "SkillCollisionOffset 가 없습니다.")
        return false
    end
    
    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionEffect] then
        Debug.Assert(false, "SkillCollisionEffect 가 없습니다.")
        return false
    end
    
    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnDestroyEffect] then
        Debug.Assert(false, "SkillCollisionOnDestroyEffect 가 없습니다.")
        return false
    end
    
    --[[
    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnCreateSound] then
        Debug.Assert(false, "SkillCollisionOnCreateSound 가 없습니다.")
        return false
    end
    
    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnUpdateSound] then
        Debug.Assert(false, "SkillCollisionOnUpdateSound 가 없습니다.")
        return false
    end
    
    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnHitSound] then
        Debug.Assert(false, "SkillCollisionOnHitSound 가 없습니다.")
        return false
    end
    
    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnDestroySound] then
        Debug.Assert(false, "SkillCollisionOnDestroySound 가 없습니다.")
        return false
    end
    --]]

    return true
end

function SkillCollisionSequence:InitializeSkillCollisionData(skillCollisionParameter)
    --[[ 예시
    SkillCollisionSequence:InitializeSkillCollisionData({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "SwordSlashEffect",
        [SkillCollisionParameterType.SkillCollisionOnDestroyEffect] = "HitEffect"
    })
    --]]

    if not self:ValidateSkillCollisionParameter(skillCollisionParameter) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    -- Effect
    local skillCollisionEffectName = skillCollisionParameter[SkillCollisionParameterType.SkillCollisionEffect]
    local skillCollisionEffect = SkillEffectTemplate:Get(skillCollisionEffectName)
    if not skillCollisionEffect then
        Debug.Assert(false, "해당 이름을 가진 이펙트가 존재하지 않습니다. => " .. skillCollisionEffect)
        return false
    end
    skillCollisionParameter[SkillCollisionParameterType.SkillCollisionEffect] = skillCollisionEffect

    local skillCollisionOnDestroyEffectName = skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnDestroyEffect]
    local skillCollisionOnDestroyEffect = SkillEffectTemplate:Get(skillCollisionOnDestroyEffectName)
    if not skillCollisionOnDestroyEffect then
        Debug.Assert(false, "해당 이름을 가진 이펙트가 존재하지 않습니다. => " .. skillCollisionOnDestroyEffect)
        return false
    end
    skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnDestroyEffect] = skillCollisionOnDestroyEffect


    -- Sound

    -- OnCreate
    local skillCollisionOnCreateSoundName = skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnCreateSound]
    if skillCollisionOnCreateSoundName then
        local skillCollisionOnCreateSound = SkillSoundTemplate:Get(skillCollisionOnCreateSoundName)
        if not skillCollisionOnCreateSound then
            Debug.Assert(false, "해당 이름을 가진 사운드가 존재하지 않습니다. => " .. skillCollisionOnCreateSoundName)
            return false
        end

        if skillCollisionOnCreateSound.Looped then
            Debug.Print(false, "OnCreateSound 에 Looped를 사용하면 안됩니다. => " .. skillCollisionOnCreateSound.Name)
            skillCollisionOnCreateSound.Looped = false
        end

        skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnCreateSound] = skillCollisionOnCreateSound
    end
    
    -- OnUpdate
    local skillCollisionOnUpdateSoundName = skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnUpdateSound]
    if skillCollisionOnUpdateSoundName then
        local skillCollisionOnUpdateSound = SkillSoundTemplate:Get(skillCollisionOnUpdateSoundName)
        if not skillCollisionOnUpdateSound then
            Debug.Assert(false, "해당 이름을 가진 사운드가 존재하지 않습니다. => " .. skillCollisionOnUpdateSoundName)
            return false
        end

        if not skillCollisionOnUpdateSound.Looped then
            Debug.Print("OnUpdateSound 에는 Looped를 사용해야합니다. => " .. skillCollisionOnUpdateSound.Name)
            skillCollisionOnUpdateSound.Looped = true
        end

        skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnUpdateSound] = skillCollisionOnUpdateSound
    end

    -- OnHit
    local skillCollisionOnHitSoundName = skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnHitSound]
    if skillCollisionOnHitSoundName then
        local skillCollisionOnHitSound = SkillSoundTemplate:Get(skillCollisionOnHitSoundName)
        if not skillCollisionOnHitSound then
            Debug.Assert(false, "해당 이름을 가진 사운드가 존재하지 않습니다. => " .. skillCollisionOnHitSoundName)
            return false
        end

        if skillCollisionOnHitSound.Looped then
            Debug.Print("OnHitSound 에 Looped를 사용하면 안됩니다. => " .. skillCollisionOnHitSound.Name)
            skillCollisionOnHitSound.Looped = false
        end

        skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnHitSound] = skillCollisionOnHitSound
    end

    -- OnDestroy
    local skillCollisionOnDestroySoundName = skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnDestroySound]
    if skillCollisionOnDestroySoundName then
        local skillCollisionOnDestroySound = SkillSoundTemplate:Get(skillCollisionOnDestroySoundName)
        if not skillCollisionOnDestroySound then
            Debug.Assert(false, "해당 이름을 가진 사운드가 존재하지 않습니다. => " .. skillCollisionOnDestroySoundName)
            return false
        end

        if skillCollisionOnDestroySound.Looped then
            Debug.Print("OnDestroySound 에 Looped를 사용하면 안됩니다. => " .. skillCollisionOnDestroySound.Name)
            skillCollisionOnDestroySound.Looped = false
        end

        skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnDestroySound] = skillCollisionOnDestroySound
    end

    self.SkillCollisionData = skillCollisionParameter
    return true
end


function SkillCollisionSequence:AddSkillCollisionSequenceTrack(skillCollisionSequenceTrackParameter)
    --[[ 예시
    SkillCollisionSequence:AddSkillCollisionSequenceTrack({
        [skillCollisionSequenceTrackParameter.SkillCollisionDirection] = Vector3.new(1, 0, 0), -- look, right, up
        [skillCollisionSequenceTrackParameter.SkillCollisionSpeed] = DefaultSkillCollisionSpeed,
        [skillCollisionSequenceTrackParameter.SkillCollisionSequenceTrackDuration] = 1,
    })
    --]]

    local skillCollisionSequenceTrack = Utility:DeepCopy(SkillCollisionSequenceTrack)
    if not skillCollisionSequenceTrack:Initialize(skillCollisionSequenceTrackParameter) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    table.insert(self.SkillCollisionSequenceTracks, skillCollisionSequenceTrack)
    self.SkillCollisionSequenceTrackCount += 1
    return true
end

function SkillCollisionSequence:IsValid()
    return 0 ~= self.SkillCollisionSequenceTrackCount
end

function SkillCollisionSequence:GetSkillCollisionSequenceTrackCount()
    return self.SkillCollisionSequenceTrackCount
end

function SkillCollisionSequence:GetSkillCollisionSequenceTrack(trackIndex)
    if 0 >= trackIndex or self.SkillCollisionSequenceTrackCount < trackIndex then
        Debug.Assert(false, "트랙인덱스가 비정상입니다.")
        return nil
    end

    return self.SkillCollisionSequenceTracks[trackIndex]
end

function SkillCollisionSequence:GetSkillCollisionSequenceTrackData(trackIndex, skillCollisionSequenceTrackParameterType)
    if not SkillCollisionSequenceTrackParameterTypeConverter[skillCollisionSequenceTrackParameterType] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    local targetTrack = self:GetTrack(trackIndex)
    if not targetTrack then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return targetTrack:GetData(skillCollisionSequenceTrackParameterType)
end

function SkillCollisionSequence:GetSkillCollisionData(skillCollisionParameterType)
    if not SkillCollisionParameterTypeConverter[skillCollisionParameterType] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.SkillCollisionData[skillCollisionParameterType]
end


return SkillCollisionSequence