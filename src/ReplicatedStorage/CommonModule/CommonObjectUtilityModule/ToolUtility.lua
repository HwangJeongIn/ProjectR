local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonObjectUtilityModule = CommonModule:WaitForChild("CommonObjectUtilityModule")

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local MaxQuickSlotCount = CommonConstant.MaxQuickSlotCount
local MaxSkillCount = CommonConstant.MaxSkillCount

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local ToolType = CommonEnum.ToolType


local ToolUtility = Utility:DeepCopy(require(CommonObjectUtilityModule:WaitForChild("ObjectUtilityBase")))

function ToolUtility:Initialize()
	local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
	local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

	if not self:InitializeRaw(CommonGameDataManager, GameDataType.Tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	self.DefaultToolImage = "http://www.roblox.com/asset/?id=10490139376"
	self.EmptyToolImage = ""
	self.DefaultSkillImage = "http://www.roblox.com/asset/?id=10489717222"
	self.EmptySkillImage = "http://www.roblox.com/asset/?id=10489717222"
	self.DefaultSlotImage = "http://www.roblox.com/asset/?id=10489757489"
	self.DefaultCircularSlotImage = "http://www.roblox.com/asset/?id=10489755989"

	self.QuickSlotIndexToKeyCodeTable = {
		[1] = Enum.KeyCode.One,
		[2] = Enum.KeyCode.Two,
		[3] = Enum.KeyCode.Three,
		[4] = Enum.KeyCode.Four,
		[5] = Enum.KeyCode.Five
	}
	Debug.Assert(MaxQuickSlotCount == #self.QuickSlotIndexToKeyCodeTable, "여기도 갱신해야합니다.")

	self.SkillSlotIndexToKeyCodeTable = {
		[1] = Enum.KeyCode.Q,
		[2] = Enum.KeyCode.E,
		[3] = Enum.KeyCode.R,
		[4] = Enum.KeyCode.T,
	}
	Debug.Assert(MaxSkillCount == #self.SkillSlotIndexToKeyCodeTable, "여기도 갱신해야합니다.")

	return true
end

function ToolUtility:IsValidTool(tool)
	return (self:GetGameData(tool) ~= nil)
end

function ToolUtility:CheckEquipableToolGameData(toolGameData)
	if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

    local targetToolType = toolGameData.ToolType
    if not targetToolType == ToolType.Armor and not targetToolType == ToolType.Weapon then
		return false
    end

    return true
end

function ToolUtility:CheckEquipableTool(tool)
    local toolGameData = self:GetGameData(tool)
    if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

    if not self:CheckEquipableToolGameData(toolGameData) then
        Debug.Assert(false, "비정상입니다.")
		return false
    end

    return true
end

function ToolUtility:GetEquipType(tool)
    local toolGameData = self:GetGameData(tool)
    if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

    return toolGameData.EquipType
end

function ToolUtility:CheckWeaponToolGameData(toolGameData)
    if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

    local targetToolType = toolGameData.ToolType
    if not targetToolType == ToolType.Weapon then
		return false
    end

    return true
end

function ToolUtility:CheckWeaponTool(tool)
    local toolGameData = self:GetGameData(tool)
    if not self:CheckWeaponToolGameData(toolGameData) then
        Debug.Assert(false, "비정상입니다.")
		return false
    end

    return true
end

ToolUtility:Initialize()
return ToolUtility
