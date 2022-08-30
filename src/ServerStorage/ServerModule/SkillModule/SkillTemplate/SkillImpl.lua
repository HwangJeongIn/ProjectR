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

function SkillImpl:DamagePlayer(skillFactor, attackerPlayer, attackee)
    local attackerPlayerStatisticRaw = ServerGlobalStorage:GetPlayerStatisticRaw(attackerPlayer.UserId)
    Debug.Assert(attackerPlayerStatisticRaw, "비정상입니다.")

    local targetCharacter = attackee.Parent
    if not targetCharacter then
        Debug.Assert(false, "비정상입니다.")
        return 0
    end

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
    local finalDamage = DamageCalculator:CalculateSkillDamage(skillFactor, attackerPlayerStatisticRaw, targetStatisticRaw)
    targetHumanoid:TakeDamage(finalDamage)

    if not ServerGlobalStorage:SetRecentAttackerAndNotify(targetPlayer.UserId, attackerPlayer.Character) then
        Debug.Assert(false, "비정상입니다.")
    end

    return finalDamage
end

function SkillImpl:DamageNpc(skillFactor, attackerPlayer, attackee)

    local attackerPlayerStatisticRaw = ServerGlobalStorage:GetPlayerStatisticRaw(attackerPlayer.UserId)
    Debug.Assert(attackerPlayerStatisticRaw, "비정상입니다.")

    local targetCharacter = attackee.Parent

    local targetHumanoid = targetCharacter.Humanoid
    if not targetHumanoid then
        Debug.Assert(false, "비정상입니다.")
        return 0
    end

    local npcGameData = NpcUtility:GetGameDataByModelName(targetCharacter.Name)
    local targetStatisticRaw = npcGameData.StatisticRaw

    local finalDamage = DamageCalculator:CalculateSkillDamage(skillFactor, attackerPlayerStatisticRaw, targetStatisticRaw)
    targetHumanoid:TakeDamage(finalDamage)

    return finalDamage
end

function SkillImpl:DamageWorldInteractor(skillFactor, attackerPlayer, attackee)
    
    local attackerPlayerStatisticRaw = ServerGlobalStorage:GetPlayerStatisticRaw(attackerPlayer.UserId)
    Debug.Assert(attackerPlayerStatisticRaw, "비정상입니다.")

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

    local skillGameData = skillController:GetSkillGameData()
    Debug.Assert(skillGameData, "비정상입니다.")

    local collisionGroupType = ObjectCollisionGroupUtility:GetCollisionGroupTypeByPart(attackee)
    if CollisionGroupType.Player == collisionGroupType then
        return self:DamagePlayer(skillGameData.SkillFactor, attackerPlayer, attackee)

    elseif CollisionGroupType.Npc == collisionGroupType then
        return self:DamageNpc(skillGameData.SkillFactor, attackerPlayer, attackee)

    elseif CollisionGroupType.WorldInteractor == collisionGroupType then
        return self:DamageWorldInteractor(skillGameData.SkillFactor, attackerPlayer, attackee)
    else
        --Debug.Assert(false, "피해를 입힐 수 없는 대상입니다. 비정상입니다.")
        return 0
    end
end

