local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug

local CommonEnum = CommonModuleFacade.CommonEnum
local GameDataType = CommonEnum.GameDataType

local ServerStorage = game:GetService("ServerStorage")
local MapsFolder = ServerStorage:WaitForChild("Maps")

local ServerModule = ServerStorage:WaitForChild("ServerModule")

local ToolUtility = CommonModuleFacade.ToolUtility
local NpcUtility = CommonModuleFacade.NpcUtility

local ServerObjectUtilityModule = ServerModule:WaitForChild("ServerObjectUtilityModule")
local WorldInteractorUtility = require(ServerObjectUtilityModule:WaitForChild("WorldInteractorUtility"))

local ToolsFolder = ServerStorage:WaitForChild("Tools")
local WorldInteractorsFolder = ServerStorage:WaitForChild("WorldInteractors")
local NpcsFolder = ServerStorage:WaitForChild("Npcs")

local MapTemplate = {
	MapTable = {}
}

function MapTemplate:ValidateMapObjects(gameDataType, objectsFolder)
	local targetObjectUtility = nil
	if GameDataType.Tool == gameDataType then
		targetObjectUtility = ToolUtility

	elseif GameDataType.WorldInteractor == gameDataType then
		targetObjectUtility = WorldInteractorUtility

	elseif GameDataType.Npc == gameDataType then
		targetObjectUtility = NpcUtility

	else
		Debug.Assert(false, "비정상입니다. => " .. tostring(gameDataType))
        return false
	end

	if not targetObjectUtility then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local objects = objectsFolder:GetChildren()
	for _, object in objects do
		local objectName = object.Name
		if not targetObjectUtility:GetGameDataKeyByModelName(objectName) then
			Debug.Assert(false, "등록되지 않은 객체입니다. => " .. tostring(gameDataType) .. " : " ..objectName)
			return false
		end
	end

	return true
end

function MapTemplate:InitializeAllMaps()
	local maps = MapsFolder:GetChildren()

	for mapIndex, map in pairs(maps) do 
		self.MapTable[mapIndex] = {}

		local mapName = map.Name

		local mapObjects = Instance.new("Model")
		mapObjects.Name = mapName .. "Objects"
		mapObjects.Parent = MapsFolder

		local mapTools = map:FindFirstChild("Tools")
		local mapWorldInteractors = map:FindFirstChild("WorldInteractors")
		local mapNpcs = map:FindFirstChild("Npcs")

		self.MapTable[mapIndex].GetMap = function() return map end
		if mapTools then
			if not self:ValidateMapObjects(GameDataType.Tool, mapTools) then
				Debug.Assert(false, "ValidateMapObjects에 실패했습니다. => " .. mapName)
				return false
			end
			mapTools.Parent = mapObjects
		end
		self.MapTable[mapIndex].GetTools = function() return mapTools end
		
		if mapWorldInteractors then
			if not self:ValidateMapObjects(GameDataType.WorldInteractor, mapWorldInteractors) then
				Debug.Assert(false, "ValidateMapObjects에 실패했습니다. => " .. mapName)
				return false
			end
			mapWorldInteractors.Parent = mapObjects
		end
		self.MapTable[mapIndex].GetWorldInteractors = function() return mapWorldInteractors end
		
		if mapNpcs then
			if not self:ValidateMapObjects(GameDataType.Npc, mapNpcs) then
				Debug.Assert(false, "ValidateMapObjects에 실패했습니다. => " .. mapName)
				return false
			end
			mapNpcs.Parent = mapObjects
		end
		self.MapTable[mapIndex].GetNpcs = function() return mapNpcs end
	end

	return true
end

function MapTemplate:GetMapTemplate(mapIndex)
	if not self.MapTable[mapIndex] then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return self.MapTable[mapIndex]
end


MapTemplate:InitializeAllMaps()
return MapTemplate
