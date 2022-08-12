local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local ToolType = CommonEnum.ToolType

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

local ToolUtility = {
	DefaultToolImage = "http://www.roblox.com/asset/?id=10490139376",
	EmptyToolImage = "",
	DefaultSkillImage = "http://www.roblox.com/asset/?id=10489717222",
	EmptySkillImage = "http://www.roblox.com/asset/?id=10489717222",
	DefaultSlotImage = "http://www.roblox.com/asset/?id=10489757489",
	DefaultCircularSlotImage = "http://www.roblox.com/asset/?id=10489755989",

	QuickSlotIndexToKeyCodeTable = {
		[1] = Enum.KeyCode.One,
		[2] = Enum.KeyCode.Two,
		[3] = Enum.KeyCode.Three,
		[4] = Enum.KeyCode.Four,
		[5] = Enum.KeyCode.Five
	}
}

function ToolUtility:GetGameDataKeyByToolModelName(toolModelName)

end

function ToolUtility:GetGameDataByToolModelName(toolModelName)
	if not toolModelName then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local toolGameData = CommonGameDataManager[GameDataType.Tool]:GetGameDataByModelName(toolModelName)
	if not toolGameData then
		Debug.Assert(false, "ToolGameData가 존재하지 않습니다. [ModelName] => " .. toolModelName)
		return nil
	end

	return toolGameData
end

function ToolUtility:GetGameDataByKey(key)
	local toolGameData = CommonGameDataManager[GameDataType.Tool]:Get(key)
	if not toolGameData then
		Debug.Assert(false, "ToolGameData가 존재하지 않습니다. [key] => " .. tostring(key))
		return nil
	end

	return toolGameData
end

function ToolUtility:GetGameData(tool)
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local toolGameData = self:GetGameDataByToolModelName(tool.Name)
	if not toolGameData then
		Debug.Assert(false, "모델과 일치하는 데이터가 Mapping Table을 확인해봐야 합니다. => " .. tool.Name)
		return nil
	end

	return toolGameData
	-- FindFirstChild를 쓰면 가끔 못찾는 경우가 있다. 확인해봐야한다.
	--[[
	local key = tool:WaitForChild("Key")
	if not key then
		Debug.Assert(false, "Key 객체가 존재하지 않습니다. => " .. tostring(tool))
		return nil
	end
	--]]

	--[[
	local key = tool.Key.Value
	local toolGameData = self:GetGameDataByKey(key)
	if not toolGameData then
		Debug.Assert(false, "ToolGameData가 존재하지 않습니다. [key] => " .. tostring(key))
		return nil
	end

	return toolGameData
	--]]
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



return ToolUtility
