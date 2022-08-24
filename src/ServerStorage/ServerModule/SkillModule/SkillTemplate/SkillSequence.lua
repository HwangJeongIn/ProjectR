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
--[[
local GameDataType = ServerEnum.GameDataType
local CollisionGroupType = ServerEnum.CollisionGroupType

local SkillDataType = ServerEnum.SkillDataType
local EquipType = ServerEnum.EquipType
local WorldInteractorType = ServerEnum.WorldInteractorType
local SkillSequenceType = ServerEnum.SkillSequenceType
local SkillSequenceTypeConverter = SkillSequenceType.Converter
local SkillDataParameterType = ServerEnum.SkillDataParameterType
local SkillDataParameterTypeConverter = SkillDataParameterType.Converter

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager

local SkillModule = ServerModuleFacade.SkillModule
local DamageCalculator = require(SkillModule:WaitForChild("DamageCalculator"))
--]]


local SkillCollisionFireTimeRate

local SkillCollisionSequence = {}

function SkillCollisionSequence:aaa()

end


local SkillSequence = {}

function SkillSequence:Initialize(skillName)
    
end

function SkillSequence:AddAnimationTrack(animationName)
    -- 애니메이션을 찾는다.
    local targetAnimation
    return targetAnimation
end

function SkillSequence:AddSkillCollision(parentAnimationName, skillCollisionFireTimeRate)

end


return SkillSequence