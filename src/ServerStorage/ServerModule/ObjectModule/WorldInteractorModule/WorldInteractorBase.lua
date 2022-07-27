-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Utility = ServerModuleFacade.Utility
local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage

local GameDataManager = ServerModuleFacade.GameDataManager
local Debug = ServerModuleFacade.Debug


local WorldInteractorBase = {}
WorldInteractorBase.__index = Utility.Inheritable__index
WorldInteractorBase.__newindex = Utility.Inheritable__newindex


-- 함수 정의 ------------------------------------------------------------------------------------------------------

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

function onDestroying(worldInteractorBase)
	
	local worldInteractor = worldInteractorBase.Root()
	local worldInteractorData = worldInteractorBase.GetGameData()
	
end

function WorldInteractorBase:InitializeAll(gameDataType, worldInteractor)
	self:Initialize(gameDataType, worldInteractor)
	worldInteractor.Destroying:Connect(function() onDestroying(self) end)
end


-- 반환 코드 ------------------------------------------------------------------------------------------------------

setmetatable(WorldInteractorBase, Utility.DeepCopy(require(ServerModuleFacade.ObjectModule:WaitForChild("ObjectBase"))))
return WorldInteractorBase
