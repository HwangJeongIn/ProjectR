-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility

local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultWeaponSkillGameDataKey = ServerConstant.DefaultWeaponSkillGameDataKey
--local DefaultArmorSkillGameDataKey = ServerConstant.DefaultArmorSkillGameDataKey


local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType
local EquipType = ServerEnum.EquipType
local WorldInteractorType = ServerEnum.WorldInteractorType
local SkillImplType = ServerEnum.SkillImplType
local SkillImplTypeConverter = SkillImplType.Converter

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager
local Debug = ServerModuleFacade.Debug

local ObjectModule = ServerModuleFacade.ObjectModule

local SkillCollisionSizeString = "SkillCollisionSize"
local SkillCollisionOffsetString = "SkillCollisionOffset"


local SkillTemplate = { SkillTemplateTable = {} }


function SkillTemplate:GetSkillTemplateByKey(skillGameDataKey)
    if not self.SkillTemplateTable[skillGameDataKey] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.SkillTemplateTable[skillGameDataKey]
end

function SkillTemplate:RegisterSkillCollisionParameter(skillName, skillCollisionSize, skillCollisionOffset)
    if not skillName or not skillCollisionSize or not skillCollisionOffset then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local sizeString = skillName .. "_" .. SkillCollisionSizeString
    local offsetString = skillName .. "_" .. SkillCollisionOffsetString

    if self[sizeString] then
        Debug.Assert(false, sizeString .. "를 두번 등록하려 합니다.")
        return false
    end
    self[sizeString] = skillCollisionSize

    if self[offsetString] then
        Debug.Assert(false, offsetString .. "를 두번 등록하려 합니다.")
        return false
    end
    self[offsetString] = skillCollisionOffset -- forward / right
    
    return true
end

function SkillTemplate:RegisterSkillImpl(skillName, skillImplType, inputFunction)
    if not skillName or not inputFunction then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if "function" ~= type(inputFunction) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local skillImplString = SkillImplTypeConverter[skillImplType]
    if not skillImplString then
        Debug.Assert(false, "비정상입니다. => " .. skillName)
        return false
    end

    local finalName = skillName .. "_" .. skillImplString
    
    if self[finalName] then
        Debug.Assert(false, finalName .. "를 두번 등록하려 합니다.")
        return false
    end

    self[finalName] = inputFunction
    return true
end

function SkillTemplate:InitializeAllTemplates()

    local defaultWeaponSkillGameData = ServerGameDataManager[GameDataType.Skill]:Get(DefaultWeaponSkillGameDataKey)
    Debug.Assert(defaultWeaponSkillGameData, "DefaultWeaponSkillGameDataKey에 해당하는 데이터가 없습니다.")
    self.GetDefaultWeaponSkillGameData = function() return defaultWeaponSkillGameData  end


    local allData = ServerGameDataManager[GameDataType.Skill]:GetAllData()
    for skillGameDataKey, skillGameData in pairs(allData) do
        self.SkillTemplateTable[skillGameDataKey] = {}
        local skillName = skillGameData.Name

        -- 파라미터에 따라서 자동 등록
        local sizeString = skillName .. "_" .. SkillCollisionSizeString
        local skillCollisionSize = self[sizeString]
        Debug.Assert(skillCollisionSize, sizeString .. "가 없습니다.")

        local offsetString = skillName .. "_" .. SkillCollisionOffsetString
        local skillCollisionOffset = self[offsetString]
        Debug.Assert(skillCollisionOffset, offsetString .. "가 없습니다.")

        self:RegisterSkillImpl(skillName,
            SkillImplType.GetSkillCollisionParameter,
            function(skillController, toolOwnerPlayerCFrame)
                local skillCollisionParameter = {}

                local finalOffsetVector = toolOwnerPlayerCFrame.LookVector * skillCollisionOffset.X 
                + toolOwnerPlayerCFrame.RightVector * skillCollisionOffset.Y
                skillCollisionParameter.Size = skillCollisionSize
                skillCollisionParameter.CFrame = toolOwnerPlayerCFrame + finalOffsetVector
                return skillCollisionParameter
            end)

        for skillImplIndex = 1, (SkillImplType.Count - 1) do
            local skillImplString = SkillImplTypeConverter[skillImplIndex]
            local skillImplFunctionName = skillName .. "_" .. skillImplString

            if not self[skillImplFunctionName] then
                Debug.Assert(false, skillImplFunctionName .. "가 정의되어 있지 않습니다.")
                return false
            end

            self.SkillTemplateTable[skillGameDataKey][skillImplString] = self[skillImplFunctionName]
        end
    end
    return true