function SkillImpl:RegisterBaseAttack(SkillTemplate)
    local skillName = "BaseAttack"

    SkillTemplate:RegisterSkillName(skillName)

    local skillSequence = Utility:DeepCopy(SkillSequence)
    local middleSlashIndex = skillSequence:AddSkillSequenceAnimationTrack("LeftDownSlash", 0.5)

    local baseAttackCollisionTrack = {
        [SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] = Vector3.new(1, 0, 0),
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed * .4,
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration] = 1,
	    [SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent] = true,
    }

    local baseAttackSkillCollisionSequence = Utility:DeepCopy(SkillCollisionSequence)
    baseAttackSkillCollisionSequence:InitializeSkillCollisionData({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(0.2, 4, 2),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(3.5, 0, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "BaseSwordSlashEffect",
        [SkillCollisionParameterType.SkillCollisionOnDestroyEffect] = "HitEffect",

        [SkillCollisionParameterType.SkillCollisionOnCreateSound] = "Fire_Explosion3Sound",
        [SkillCollisionParameterType.SkillCollisionOnUpdateSound] = "Emit_AirSound",
        [SkillCollisionParameterType.SkillCollisionOnHitSound] = "Hit_DirtExplosion2Sound",
        --[SkillCollisionParameterType.SkillCollisionOnDestroySound] = "Disappear_ThunderSound",
    })

    baseAttackSkillCollisionSequence:AddSkillCollisionSequenceTrack(baseAttackCollisionTrack)

    ----------------------------------------------------------------------------------------------------------------------------

    skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(middleSlashIndex, 0.1, baseAttackSkillCollisionSequence)
    SkillTemplate:RegisterSkillSequence(skillName, skillSequence)

    SkillTemplate:RegisterSkillImpl(
        skillName,
        SkillImplType.ValidateTargetInRange,
        function(skillController, toolOwnerPlayer, target)
            return true
        end
    )

    SkillTemplate:RegisterSkillImpl(
        skillName,
        SkillImplType.ApplySkillToTarget,
        function(skillController, toolOwnerPlayer, target, output)
            local damageValue = self:DamageSomething(skillController, toolOwnerPlayer, target)
            if damageValue then
                -- 추가
            end
            return true
        end
    )
end


function SkillImpl:RegisterPowerStrike(SkillTemplate)
    local skillName = "PowerStrike"

    SkillTemplate:RegisterSkillName(skillName)

    local skillSequence = Utility:DeepCopy(SkillSequence)
    local middleSlashIndex = skillSequence:AddSkillSequenceAnimationTrack("MiddleSlash", 0.75)

    local baseAttackCollisionTrack = {
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration] = 0.3,
	    [SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent] = true,
    }

    local baseAttackSkillCollisionSequence = Utility:DeepCopy(SkillCollisionSequence)
    baseAttackSkillCollisionSequence:InitializeSkillCollisionData({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(4, 1.5, 4),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(6, 0, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "PowerfulExplosion",
        [SkillCollisionParameterType.SkillCollisionOnDestroyEffect] = "HitEffect",

        [SkillCollisionParameterType.SkillCollisionOnCreateSound] = "Fire_ExplosionSound",
        --[SkillCollisionParameterType.SkillCollisionOnUpdateSound] = "Emit_AirSound",
        --[SkillCollisionParameterType.SkillCollisionOnHitSound] = "Hit_DirtExplosion2Sound",
        --[SkillCollisionParameterType.SkillCollisionOnDestroySound] = "Disappear_ThunderSound",
    })

    baseAttackSkillCollisionSequence:AddSkillCollisionSequenceTrack(baseAttackCollisionTrack)

    ----------------------------------------------------------------------------------------------------------------------------

    skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(middleSlashIndex, 0.1, baseAttackSkillCollisionSequence)
    SkillTemplate:RegisterSkillSequence(skillName, skillSequence)

    SkillTemplate:RegisterSkillImpl(
        skillName,
        SkillImplType.ValidateTargetInRange,
        function(skillController, toolOwnerPlayer, target)
            return true
        end
    )

    SkillTemplate:RegisterSkillImpl(
        skillName,
        SkillImplType.ApplySkillToTarget,
        function(skillController, toolOwnerPlayer, target, output)
            local damageValue = self:DamageSomething(skillController, toolOwnerPlayer, target)
            if damageValue then
                -- 추가
            end
            return true
        end
    )
end

function SkillImpl:RegisterFlameBlade(SkillTemplate) -- Flame Blade
    local skillName = "FlameBlade"

    SkillTemplate:RegisterSkillName(skillName)

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
    

    SkillTemplate:RegisterSkillSequence(skillName, skillSequence)

    SkillTemplate:RegisterSkillImpl(
        skillName,
        SkillImplType.ValidateTargetInRange,
        function(skillController, toolOwnerPlayer, target)
            return true
        end
    )

    SkillTemplate:RegisterSkillImpl(
        skillName,
        SkillImplType.ApplySkillToTarget,
        function(skillController, toolOwnerPlayer, target, output)
            local damageValue = self:DamageSomething(skillController, toolOwnerPlayer, target)
            if damageValue then
                -- 추가
            end
            return true
        end
    )
end

function SkillImpl:RegisterStormBlade(SkillTemplate) -- Storm Blade
    local skillName = "StormBlade"

    SkillTemplate:RegisterSkillName(skillName)

    local skillSequence = Utility:DeepCopy(SkillSequence)
    local middleSlashIndex = skillSequence:AddSkillSequenceAnimationTrack("LeftDownSlash", 0.5)

    local airBladeCollisionTrack = {
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed] = DefaultSkillCollisionSpeed * .3,
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSize] = Vector3.new(2.5, 1.5, 2.5),
        [SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration] = 1,
	    [SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent] = true,
    }

    
    local airBladeCollisionTrack1_1 = Utility:DeepCopy(airBladeCollisionTrack)
    airBladeCollisionTrack1_1[SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] = Vector3.new(2, 1, 0) -- look, right, up

    local airBladeCollisionTrack1_2 = Utility:DeepCopy(airBladeCollisionTrack)
    airBladeCollisionTrack1_2[SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] = Vector3.new(1, 0, 0) -- look, right, up

    local airBladeCollisionTrack1_3 = Utility:DeepCopy(airBladeCollisionTrack)
    airBladeCollisionTrack1_3[SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] = Vector3.new(2, -1, 0) -- look, right, up


    local airBladeSkillCollisionSequence1 = Utility:DeepCopy(SkillCollisionSequence)
    airBladeSkillCollisionSequence1:InitializeSkillCollisionData({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(.5, 3.5, 2),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(3.5, 0, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "SwordSlashEffect",
        [SkillCollisionParameterType.SkillCollisionOnDestroyEffect] = "HitEffect",

        [SkillCollisionParameterType.SkillCollisionOnCreateSound] = "Fire_Explosion3Sound",
        [SkillCollisionParameterType.SkillCollisionOnUpdateSound] = "Emit_AirSound",
        [SkillCollisionParameterType.SkillCollisionOnHitSound] = "Hit_DirtExplosion2Sound",
        --[SkillCollisionParameterType.SkillCollisionOnDestroySound] = "Disappear_ThunderSound",
    })

    
    local airBladeSkillCollisionSequence2 = Utility:DeepCopy(airBladeSkillCollisionSequence1)
    local airBladeSkillCollisionSequence3 = Utility:DeepCopy(airBladeSkillCollisionSequence1)

    airBladeSkillCollisionSequence1:AddSkillCollisionSequenceTrack(airBladeCollisionTrack1_1)
    airBladeSkillCollisionSequence2:AddSkillCollisionSequenceTrack(airBladeCollisionTrack1_2)
    airBladeSkillCollisionSequence3:AddSkillCollisionSequenceTrack(airBladeCollisionTrack1_3)
    
    -- 오른쪽 중앙 왼쪽
    skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(middleSlashIndex, 0.1, airBladeSkillCollisionSequence3)
    skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(middleSlashIndex, 0.3, airBladeSkillCollisionSequence2)
    skillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(middleSlashIndex, 0.5, airBladeSkillCollisionSequence1)
    
    SkillTemplate:RegisterSkillSequence(skillName, skillSequence)

    SkillTemplate:RegisterSkillImpl(
        skillName,
        SkillImplType.ValidateTargetInRange,
        function(skillController, toolOwnerPlayer, target)
            return true
        end
    )

    SkillTemplate:RegisterSkillImpl(
        skillName,
        SkillImplType.ApplySkillToTarget,
        function(skillController, toolOwnerPlayer, target, output)
            local damageValue = self:DamageSomething(skillController, toolOwnerPlayer, target)
            if damageValue then
                -- 추가
            end
            return true
        end
    )
end

function SkillImpl:RegisterLightningVortex(SkillTemplate) -- Lightning Vortex
end

function SkillImpl:RegisterAuraBlade(SkillTemplate) -- Aura Blade
end


function SkillImpl:RegisterAllSkillImpls(SkillTemplate)
    self:RegisterBaseAttack(SkillTemplate)
    self:RegisterPowerStrike(SkillTemplate)
    
    self:RegisterFlameBlade(SkillTemplate)
    self:RegisterStormBlade(SkillTemplate)
    self:RegisterLightningVortex(SkillTemplate)
    self:RegisterAuraBlade(SkillTemplate)
end



return SkillImpl