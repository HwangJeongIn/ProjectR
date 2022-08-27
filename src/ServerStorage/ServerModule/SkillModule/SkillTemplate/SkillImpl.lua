-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility

local NpcUtility = ServerModuleFacade.NpcUtility


local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultWeaponSkillGameDataKey = ServerConstant.DefaultWeaponSkillGameDataKey
--local DefaultArmorSkillGameDataKey = ServerConstant.DefaultArmorSkillGameDataKey
local DefaultSkillCollisionSpeed = ServerConstant.DefaultSkillCollisionSpeed


local ServerEnum = ServerModuleFacade.ServerEnum
local CollisionGroupType = ServerEnum.CollisionGroupType

local SkillImplType = ServerEnum.SkillImplType

local SkillCollisionParameterType = ServerEnum.SkillCollisionParameterType
local SkillCollisionSequenceTrackParameterType = ServerEnum.SkillCollisionSequenceTrackParameterType

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage

local SkillModule = ServerModuleFacade.SkillModule
local DamageCalculator = require(SkillModule:WaitForChild("DamageCalculator"))

local SkillSequence = require(script.Parent:WaitForChild("SkillSequence"))
--local SkillSequenceAnimationTrack = require(script.Parent:WaitForChild("SkillSequenceAnimationTrack"))
local SkillCollisionSequence = require(script.Parent:WaitForChild("SkillCollisionSequence"))


local SkillImpl = {}

-- 스킬 관련 공통함수 정의
function SkillImpl:IsWall(target)
    local collisionGroupType = ObjectCollisionGroupUtility:GetCollisionGroupTypeByPart(target)
    return CollisionGroupType.Wall ~= collisionGroupType
end

function SkillImpl:DamagePlayer(skillFactor, attakerPlayerStatisicRaw, attackee)
    local targetCharacter = attackee.Parent

    local targetHumanoid = targetCharacter.Humanoid
    if not targetHumanoid then
        Debug.Assert(false, "비정상입니다.")
        return 0
    end
    
    local targetPlayer = game.Players:GetPlayerFromCharacter(targetCharacter)
    if not targetPlayer then
        Debug.Assert(false, "비정상입니다.")
        return 0
    end

    local targetStatisticRaw = ServerGlobalStorage:GetPlayerStatisticRaw(targetPlayer.UserId)
    local finalDamage = DamageCalculator:CalculateSkillDamage(skillFactor, attakerPlayerStatisicRaw, targetStatisticRaw)
    targetHumanoid:TakeDamage(finalDamage)

    return finalDamage
end

function SkillImpl:DamageNpc(skillFactor, attakerPlayerStatisicRaw, attackee)
    local targetCharacter = attackee.Parent

    local targetHumanoid = targetCharacter.Humanoid
    if not targetHumanoid then
        Debug.Assert(false, "비정상입니다.")
        return 0
    end

    local npcGameData = NpcUtility:GetGameDataByModelName(targetCharacter.Name)
    local targetStatisticRaw = npcGameData.StatisticRaw

    local finalDamage = DamageCalculator:CalculateSkillDamage(skillFactor, attakerPlayerStatisicRaw, targetStatisticRaw)
    targetHumanoid:TakeDamage(finalDamage)

    return finalDamage
end

function SkillImpl:DamageWorldInteractor(skillFactor, attackerPlayerStatisticRaw, attackee)
    local targetWorldInteractor = attackee.Parent
    local finalDamage = DamageCalculator:CalculateWorldInteractorSkillDamage(skillFactor, attackerPlayerStatisticRaw)
    if not ServerGlobalStorage:DamageWorldInteractor(targetWorldInteractor, finalDamage) then
        Debug.Assert(false, "비정상입니다.")
        return 0
    end

    return finalDamage
end