end


--1, Name = "BaseAttack"
SkillTemplate:RegisterSkillCollisionParameter(
    "BaseAttack",
    Vector3.new(3, 2, 2),
    Vector2.new(5, 0)
)

SkillTemplate:RegisterSkillImpl(
    "BaseAttack",
    SkillImplType.UseSkill,
    function(skillController, toolOwnerPlayer)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)

SkillTemplate:RegisterSkillImpl(
    "BaseAttack",
    SkillImplType.FindTargetsInRange,
    function(skillController, toolOwnerPlayer, filteredTargets)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return nil
    end
)

SkillTemplate:RegisterSkillImpl(
    "BaseAttack",
    SkillImplType.ApplySkillToTarget,
    function(skillController, toolOwnerPlayer, target)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)


--2, Name = "WhirlwindSlash"
SkillTemplate:RegisterSkillCollisionParameter(
    "WhirlwindSlash",
    Vector3.new(3, 2, 2),
    Vector2.new(5, 0)
)

SkillTemplate:RegisterSkillImpl(
    "WhirlwindSlash",
    SkillImplType.UseSkill,
    function(skillController, toolOwnerPlayer)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)

SkillTemplate:RegisterSkillImpl(
    "WhirlwindSlash",
    SkillImplType.FindTargetsInRange,
    function(skillController, toolOwnerPlayer, filteredTargets)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return nil
    end
)

SkillTemplate:RegisterSkillImpl(
    "WhirlwindSlash",
    SkillImplType.ApplySkillToTarget,
    function(skillController, toolOwnerPlayer, target)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)


--3, Name = "TempestSlash"
SkillTemplate:RegisterSkillCollisionParameter(
    "TempestSlash",
    Vector3.new(3, 2, 2),
    Vector2.new(5, 0)
)

SkillTemplate:RegisterSkillImpl(
    "TempestSlash",
    SkillImplType.UseSkill,
    function(skillController, toolOwnerPlayer)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)

SkillTemplate:RegisterSkillImpl(
    "TempestSlash",
    SkillImplType.FindTargetsInRange,
    function(skillController, toolOwnerPlayer, filteredTargets)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return nil
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
SkillTemplate:RegisterSkillCollisionParameter(
    "PowerStrike",
    Vector3.new(3, 2, 2),
    Vector2.new(5, 0)
)

SkillTemplate:RegisterSkillImpl(
    "PowerStrike",
    SkillImplType.UseSkill,
    function(skillController, toolOwnerPlayer)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)

SkillTemplate:RegisterSkillImpl(
    "PowerStrike",
    SkillImplType.FindTargetsInRange,
    function(skillController, toolOwnerPlayer, filteredTargets)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return nil
    end
)

SkillTemplate:RegisterSkillImpl(
    "PowerStrike",
    SkillImplType.ApplySkillToTarget,
    function(skillController, toolOwnerPlayer, target)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)


--5, Name = "StormBlade"
SkillTemplate:RegisterSkillCollisionParameter(
    "StormBlade",
    Vector3.new(3, 2, 2),
    Vector2.new(5, 0)
)

SkillTemplate:RegisterSkillImpl(
    "StormBlade",
    SkillImplType.UseSkill,
    function(skillController, toolOwnerPlayer)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)

SkillTemplate:RegisterSkillImpl(
    "StormBlade",
    SkillImplType.FindTargetsInRange,
    function(skillController, toolOwnerPlayer, filteredTargets)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return nil
    end
)

SkillTemplate:RegisterSkillImpl(
    "StormBlade",
    SkillImplType.ApplySkillToTarget,
    function(skillController, toolOwnerPlayer, target)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)


SkillTemplate:InitializeAllTemplates()
return SkillTemplate