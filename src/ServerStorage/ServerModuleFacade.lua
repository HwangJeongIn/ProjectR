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

-- 종속성 때문에 주석처리
-- 오브젝트 모듈
--local ObjectModule = ServerModule:WaitForChild("ObjectModule")
--local ToolModule = ObjectModule:WaitForChild("ToolModule")
--local VehicleModule = ObjectModule:WaitForChild("VehicleModule")
--local WorldInteractorModule = ObjectModule:WaitForChild("WorldInteractorModule")


local ServerModuleFacade = {
	ServerModule = ServerModule,
	ServerConstant = ServerConstant,
	ServerEnum = ServerEnum,
	ServerGlobalStorage = ServerGlobalStorage,
	ServerGameDataManager = ServerGameDataManager,
	
	-- 종속성 때문에 주석처리
	--ObjectModule = ObjectModule,
	--ToolModule = ToolModule,
	--VehicleModule = VehicleModule,
	--WorldInteractorModule = WorldInteractorModule
}

setmetatable(ServerModuleFacade, CommonModuleFacade)
ServerModuleFacade.__index = ServerModuleFacade.Utility.Inheritable__index

return ServerModuleFacade