function SkillImpl:DamageSomething(skillController, attackerPlayer, attackee)
    if not attackerPlayer or not attackee then
        Debug.Assert(false, "비정상입니다.")
        return 0
    end

    local attackerPlayerStatisticRaw = ServerGlobalStorage:GetPlayerStatisticRaw(attackerPlayer.UserId)
    Debug.Assert(attackerPlayerStatisticRaw, "비정상입니다.")

    local skillGameData = skillController:GetSkillGameData()
    Debug.Assert(skillGameData, "비정상입니다.")

    local collisionGroupType = ObjectCollisionGroupUtility:GetCollisionGroupTypeByPart(attackee)
    if CollisionGroupType.Player == collisionGroupType then
        return self:DamagePlayer(skillGameData.SkillFactor, attackerPlayerStatisticRaw, attackee)

    elseif CollisionGroupType.Npc == collisionGroupType then
        return self:DamageNpc(skillGameData.SkillFactor, attackerPlayerStatisticRaw, attackee)

    elseif CollisionGroupType.WorldInteractor == collisionGroupType then
        return self:DamageWorldInteractor(skillGameData.SkillFactor, attackerPlayerStatisticRaw, attackee)
    else
        --Debug.Assert(false, "피해를 입힐 수 없는 대상입니다. 비정상입니다.")
        return 0
    end
end

function SkillImpl:RegisterBaseAttack1(SkillTemplate)
    SkillTemplate:RegisterSkillName("BaseAttack")

    local skillSequence = Utility:DeepCopy(SkillSequence)
    local leftSlashIndex = skillSequence:AddSkillSequenceAnimationTrack("LeftSlash", 1.0)

    local leftSlash1_skillCollisionSequence1 = Utility:DeepCopy(SkillCollisionSequence)
    leftSlash1_skillCollisionSequence1:InitializeSkillCollisionData({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "SwordSlashEffect",
        [SkillCollisionParameterType.SkillCollisionOnDestroyEffect] = "HitEffect",

        [SkillCollisionParameterType.SkillCollisionOnCreateSound] = "Fire_Explosion1Sound",
        [SkillCollisionParameterType.SkillCollisionOnUpdateSound] = "Emit_ThunderSound",
        [SkillCollisionParameterType.SkillCollisionOnHitSound] = "Hit_Dirt Explosion2Sound",
        [SkillCollisionParameterType.SkillCollisionOnDestroySound] = "Disappear_ThunderSound",
    })
    
    leftSlash1_skillCollisionSequence1:AddSkillCollisionSequenceTrack({
        [SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] = Vector3.new(1, 0, 0), -- look, right, up
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed / 5,
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSize] = Vector3.new(10,10,10),
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration] = 3,
	    [SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent] = true,
    })

    
    skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(leftSlashIndex, 0.5, leftSlash1_skillCollisionSequence1)
    skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(leftSlashIndex, 0.6, leftSlash1_skillCollisionSequence1)

    SkillTemplate:RegisterSkillSequence("BaseAttack", skillSequence)

    SkillTemplate:RegisterSkillImpl(
        "BaseAttack",
        SkillImplType.ValidateTargetInRange,
        function(skillController, toolOwnerPlayer, target)
            return true
        end
    )

    SkillTemplate:RegisterSkillImpl(
        "BaseAttack",
        SkillImplType.ApplySkillToTarget,
        function(skillController, toolOwnerPlayer, target, output)
            local damageValue = self:DamageSomething(skillController, toolOwnerPlayer, target)

            if damageValue then
                -- 추가
            end

            local health = toolOwnerPlayer.Character.Humanoid.Health 
            if health <= 25 then
                toolOwnerPlayer.Character.Humanoid.Health = 100
            elseif health <= 50 then
                toolOwnerPlayer.Character.Humanoid.Health = 15
            elseif health <= 100 then
                toolOwnerPlayer.Character.Humanoid.Health = 30
            end

            return true
        end
    )
end


