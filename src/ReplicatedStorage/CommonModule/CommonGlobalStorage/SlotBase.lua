local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local ToolType = CommonEnum.ToolType

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

local SlotBase = {}

function SlotBase:GetToolGameData(tool)
	
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	-- FindFirstChild를 쓰면 가끔 못찾는 경우가 있다. 확인해봐야한다.
	local key = tool:WaitForChild("Key")
	if not key then
		Debug.Assert(false, "Key 객체가 존재하지 않습니다. => " .. tostring(tool))
		return nil
	end

	key = key.Value
	local toolGameData = CommonGameDataManager[GameDataType.Tool]:Get(key)
	if not toolGameData then
		Debug.Assert(false, "ToolGameData가 존재하지 않습니다. [key] => " .. tostring(key))
		return nil
	end

	return toolGameData
end

function SlotBase:IsValidTool(tool)
	return (self:GetToolGameData(tool) ~= nil)
end

function SlotBase:CheckEquipableToolGameData(toolGameData)
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

function SlotBase:CheckEquipableTool(tool)
    local toolGameData = self:GetToolGameData(tool)
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

function SlotBase:CheckWeaponToolGameData(toolGameData)
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

function SlotBase:CheckWeaponTool(tool)
    local toolGameData = self:GetToolGameData(tool)
    if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

    if not self:CheckWeaponToolGameData(toolGameData) then
        Debug.Assert(false, "비정상입니다.")
		return false
    end

    return true
end



return SlotBase
