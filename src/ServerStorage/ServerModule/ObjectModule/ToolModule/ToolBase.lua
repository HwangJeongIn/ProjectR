-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility

local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType
local EquipType = ServerEnum.EquipType
local WorldInteractorType = ServerEnum.WorldInteractorType

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local GameDataManager = ServerModuleFacade.GameDataManager
local Debug = ServerModuleFacade.Debug

local ObjectModule = ServerModuleFacade.ObjectModule
local SkillModule = ServerModuleFacade.SkillModule
local SkillController = require(SkillModule:WaitForChild("SkillController"))

local ToolBase = {}
ToolBase.__index = Utility.Inheritable__index
ToolBase.__newindex = Utility.Inheritable__newindex
setmetatable(ToolBase, Utility:DeepCopy(require(ObjectModule:WaitForChild("ObjectBase"))))

function ToolBase:InitializeTool(gameDataType, tool)
	if not self:InitializeObject(gameDataType, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	local toolGameData = self:GetGameData()

	self.SkillCount = toolGameData.SkillCount
	self.SkillControllers = {}
	for skillIndex = 1, self.SkillCount do
		local skillGameData = toolGameData.SkillGameDataSet[skillIndex]
		local skillController = Utility:DeepCopy(SkillController)
		if not skillController:InitializeTool(tool, skillGameData) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end

		self.SkillControllers[skillIndex] = skillController
	end

	self.ToolOwnerPlayer = nil

	return true
end

function ToolBase:SetToolOwnerPlayer(toolOwnerPlayer)
	self.ToolOwnerPlayer = toolOwnerPlayer
	for _, skillController in pairs(self.SkillControllers) do
		skillController:SetToolOnwerPlayer(toolOwnerPlayer)
	end
end

function ToolBase:ActivateSkill(player, skillIndex)
	if self.SkillCount < skillIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local targetSkillController = self.SkillControllers[skillIndex]
	Debug.Assert(targetSkillController, "코드 버그")
	if not targetSkillController:Activate(player) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function ToolBase:GetToolOwnerIfPlayer(equipType)
	local tool = self:Root()
	local targetCharacter = tool.Parent
	if not targetCharacter then
		return nil
	end

	if not game.Players:GetPlayerFromCharacter(targetCharacter) then
		return nil
	end

	return targetCharacter
end

function ToolBase:IsWorldInteractor(object)
	local objectTag = ObjectTagUtility:GetTag(object)
	if not objectTag then
		return false
	end

	return (nil ~= WorldInteractorType[objectTag])
end

function ToolBase:IsPlayerCharacter(object)
	return (nil ~= game.Players:GetPlayerFromCharacter(object))
end

return ToolBase
