local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")

-- 서버 상수
local ServerConstant = require(ServerModule:WaitForChild("ServerConstant"))
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))

-- 서버 전역변수
local ServerGlobalStorage = require(ServerModule:WaitForChild("ServerGlobalStorage"))

-- 게임 데이터 매니저
local ServerGameDataModule = ServerModule:WaitForChild("ServerGameDataModule")
local ServerGameDataManager = require(ServerGameDataModule:WaitForChild("ServerGameDataManager"))

-- 오브젝트 모듈 
-- require 호출을 하지 않기 때문에 ObjectModule 내부에 있는 스크립트에서 ServerModuleFacade를 사용할 수 있다.
-- System 종류는 ServerGlobalStorage에서도 사용해야할 것 같으니 함수를 통해 ServerGlobalStorage 내부 변수로 초기화하면 된다.
local ObjectModule = ServerModule:WaitForChild("ObjectModule")
local ToolModule = ObjectModule:WaitForChild("ToolModule")
local VehicleModule = ObjectModule:WaitForChild("VehicleModule")
local WorldInteractorModule = ObjectModule:WaitForChild("WorldInteractorModule")

local SkillModule = ServerModule:WaitForChild("SkillModule")


local ServerModuleFacade = {
	ServerModule = ServerModule,
	ServerConstant = ServerConstant,
	ServerEnum = ServerEnum,
	ServerGlobalStorage = ServerGlobalStorage,
	ServerGameDataManager = ServerGameDataManager,
	
	ObjectModule = ObjectModule,
	ToolModule = ToolModule,
	VehicleModule = VehicleModule,
	WorldInteractorModule = WorldInteractorModule,
	SkillModule = SkillModule
}

setmetatable(ServerModuleFacade, CommonModuleFacade)
ServerModuleFacade.__index = ServerModuleFacade.Utility.Inheritable__index

return ServerModuleFacade
