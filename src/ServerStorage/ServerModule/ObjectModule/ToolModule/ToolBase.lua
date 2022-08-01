-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Utility = ServerModuleFacade.Utility
local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage

local GameDataManager = ServerModuleFacade.GameDataManager
local Debug = ServerModuleFacade.Debug


local ToolBase = {}
ToolBase.__index = Utility.Inheritable__index
ToolBase.__newindex = Utility.Inheritable__newindex


-- 함수 정의 ------------------------------------------------------------------------------------------------------

-- Tool에 붙은 데이터들을 플레이어에게 적용하기

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

function ToolBase:InitializeAll(gameDataType, tool)
	
	self:Initialize(gameDataType, tool)
	
	--tool.Equipped:Connect(function() OnEquipped(self) end)
	--tool.Unequipped:Connect(function() OnUnequipped(self) end)
	tool.Equipped:Connect(function() Debug.Print("OnEquipped") end)
	tool.Unequipped:Connect(function() Debug.Print("OnUnequipped") end)

end


-- 반환 코드 ------------------------------------------------------------------------------------------------------

setmetatable(ToolBase, Utility:DeepCopy(require(ServerModuleFacade.ObjectModule:WaitForChild("ObjectBase"))))
return ToolBase