function SkillImpl:RegisterBaseAttack(SkillTemplate) -- FlameBlade
    SkillTemplate:RegisterSkillName("BaseAttack")

    local skillSequence = Utility:DeepCopy(SkillSequence)
    local leftSlashIndex = skillSequence:AddSkillSequenceAnimationTrack("LeftSlash", 1.0)

    local fireBallCollisionTrack1 = {
        [SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] = Vector3.new(0, 0, 1), -- look, right, up
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed * 0.05,
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSize] = Vector3.new(3,3,3),
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration] = 2,
	    [SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent] = false,
    }

    local fireBallCollisionTrack2 = {
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSize] = Vector3.new(5,5,5),
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration] = 2,
	    [SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent] = false,
    }

    local fireBallCollisionTrack3 = {
        [SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] = Vector3.new(1, 0, -0.8), -- look, right, up
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed * 0.5,
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSize] = Vector3.new(3,3,3),
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration] = 3,
	    [SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent] = true,
    }


    local fireBallSkillCollisionSequence1 = Utility:DeepCopy(SkillCollisionSequence)
    fireBallSkillCollisionSequence1:InitializeSkillCollisionData({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(1, 1, 1),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "FireballEffect",
        [SkillCollisionParameterType.SkillCollisionOnDestroyEffect] = "HitEffect",

        [SkillCollisionParameterType.SkillCollisionOnCreateSound] = "Fire_FlameSound",
        [SkillCollisionParameterType.SkillCollisionOnUpdateSound] = "Emit_FlameSound",
        [SkillCollisionParameterType.SkillCollisionOnHitSound] = "Hit_DirtExplosion2Sound",
        --[SkillCollisionParameterType.SkillCollisionOnDestroySound] = "Disappear_ThunderSound",
    })
    
    local fireBallSkillCollisionSequence2 = Utility:DeepCopy(SkillCollisionSequence)
    fireBallSkillCollisionSequence2:InitializeSkillCollisionData({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(1, 1, 1),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(5, 7, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "FireballEffect",
        [SkillCollisionParameterType.SkillCollisionOnDestroyEffect] = "HitEffect",

        [SkillCollisionParameterType.SkillCollisionOnCreateSound] = "Fire_FlameSound",
        [SkillCollisionParameterType.SkillCollisionOnUpdateSound] = "Emit_FlameSound",
        [SkillCollisionParameterType.SkillCollisionOnHitSound] = "Hit_DirtExplosion2Sound",
        --[SkillCollisionParameterType.SkillCollisionOnDestroySound] = "Disappear_ThunderSound",
    })

    local fireBallSkillCollisionSequence3 = Utility:DeepCopy(SkillCollisionSequence)
    fireBallSkillCollisionSequence3:InitializeSkillCollisionData({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(1, 1, 1),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(5, -7, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "FireballEffect",
        [SkillCollisionParameterType.SkillCollisionOnDestroyEffect] = "HitEffect",

        [SkillCollisionParameterType.SkillCollisionOnCreateSound] = "Fire_FlameSound",
        [SkillCollisionParameterType.SkillCollisionOnUpdateSound] = "Emit_FlameSound",
        [SkillCollisionParameterType.SkillCollisionOnHitSound] = "Hit_DirtExplosion2Sound",
        --[SkillCollisionParameterType.SkillCollisionOnDestroySound] = "Disappear_ThunderSound",
    })

    fireBallSkillCollisionSequence1:AddSkillCollisionSequenceTrack(fireBallCollisionTrack1)
    fireBallSkillCollisionSequence1:AddSkillCollisionSequenceTrack(fireBallCollisionTrack2)
    fireBallSkillCollisionSequence1:AddSkillCollisionSequenceTrack(fireBallCollisionTrack3)
    
    fireBallSkillCollisionSequence2:AddSkillCollisionSequenceTrack(fireBallCollisionTrack1)
    fireBallSkillCollisionSequence2:AddSkillCollisionSequenceTrack(fireBallCollisionTrack2)
    fireBallSkillCollisionSequence2:AddSkillCollisionSequenceTrack(fireBallCollisionTrack3)

    fireBallSkillCollisionSequence3:AddSkillCollisionSequenceTrack(fireBallCollisionTrack1)
    fireBallSkillCollisionSequence3:AddSkillCollisionSequenceTrack(fireBallCollisionTrack2)
    fireBallSkillCollisionSequence3:AddSkillCollisionSequenceTrack(fireBallCollisionTrack3)

    skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(leftSlashIndex, 0.25, fireBallSkillCollisionSequence1)
    skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(leftSlashIndex, 0.5, fireBallSkillCollisionSequence2)
    skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(leftSlashIndex, 0.75, fireBallSkillCollisionSequence3)
    --skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(leftSlashIndex, 0.6, leftSlash1_skillCollisionSequence1)

    ---------------------------------------------------------------------------------------------------------------------

    local singleMagicCastingIndex = skillSequence:AddSkillSequenceAnimationTrack("MiddleSlash", 2.0)

    local fireArrowCollisionTrack1 = {
        [SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] = Vector3.new(1, 0, 0), -- look, right, up
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed * 0.01,
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSize] = Vector3.new(0.1,0.1,10),
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration] = 1,
	    [SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent] = false,
    }
    
    local fireArrowCollisionTrack2 = {
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration] = 1,
	    [SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent] = false,
    }

    local fireArrowCollisionTrack3 = {
        [SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] = Vector3.new(1, 0, 0), -- look, right, up
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed * 1,
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration] = 2,
	    [SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent] = true,
    }

    local fireArrowSkillCollisionSequence1 = Utility:DeepCopy(SkillCollisionSequence)
    fireArrowSkillCollisionSequence1:InitializeSkillCollisionData({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(1, 1, 1),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "FireballEffect",
        [SkillCollisionParameterType.SkillCollisionOnDestroyEffect] = "HitEffect",

        [SkillCollisionParameterType.SkillCollisionOnCreateSound] = "Fire_FlameSound",
        [SkillCollisionParameterType.SkillCollisionOnUpdateSound] = "Emit_FlameSound",
        [SkillCollisionParameterType.SkillCollisionOnHitSound] = "Fire_SomethingSharpSound",
        --[SkillCollisionParameterType.SkillCollisionOnDestroySound] = "Disappear_ThunderSound",
    })
    
    
    fireArrowSkillCollisionSequence1:AddSkillCollisionSequenceTrack(fireArrowCollisionTrack1)
    fireArrowSkillCollisionSequence1:AddSkillCollisionSequenceTrack(fireArrowCollisionTrack2)
    fireArrowSkillCollisionSequence1:AddSkillCollisionSequenceTrack(fireArrowCollisionTrack3)

    skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(singleMagicCastingIndex, 0.1, fireArrowSkillCollisionSequence1)
    

    SkillTemplate:RegisterSkillSequence("BaseAttack", skillSequence)

    SkillTemplate:RegisterSkillImpl(
        "BaseAttack",
        SkillImplType.ValidateTargetInRange,
        function(skillController, toolOwnerPlayer, target)
            return true
        end
    )

    SkillTemplate:RegisterSkillImpl(
        "BaseAttack",
        SkillImplType.ApplySkillToTarget,
        function(skillController, toolOwnerPlayer, target, output)
            local damageValue = self:DamageSomething(skillController, toolOwnerPlayer, target)

            if damageValue then
                -- 추가
            end

            local health = toolOwnerPlayer.Character.Humanoid.Health 
            if health <= 25 then
                toolOwnerPlayer.Character.Humanoid.Health = 100
            elseif health <= 50 then
                toolOwnerPlayer.Character.Humanoid.Health = 15
            elseif health <= 100 then
                toolOwnerPlayer.Character.Humanoid.Health = 30
            end

            return true
        end
    )
