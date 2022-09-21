local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")

local ServerConstant = require(ServerModule:WaitForChild("ServerConstant"))
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))

local ServerObjectUtilityModule = ServerModule:WaitForChild("ServerObjectUtilityModule")
local ObjectTagUtility = require(ServerObjectUtilityModule:WaitForChild("ObjectTagUtility"))
local ObjectCollisionGroupUtility = require(ServerObjectUtilityModule:WaitForChild("ObjectCollisionGroupUtility"))

local ServerGlobalStorage = require(ServerModule:WaitForChild("ServerGlobalStorage"))


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
local ResourceTemplateModule = ServerModule:WaitForChild("ResourceTemplateModule")

-- 리소스
local Maps = ServerStorage:WaitForChild("Maps")
local Animations = ServerStorage:WaitForChild("Animations")
local Effects = ServerStorage:WaitForChild("Effects")
local Sounds = ServerStorage:WaitForChild("Sounds")

-- 프리팹
local Tools = ServerStorage:WaitForChild("Tools")
local WorldInteractors = ServerStorage:WaitForChild("WorldInteractors")
local Npcs = ServerStorage:WaitForChild("Npcs")


local ServerModuleFacade = {
	ServerModule = ServerModule,
	ServerConstant = ServerConstant,
	ServerEnum = ServerEnum,
	ObjectTagUtility = ObjectTagUtility,
	ObjectCollisionGroupUtility = ObjectCollisionGroupUtility,

	ServerGlobalStorage = ServerGlobalStorage,
	ServerGameDataManager = ServerGameDataManager,
	
	ObjectModule = ObjectModule,
	ToolModule = ToolModule,
	VehicleModule = VehicleModule,
	WorldInteractorModule = WorldInteractorModule,
	SkillModule = SkillModule,
	ResourceTemplateModule = ResourceTemplateModule,

	-- 리소스
	Maps = Maps,
	Animations = Animations,
	Effects = Effects,
	Sounds = Sounds,
	
	-- 프리팹
	Tools = Tools,
	WorldInteractors = WorldInteractors,
	Npcs = Npcs,
}

setmetatable(ServerModuleFacade, CommonModuleFacade)
ServerModuleFacade.__index = ServerModuleFacade.Utility.Inheritable__index

return ServerModuleFacade
