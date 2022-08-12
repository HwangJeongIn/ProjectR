-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Utility = ServerModuleFacade.Utility
local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType
local EquipType = ServerEnum.EquipType

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local GameDataManager = ServerModuleFacade.GameDataManager
local Debug = ServerModuleFacade.Debug

local ObjectModule = ServerModuleFacade.ObjectModule

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
	self.ToolType = toolGameData.ToolType
	return true
end

function ToolBase:GetToolOwnerIfPlayer(equipType)
	--[[
	local targetCharacter = nil
	local tool = self:Root()
	if EquipType.Weapon == equipType then
		targetCharacter = tool.Parent
	elseif EquipType.Armor == equipType then
		targetCharacter = tool.Parent.Parent
	end
	--]]

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

return ToolBase