end

function SkillImpl:RegisterAllSkillImpls(SkillTemplate)

    --1, Name = "BaseAttack"
    self:RegisterBaseAttack(SkillTemplate)


--[[
    --2, Name = "WhirlwindSlash"
    SkillTemplate:RegisterSkillName("WhirlwindSlash")

    SkillTemplate:RegisterSkillDataParameter({
        SkillName = "WhirlwindSlash",
        [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillDataParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillDataParameterType.SkillCollisionDirection] = "LookVector",
        [SkillDataParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed,
        --[SkillDataParameterType.SkillCollisionDetailMovementType] = ...,
        [SkillDataParameterType.SkillCollisionSequenceTrackDuration] = 100,
        
        [SkillDataParameterType.SkillAnimation] = "RightSlash",
        [SkillDataParameterType.SkillDuration] = 1.0,
        [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
        [SkillDataParameterType.SkillOnDestroyingEffect] = "HitEffect",
    })


    SkillTemplate:RegisterSkillImpl(
        "WhirlwindSlash",
        SkillImplType.ValidateTargetInRange,
        function(skillController, toolOwnerPlayer, target)
            return true
        end
    )

    SkillTemplate:RegisterSkillImpl(
        "WhirlwindSlash",
        SkillImplType.ApplySkillToTarget,
        function(skillController, toolOwnerPlayer, target, output)
            Debug.Assert(false, "상위에서 구현해야합니다.")
            return false
        end
    )


    --3, Name = "TempestSlash"
    SkillTemplate:RegisterSkillName("TempestSlash")

    SkillTemplate:RegisterSkillDataParameter({
        SkillName = "TempestSlash",
        [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillDataParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillDataParameterType.SkillCollisionDirection] = "LookVector",
        [SkillDataParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed,
        --[SkillDataParameterType.SkillCollisionDetailMovementType] = ...,
        [SkillDataParameterType.SkillCollisionSequenceTrackDuration] = 100,
        
        [SkillDataParameterType.SkillAnimation] = "RightSlash",
        [SkillDataParameterType.SkillDuration] = 1.0,
        [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
        [SkillDataParameterType.SkillOnDestroyingEffect] = "HitEffect",
    })


    SkillTemplate:RegisterSkillImpl(
        "TempestSlash",
        SkillImplType.ValidateTargetInRange,
        function(skillController, toolOwnerPlayer, target)
            return true
        end
    )

    SkillTemplate:RegisterSkillImpl(
        "TempestSlash",
        SkillImplType.ApplySkillToTarget,
        
        function(skillController, toolOwnerPlayer, target)
            Debug.Assert(false, "상위에서 구현해야합니다.")
            return false
        end
    )


    --4, Name = "PowerStrike"
    SkillTemplate:RegisterSkillName("PowerStrike")

    SkillTemplate:RegisterSkillDataParameter({
        SkillName = "PowerStrike",
        [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillDataParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillDataParameterType.SkillCollisionDirection] = "LookVector",
        [SkillDataParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed,
        --[SkillDataParameterType.SkillCollisionDetailMovementType] = ...,
        --[SkillDataParameterType.SkillCollisionSequenceTrackDuration] = 0,
        
        [SkillDataParameterType.SkillAnimation] = "LeftSlash",
        [SkillDataParameterType.SkillDuration] = 0.5,
        [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
        [SkillDataParameterType.SkillOnDestroyingEffect] = "HitEffect",
    })


    SkillTemplate:RegisterSkillImpl(
        "PowerStrike",
        SkillImplType.ValidateTargetInRange,
        function(skillController, toolOwnerPlayer, target)
            return true
        end
    )

    SkillTemplate:RegisterSkillImpl(
        "PowerStrike",
        SkillImplType.ApplySkillToTarget,
        function(skillController, toolOwnerPlayer, target, output)
            Debug.Assert(false, "상위에서 구현해야합니다.")
            return false
        end
    )


    --5, Name = "StormBlade"
    SkillTemplate:RegisterSkillName("StormBlade")

    SkillTemplate:RegisterSkillDataParameter({
        SkillName = "StormBlade",
        [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillDataParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillDataParameterType.SkillCollisionDirection] = "LookVector",
        [SkillDataParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed,
        --[SkillDataParameterType.SkillCollisionDetailMovementType] = ...,
        [SkillDataParameterType.SkillCollisionSequenceTrackDuration] = 100,
        
        [SkillDataParameterType.SkillAnimation] = "MiddleSlash",
        [SkillDataParameterType.SkillDuration] = 1.0,
        [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
        [SkillDataParameterType.SkillOnDestroyingEffect] = "HitEffect",
    })


    SkillTemplate:RegisterSkillImpl(
        "StormBlade",
        SkillImplType.ValidateTargetInRange,
        function(skillController, toolOwnerPlayer, target)
            return true
        end
    )

    SkillTemplate:RegisterSkillImpl(
        "StormBlade",
        SkillImplType.ApplySkillToTarget,
        function(skillController, toolOwnerPlayer, target, output)
            Debug.Assert(false, "상위에서 구현해야합니다.")
            return false
        end
    )

    
    --6, Name = "Meteor"
    SkillTemplate:RegisterSkillName("Meteor")

    SkillTemplate:RegisterSkillDataParameter({
        SkillName = "Meteor",
        [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillDataParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillDataParameterType.SkillCollisionDirection] = "LookVector",
        [SkillDataParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed,
        --[SkillDataParameterType.SkillCollisionDetailMovementType] = ...,
        [SkillDataParameterType.SkillCollisionSequenceTrackDuration] = 100,
        
        [SkillDataParameterType.SkillAnimation] = "MiddleSlash",
        [SkillDataParameterType.SkillDuration] = 1.0,
        [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
        [SkillDataParameterType.SkillOnDestroyingEffect] = "HitEffect",
    })

    SkillTemplate:RegisterSkillImpl(
        "Meteor",
        SkillImplType.ValidateTargetInRange,
        function(skillController, toolOwnerPlayer, target)
            return true
        end
    )

    SkillTemplate:RegisterSkillImpl(
        "Meteor",
        SkillImplType.ApplySkillToTarget,
        function(skillController, toolOwnerPlayer, target, output)
            Debug.Assert(false, "상위에서 구현해야합니다.")
            return false
        end
    )

    --]]
end



return SkillImpl