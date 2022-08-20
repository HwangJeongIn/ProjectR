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


--[[
local ToolsFolder = ServerStorage:WaitForChild("Tools")
local WorldInteractorsFolder = ServerStorage:WaitForChild("WorldInteractors")
local NpcsFolder = ServerStorage:WaitForChild("Npcs")
--]]


--[[
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))
local ServerConstant = require(ServerModule:WaitForChild("ServerConstant"))

local MaxPickupDistance = ServerConstant.MaxPickupDistance
local MaxDropDistance = ServerConstant.MaxDropDistance
local MaxSkillCount = ServerConstant.MaxSkillCount

local EquipTypeToBoneMappingTable = ServerConstant.EquipTypeToBoneMappingTable

local GameDataType = ServerEnum.GameDataType
local StatusType = ServerEnum.StatusType
local ToolType = ServerEnum.ToolType
local EquipType = ServerEnum.EquipType
--]]

local MapTemplate = require(script.Parent:WaitForChild("MapTemplate"))


local MapController = {
	CurrentMap = {
		Map = nil,
		Tools = nil,
		WorldInteractors = nil,
		Npcs = nil
	}
}

function MapController:GetCurrentMap()
	return self.CurrentMap.Map
end

function MapController:GetCurrentMapTools()
	if not self.CurrentMap.Map then
		return nil
	end

	return self.CurrentMap.Tools
end

function MapController:GetCurrentMapWorldInteractors()
	if not self.CurrentMap.Map then
		return nil
	end

	return self.CurrentMap.WorldInteractors
end

function MapController:GetCurrentMapNpcs()
	if not self.CurrentMap.Map then
		return nil
	end

	return self.CurrentMap.Npcs
end

function MapController:SetCurrentMapByMapTemplate(mapTemplate)
	if not mapTemplate then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local map = mapTemplate:GetMap()
	local mapTools = mapTemplate.GetTools()
	local mapWorldInteractors = mapTemplate:GetWorldInteractors()
	local mapNpcs = mapTemplate:GetNpcs()

	self.CurrentMap.Map = map:Clone()
	if mapTools then
		self.CurrentMap.Tools = mapTools:Clone()
		self.CurrentMap.Tools.Parent = self.CurrentMap.Map
	end

	if mapWorldInteractors then
		self.CurrentMap.WorldInteractors = mapWorldInteractors:Clone()
		self.CurrentMap.WorldInteractors.Parent = self.CurrentMap.Map
	end

	if mapNpcs then
		self.CurrentMap.Npcs = mapNpcs:Clone()
		self.CurrentMap.Npcs.Parent = self.CurrentMap.Map
	end

	return true
end

function MapController:DivideWithoutRemainder(value, divisor)
	return (value - (value % divisor)) / divisor
end

--[[
function MapController:TestSpawnPoints(spawnPoints, centerPosition, mapBase)
	-- 테스트
	print("Center : ".. tostring(centerPosition))
	for i, pos in pairs (spawnPoints) do
		local clonedobject = mapBase.Parent:FindFirstChild("Cactus"):Clone()
		clonedobject.Parent = workspace

		clonedobject:SetPrimaryPartCFrame(CFrame.lookAt(Vector3.new(pos.X, pos.Y + 5.0, pos.Z), centerPosition))
		--clonedobject:MoveTo(pos)
		-- SetPrimaryPartCFrame ( CFrame cframe )
		print(tostring(i).. " : ".. tostring(pos))
	end
end
--]]

