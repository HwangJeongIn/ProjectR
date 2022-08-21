-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility


local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultWeaponSkillGameDataKey = ServerConstant.DefaultWeaponSkillGameDataKey
--local DefaultArmorSkillGameDataKey = ServerConstant.DefaultArmorSkillGameDataKey


local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType
local CollisionGroupType = ServerEnum.CollisionGroupType

local SkillDataType = ServerEnum.SkillDataType
local EquipType = ServerEnum.EquipType
local WorldInteractorType = ServerEnum.WorldInteractorType
local SkillImplType = ServerEnum.SkillImplType
local SkillImplTypeConverter = SkillImplType.Converter
local SkillDataParameterType = ServerEnum.SkillDataParameterType
local SkillDataParameterTypeConverter = SkillDataParameterType.Converter

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager
local Debug = ServerModuleFacade.Debug

local SkillImpl = { 
}

-- 스킬 관련 공통함수 정의
function SkillImpl:IsWall(target)
    local collisionGroupType = ObjectCollisionGroupUtility:GetCollisionGroupTypeByPart(target)
    return CollisionGroupType.Wall ~= collisionGroupType
end

function SkillImpl:RegisterAllSkillImpls(SkillTemplate)

    --1, Name = "BaseAttack"
    SkillTemplate:RegisterSkillName("BaseAttack")

    -- 데이터 로드해서 받아올 수 있도록 수정하면 좋을듯
    SkillTemplate:RegisterSkillDataParameter({
        SkillName = "BaseAttack",
        [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillDataParameterType.SkillCollisionOffset] = Vector2.new(5, 0),
        [SkillDataParameterType.SkillCollisionDirection] = "LookVector",
        [SkillDataParameterType.SkillCollisionSpeed] = 50,
        --[SkillDataParameterType.SkillCollisionDetailMovementType] = ...,
        [SkillDataParameterType.SkillCollisionDuration] = 100,
        
        [SkillDataParameterType.SkillAnimation] = "LeftSlash",
        [SkillDataParameterType.SkillDuration] = 1.0,
        [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
    })


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
            local collisionGroupType = ObjectCollisionGroupUtility:GetCollisionGroupTypeByPart(target)
            if CollisionGroupType.Player == collisionGroupType or CollisionGroupType.Npc == collisionGroupType then

                local targetCharacter = target.Parent
                local targetPlayer = game.Players:GetPlayerByUserId(targetCharacter)
                if not targetPlayer then
                    Debug.Assert(false, "대상 캐릭터가 없습니다.")
                    return false
                end

                local targetHumanoid = targetCharacter.Humanoid
                if not targetHumanoid then

                    --local tempPlayerId
                    --ServerGlobalStorage:GetStat(tempPlayerId, )
                end

            elseif CollisionGroupType.WorldInteractor == collisionGroupType then

            end

            return true
        end
    )


    --2, Name = "WhirlwindSlash"
    SkillTemplate:RegisterSkillName("WhirlwindSlash")

    SkillTemplate:RegisterSkillDataParameter({
        SkillName = "WhirlwindSlash",
        [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillDataParameterType.SkillCollisionOffset] = Vector2.new(5, 0),
        [SkillDataParameterType.SkillCollisionDirection] = "LookVector",
        [SkillDataParameterType.SkillCollisionSpeed] = 50,
        --[SkillDataParameterType.SkillCollisionDetailMovementType] = ...,
        [SkillDataParameterType.SkillCollisionDuration] = 100,
        
        [SkillDataParameterType.SkillAnimation] = "RightSlash",
        [SkillDataParameterType.SkillDuration] = 1.0,
        [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
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
        [SkillDataParameterType.SkillCollisionOffset] = Vector2.new(5, 0),
        [SkillDataParameterType.SkillCollisionDirection] = "LookVector",
        [SkillDataParameterType.SkillCollisionSpeed] = 50,
        --[SkillDataParameterType.SkillCollisionDetailMovementType] = ...,
        [SkillDataParameterType.SkillCollisionDuration] = 100,
        
        [SkillDataParameterType.SkillAnimation] = "RightSlash",
        [SkillDataParameterType.SkillDuration] = 1.0,
        [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
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
        [SkillDataParameterType.SkillCollisionOffset] = Vector2.new(5, 0),
        [SkillDataParameterType.SkillCollisionDirection] = "LookVector",
        [SkillDataParameterType.SkillCollisionSpeed] = 1,
        --[SkillDataParameterType.SkillCollisionDetailMovementType] = ...,
        --[SkillDataParameterType.SkillCollisionDuration] = 0,
        
        [SkillDataParameterType.SkillAnimation] = "LeftSlash",
        [SkillDataParameterType.SkillDuration] = 0.5,
        [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
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
        [SkillDataParameterType.SkillCollisionOffset] = Vector2.new(5, 0),
        [SkillDataParameterType.SkillCollisionDirection] = "LookVector",
        [SkillDataParameterType.SkillCollisionSpeed] = 50,
        --[SkillDataParameterType.SkillCollisionDetailMovementType] = ...,
        [SkillDataParameterType.SkillCollisionDuration] = 100,
        
        [SkillDataParameterType.SkillAnimation] = "MiddleSlash",
        [SkillDataParameterType.SkillDuration] = 1.0,
        [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
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

end


return SkillImpl