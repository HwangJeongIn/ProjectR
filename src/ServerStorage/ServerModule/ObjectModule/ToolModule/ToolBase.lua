-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Utility = ServerModuleFacade.Utility
local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType

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
	
	--tool.Equipped:Connect(function() OnEquipped(self) end)
	--tool.Unequipped:Connect(function() OnUnequipped(self) end)
	--tool.Equipped:Connect(function() Debug.Print("OnEquipped : " .. tostring(tool)) end)
	--tool.Unequipped:Connect(function() Debug.Print("OnUnequipped : ".. tostring(tool)) end)
	return true
end

--[[
function OnEquipped(toolBase)

	local tool = toolBase.Root()
	--local temp = getmetatable(toolBase)
	--local temp2 = temp.GetGameDataKey()
	--local temp = ServerGlobalStorage
	
	-- 캐릭터가 장착중인 상태 -- Character의 Parent는 Workspace이다 주의해야한다.
	-- tool =(parent)> Character
	
	local character = tool.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	ServerGlobalStorage:CheckAndEquipIfWeapon(player.UserId, tool)
end


function OnUnequipped(toolBase)
	
	local tool = toolBase.Root()
	--local temp = getmetatable(toolBase)
	
	--Backpack에 존재 
	-- tool =(parent)> Backpack =(parent)> Player > Character
	local player = tool.Parent.Parent
	ServerGlobalStorage:CheckAndEquipIfWeapon(player.UserId, tool)
end
--]]

-- 반환 코드 ------------------------------------------------------------------------------------------------------

return ToolBase
