local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Utility = CommonModuleFacade.Utility
local CommonConstant = CommonModuleFacade.CommonConstant
local CommonEnum = CommonModuleFacade.CommonEnum
local EquipType = CommonEnum.EquipType

--[[
local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))
--]]

local ServerConstant = {
	DefaultAttackPoint = 10,
	DefaultSTRFactor = 1.2,
	IsTestMode = true,

	EquipTypeToBoneMappingTable = {
		[EquipType.Helmet] = {[1] = "Head"},
		[EquipType.Chestplate] = {[1] = "UpperTorso"},
		[EquipType.Leggings] = {[1] = "LeftLowerLeg", [2] = "RightLowerLeg"},
		[EquipType.Boots] = {[1] = "LeftFoot", [2] = "RightFoot"},
	},

	DefaultWeaponSkillGameDataKey = 1,
	DefaultArmorSkillGameDataKey = 100,
}

ServerConstant.__index = Utility.Inheritable__index
ServerConstant.__newindex = Utility.Inheritable__newindex

setmetatable(ServerConstant, CommonConstant)

return ServerConstant
