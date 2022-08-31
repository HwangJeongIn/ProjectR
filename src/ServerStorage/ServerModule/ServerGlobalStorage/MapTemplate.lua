local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug

local CommonEnum = CommonModuleFacade.CommonEnum
local GameDataType = CommonEnum.GameDataType
local MapType = CommonEnum.MapType
local MapTypeConverter = MapType.Converter

local ServerStorage = game:GetService("ServerStorage")
local MapsFolder = ServerStorage:WaitForChild("Maps")

local ServerModule = ServerStorage:WaitForChild("ServerModule")

local ToolUtility = CommonModuleFacade.ToolUtility
local NpcUtility = CommonModuleFacade.NpcUtility
local WorldInteractorUtility = CommonModuleFacade.WorldInteractorUtility

local ServerObjectUtilityModule = ServerModule:WaitForChild("ServerObjectUtilityModule")
local ObjectCollisionGroupUtility = require(ServerObjectUtilityModule:WaitForChild("ObjectCollisionGroupUtility"))
--[[
local ToolsFolder = ServerStorage:WaitForChild("Tools")
local WorldInteractorsFolder = ServerStorage:WaitForChild("WorldInteractors")
local NpcsFolder = ServerStorage:WaitForChild("Npcs")
--]]

local MapTemplate = {
	MapTable = {},
    MapTypeToMapTable = {}
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

function MapTemplate:SetWallCollisionRecursively(mapPart)
	local mapPartClassName = mapPart.ClassName
	--Debug.Print(mapPartClassName)
	
	if "UnionOperation" == mapPartClassName or "Part" == mapPartClassName then
		ObjectCollisionGroupUtility:SetWallCollisionGroup(mapPart)
	end

	local childParts = mapPart:GetChildren()
	for _, childPart in pairs(childParts) do
		self:SetWallCollisionRecursively(childPart)
	end
end

function MapTemplate:InitializeAllMaps()
	local maps = MapsFolder:GetChildren()

	for mapIndex, map in pairs(maps) do 
		self.MapTable[mapIndex] = {}

		local mapName = map.Name
        local currentMapType = MapType[mapName]
        if not currentMapType then
            Debug.Assert(false, "맵타입에 등록되지 않은 이름입니다. => " .. mapName)
            return false
        end

		local mapObjects = Instance.new("Model")
		mapObjects.Name = mapName .. "_Objects"
		mapObjects.Parent = MapsFolder

		local mapTools = map:FindFirstChild("Tools")
		local mapWorldInteractors = map:FindFirstChild("WorldInteractors")
		local mapNpcs = map:FindFirstChild("Npcs")

		self.MapTable[mapIndex].GetMap = function() return map end
		self.MapTable[mapIndex].GetMapType = function() return currentMapType end

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
        self.MapTypeToMapTable[currentMapType] = self.MapTable[mapIndex]

		self:SetWallCollisionRecursively(map)
	end

	return true
end

function MapTemplate:GetMapTemplateByMapType(mapType)
    if not mapType then
        Debug.Assert(false, "비정상입니다.")
		return nil
    end

    if not self.MapTypeToMapTable[mapType] then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
    
    return self.MapTypeToMapTable[mapType]
end

function MapTemplate:GetMapTemplateByIndex(mapIndex)
    if not mapIndex then
        Debug.Assert(false, "비정상입니다.")
		return nil
    end

	if not self.MapTable[mapIndex] then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return self.MapTable[mapIndex]
end


MapTemplate:InitializeAllMaps()
return MapTemplate
