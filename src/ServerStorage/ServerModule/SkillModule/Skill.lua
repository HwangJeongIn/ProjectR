-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------

local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
--local ToolUtility = ServerModuleFacade.ToolUtility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage


local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultAttackPoint = ServerConstant.DefaultAttackPoint
local DefaultSTRFactor = ServerConstant.DefaultSTRFactor

local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType
local StatType = ServerEnum.StatType
local EquipType = ServerEnum.EquipType
local WorldInteractorType = ServerEnum.WorldInteractorType
local ToolType = ServerEnum.ToolType

local ToolModule = ServerModuleFacade.ToolModule
local Debris = game:GetService("Debris")

local Skill = {}
Skill.__index = Utility.Inheritable__index
Skill.__newindex = Utility.Inheritable__newindex
setmetatable(Skill, Utility:DeepCopy(require(ToolModule:WaitForChild("ToolBase"))))

-- 함수 정의 ------------------------------------------------------------------------------------------------------

function Skill:InitializeSkill(gameDataType, SkillTool)
    if not self:InitializeTool(gameDataType, SkillTool) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

	local  gameData = self:GetGameData()
	self.SkillSet = {
		[1] = gameData.Skill1,
		[2] = gameData.Skill2,
		[3] = gameData.Skill3,
	}

    return true
end

-- pure virtual
function Skill:FindTargetsInRange(toolOwner)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return nil
end

function Skill:ApplySkillToTarget(toolOwner, target)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end

function Skill:ApplySkillToTargets(toolOwner, targets)
    for _, target in pairs(targets) do
        if not self:ApplySkillToTarget(toolOwner, target) then
            Debug.Assert(false, "비정상입니다.")
            return false
        end
    end

    return true
end



return Skill
