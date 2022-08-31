local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug

local CommonEnum = CommonModuleFacade.CommonEnum
local GameDataType = CommonEnum.GameDataType

local ServerStorage = game:GetService("ServerStorage")
local MapsFolder = ServerStorage:WaitForChild("Maps")


--[[
local ToolUtility = CommonModuleFacade.ToolUtility
local NpcUtility = CommonModuleFacade.NpcUtility
local WorldInteractorUtility = CommonModuleFacade.WorldInteractorUtility
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


function MapController:Initialize(serverGlobalStorage)
	self.ServerGlobalStorage = serverGlobalStorage
end

function MapController:GetCurrentMap()
	return self.CurrentMap.Map
end


function MapController:AddObjectToCurrentMap(gameDataType, object)
	if not self.CurrentMap.Map then
		Debug.Assert(false, "CurrentMap이 없습니다.")
		return false
	end

	if GameDataType.Tool == gameDataType then
		object.Parent = self.CurrentMap.Tools
	elseif GameDataType.WorldInteractor == gameDataType then
		object.Parent = self.CurrentMap.WorldInteractors
	elseif GameDataType.Npc == gameDataType then
		object.Parent = self.CurrentMap.Npcs
	else
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function MapController:GetCurrentMapObjects(gameDataType)
	if not self.CurrentMap.Map then
		return nil
	end

	if GameDataType.Tool == gameDataType then
		return self.CurrentMap.Tools

	elseif GameDataType.WorldInteractor == gameDataType then
		return self.CurrentMap.WorldInteractors

	elseif GameDataType.Npc == gameDataType then
		return self.CurrentMap.Npcs

	else
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
end

function MapController:ClearCurrentMap()
	if self.CurrentMap.Map then
		Debris:AddItem(self.CurrentMap.Map, 0)
		self.CurrentMap.Map = nil
	end
	
	self.CurrentMap.Tools = nil
	self.CurrentMap.WorldInteractors = nil
	self.CurrentMap.Npcs = nil
end

function MapController:SetCurrentMap(map)
	if not map then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	self.CurrentMap.Map = map:Clone()
	self.CurrentMap.Map.Parent = workspace

	-- Tools
	local tools = Instance.new("Folder")
	tools.Name = "Tools"
	tools.Parent = self.CurrentMap.Map
	self.CurrentMap.Tools = tools

	-- WorldInteractors
	local worldInteractors = Instance.new("Folder")
	worldInteractors.Name = "WorldInteractors"
	worldInteractors.Parent = self.CurrentMap.Map
	self.CurrentMap.WorldInteractors = worldInteractors

	-- Npcs
	local npcs = Instance.new("Folder")
	npcs.Name = "Npcs"
	npcs.Parent = self.CurrentMap.Map
	self.CurrentMap.Npcs = npcs

	return true
end

function MapController:SelectDesertMapTemp()
	local maps = MapsFolder:GetChildren()
	local desertMapIndex = nil
	for mapIndex, map in maps do
		if "DesertMap" == map.Name then
			desertMapIndex = mapIndex
			break
		end
	end

	local targetMapTemplate = MapTemplate:GetMapTemplate(desertMapIndex)
	Debug.Assert(targetMapTemplate, "비정상입니다.")
	if not self:SetCurrentMap(targetMapTemplate:GetMap()) then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return targetMapTemplate
end

function MapController:SelectRandomMap()
	local mapCandidates = MapsFolder:GetChildren()
	local mapCount = #mapCandidates
	if mapCount == 0 then
		Debug.Assert(false, "맵이 없습니다.")
		return nil
	end
	
	local selectedMapIndex = mapCandidates[math.random(1, #mapCandidates)]
	local targetMapTemplate = MapTemplate:GetMapTemplate(selectedMapIndex)
	Debug.Assert(targetMapTemplate, "비정상입니다.")
	if not self:SetCurrentMap(targetMapTemplate:GetMap()) then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return targetMapTemplate
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
	
	humanoidRootPart.CFrame = CFrame.lookAt(finalPosition, mapCenterPosition) + Vector3.new(0, 300, 0)
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

return MapController
