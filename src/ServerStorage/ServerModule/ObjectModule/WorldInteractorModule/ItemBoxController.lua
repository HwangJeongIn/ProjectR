-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------

local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local WorldInteractorUtility = ServerModuleFacade.WorldInteractorUtility

local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerConstant = ServerModuleFacade.ServerConstant

local ServerEnum = ServerModuleFacade.ServerEnum
local WorldInteractorType = ServerEnum.WorldInteractorType

local WorldInteractorModule = ServerModuleFacade.WorldInteractorModule
local Debris = game:GetService("Debris")

local ItemBoxController = {}
ItemBoxController.__index = Utility.Inheritable__index
ItemBoxController.__newindex = Utility.Inheritable__newindex
setmetatable(ItemBoxController, Utility:DeepCopy(require(WorldInteractorModule:WaitForChild("WorldInteractorBase"))))


function ItemBoxController:InitializeItemBoxController(gameDataType, itemBoxWorldInteractor)
    if not self:InitializeWorldInteractor(gameDataType, itemBoxWorldInteractor) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end
	
    return true
end

function ItemBoxController:OnDestroying()

    local worldInteractorGameData = self:GetGameData()
    local dropGameData = worldInteractorGameData.DropGameData

    -- 아무것도 드롭하지 않음
    if not dropGameData then
        return true
    end

    local worldInteractor = self:Root()
    local spawnLocation = worldInteractor.Trigger.CFrame + Vector3.new(0, 2, 0)
    local dropTools = dropGameData.ToolGameDataSet
    for _, dropTool in pairs(dropTools) do
        ServerGlobalStorage:CreateToolToWorkspace(dropTool:GetKey(), spawnLocation)
    end

    return true
end

return ItemBoxController