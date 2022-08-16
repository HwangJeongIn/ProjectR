-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Utility = ServerModuleFacade.Utility
local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage

local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager
local Debug = ServerModuleFacade.Debug

local ObjectModule = ServerModuleFacade.ObjectModule


local WorldInteractorBase = {}
WorldInteractorBase.__index = Utility.Inheritable__index
WorldInteractorBase.__newindex = Utility.Inheritable__newindex
setmetatable(WorldInteractorBase, Utility:DeepCopy(require(ObjectModule:WaitForChild("ObjectBase"))))


function OnDestroying(worldInteractorBase)
	local worldInteractor = worldInteractorBase.Root()
	local worldInteractorData = worldInteractorBase.GetGameData()
end

function WorldInteractorBase:InitializeWorldInteractor(gameDataType, worldInteractor)
	self:InitializeObject(gameDataType, worldInteractor)
	worldInteractor.Destroying:Connect(function() OnDestroying(self) end)
end


--[[
-- Tool에 붙은 데이터들을 플레이어에게 적용하기

function onEquipped(toolBase)

	local tool = toolBase.Root()
	--local temp = getmetatable(toolBase)
	--local temp2 = temp.GetGameDataKey()
	--local temp = ServerGlobalStorage

	-- 캐릭터가 장착중인 상태 -- Character의 Parent는 Workspace이다 주의해야한다.
	-- tool =(parent)> Character
	local character = tool.Parent
	ServerGlobalStorage:AddGameData(character, toolBase.GetGameData())

end


function onUnequipped(toolBase)

	local tool = toolBase.Root()
	local temp = getmetatable(toolBase)

	--Backpack에 존재 
	-- tool =(parent)> Backpack =(parent)> Player > Character
	local character = tool.Parent.Parent.Character
	ServerGlobalStorage:RemoveGameData(character, toolBase.GetGameDataType())

end
--]]

return WorldInteractorBase