function MapController:CalcSpawnPoints(playerCount, mapBase)
	--playerCount = 4
	local splitCount = 1

	local splitFactor = MapController:DivideWithoutRemainder(playerCount, 4);
	if playerCount % 4 ~= 0 then
		splitFactor += 1
	end

	splitCount += 2 * splitFactor
	local sidePerPlayerCount = MapController:DivideWithoutRemainder(splitCount, 2);

	local centerPosition = mapBase.Position
	local xLengthPerSector = mapBase.Size.X / splitCount
	local zLengthPerSector  = mapBase.Size.Z / splitCount

	local rv = {}

	local currentPosition = centerPosition - Vector3.new(xLengthPerSector * sidePerPlayerCount, 0, zLengthPerSector * sidePerPlayerCount)
	currentPosition = currentPosition + Vector3.new(0, 0, zLengthPerSector)
	for  i = 1, sidePerPlayerCount, 1 do
		table.insert(rv, currentPosition)
		table.insert(rv, Vector3.new(currentPosition.X + (splitCount -1) * xLengthPerSector, currentPosition.Y, currentPosition.Z))

		currentPosition = currentPosition + Vector3.new(0, 0, zLengthPerSector * 2)
	end

	currentPosition = centerPosition - Vector3.new(xLengthPerSector * sidePerPlayerCount, 0, zLengthPerSector * sidePerPlayerCount)
	currentPosition = currentPosition + Vector3.new(xLengthPerSector, 0, 0)
	for  i = 1, sidePerPlayerCount, 1 do
		table.insert(rv, currentPosition)
		table.insert(rv, Vector3.new(currentPosition.X, currentPosition.Y, currentPosition.Z + ((splitCount -1) * xLengthPerSector)))

		currentPosition = currentPosition + Vector3.new(xLengthPerSector * 2, 0, 0)
	end

	return rv
end

function MapController:TeleportPlayerToSpawnPoint(character, spawnPoint, mapCenterPosition)
	local rayLength = 100
	local rayDirection = Vector3.new(0, -rayLength, 0)

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")


	local rayOrigin = Vector3.new(spawnPoint.X, spawnPoint.Y + rayLength, spawnPoint.Z)

	local raycastParams = RaycastParams.new()
	--raycastParams.FilterDescendantsInstances = {character.Parent}
	--raycastParams.FilterType = CommonEnum.RaycastFilterType.Blacklist
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	local finalPosition = rayOrigin
	if raycastResult then
		finalPosition = raycastResult.Position
	end

	humanoidRootPart.CFrame = CFrame.lookAt(finalPosition, mapCenterPosition)
end

function MapController:TeleportPlayerToRespawnLocation(player)
	if not player then
		Debug.Assert(false, "플레이어가 없습니다.")
		return
	end
	
	local character = player.Character
	if not character then
		Debug.Assert(false, "플레이어의 캐릭터가 없습니다.")
		return
	end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	humanoidRootPart.CFrame = player.RespawnLocation.CFrame
end

function MapController:SelectDesertMapTemp()
	local desertMap = MapsFolder:FindFirstChild("DesertMap")
	local maps = MapsFolder:GetChildren()
	local desertMapIndex = nil
	for mapIndex, map in maps do
		if "DesertMap" == map.Name then
			desertMapIndex = mapIndex
			break
		end
	end

	local targetMapTemplate = self:GetMapTemplate(desertMapIndex)
	Debug.Assert(targetMapTemplate, "비정상입니다.")
	if not self:SetCurrentMapByMapTemplate(targetMapTemplate) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function MapController:SelectRandomMap()
	local mapCandidates = MapsFolder:GetChildren()
	local mapCount = #mapCandidates
	if mapCount == 0 then
		Debug.Assert(false, "맵이 없습니다.")
		return nil
	end
	
	local selectedMapIndex = mapCandidates[math.random(1, #mapCandidates)]

	local targetMapTemplate = self:GetMapTemplate(selectedMapIndex)
	Debug.Assert(targetMapTemplate, "비정상입니다.")
	if not self:SetCurrentMapByMapTemplate(targetMapTemplate) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function MapController:EnterMap(playersInGame)
	if not playersInGame then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local map = self:GetCurrentMap()

	local playerCount = #playersInGame
	local mapBase = map:WaitForChild("Base")
	local mapCenterPosition = mapBase.Position
	local spawnPointList = self:CalcSpawnPoints(playerCount, mapBase)
	for i, player in pairs (playersInGame) do
		if not player then
			Debug.Log("이미 나간 플레이어입니다. => " .. player.Name)
			table.remove(playersInGame, i)
			continue
		end

		local character = player.Character
		if not character then
			Debug.Assert(false, "플레이어의 캐릭터가 없습니다. 게임에서 제외됩니다. => " .. player.Name)
			table.remove(playersInGame, i)
			continue
		end

		-- 스폰 포인트로 텔레포트
		self:TeleportPlayerToSpawnPoint(character, spawnPointList[i], mapCenterPosition)
	end

	return true
end

MapController:InitializeAllMaps()
return MapController
