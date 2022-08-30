local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility

local ToolUtility = CommonModuleFacade.ToolUtility
local WorldInteractorUtility = CommonModuleFacade.WorldInteractorUtility
local NpcUtility = CommonModuleFacade.NpcUtility

local CommonGlobalStorage = CommonModuleFacade.CommonGlobalStorage

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))
local ServerConstant = require(ServerModule:WaitForChild("ServerConstant"))

local ServerObjectUtilityModule = ServerModule:WaitForChild("ServerObjectUtilityModule")

local DefaultPlayerWalkSpeed = ServerConstant.DefaultPlayerWalkSpeed
local DefaultPlayerMaxHealth = ServerConstant.DefaultPlayerMaxHealth
local DefaultPlayerJumpHeight = ServerConstant.DefaultPlayerJumpHeight
local DefaultPlayerJumpPower = ServerConstant.DefaultPlayerJumpPower

local MaxPickupDistance = ServerConstant.MaxPickupDistance
local MaxDropDistance = ServerConstant.MaxDropDistance
local MaxSkillCount = ServerConstant.MaxSkillCount

local EquipTypeToBoneMappingTable = ServerConstant.EquipTypeToBoneMappingTable

local GameDataType = ServerEnum.GameDataType
local StatusType = ServerEnum.StatusType
local ToolType = ServerEnum.ToolType
local EquipType = ServerEnum.EquipType
local StatType = ServerEnum.StatType


local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- STC
local AddToolSTC = RemoteEvents:WaitForChild("AddToolSTC")
local RemoveToolSTC = RemoteEvents:WaitForChild("RemoveToolSTC")
local EquipToolSTC = RemoteEvents:WaitForChild("EquipToolSTC")
local UnequipToolSTC = RemoteEvents:WaitForChild("UnequipToolSTC")
local SetRecentAttackerSTC = RemoteEvents:WaitForChild("SetRecentAttackerSTC")
local SetSkillLastActivationTimeSTC = RemoteEvents:WaitForChild("SetSkillLastActivationTimeSTC")
local SetKillCountSTC = RemoteEvents:WaitForChild("SetKillCountSTC")

local ServerGlobalStorage = CommonGlobalStorage
ServerGlobalStorage.__index = Utility.Inheritable__index
ServerGlobalStorage.__newindex = Utility.Inheritable__newindex
--setmetatable(ServerGlobalStorage, CommonGlobalStorage)

function ServerGlobalStorage:Initialize(toolSystem, worldInteractorSystem, npcSystem)
	if not toolSystem or not worldInteractorSystem or not npcSystem then
		Debug.Assert(toolSystem, "비정상입니다.")
		Debug.Assert(worldInteractorSystem, "비정상입니다.")
		Debug.Assert(npcSystem, "비정상입니다.")
		return false
	end

	self.GetToolSystem = function() return toolSystem end
	self.GetWorldInteractorSystem = function() return worldInteractorSystem end
	self.GetNpcSystem = function() return npcSystem end

	local mapController = require(script:WaitForChild("MapController"))
	self.MapController = mapController

	local ServerRemoteEventImpl = require(script:WaitForChild("ServerRemoteEventImpl"))
	ServerRemoteEventImpl:InitializeRemoteEvents(self)

	return true
end

function ServerGlobalStorage:CloneObjectFromDummyObject(gameDataType, dummyObject)

	local dummyObjectName = dummyObject.Name
	local dummyObjectCFrame = dummyObject.CFrame

	local createdObject = nil
	if GameDataType.Tool == gameDataType then
		local objectGameDataKey = ToolUtility:GetGameDataKeyByModelName(dummyObjectName)
		createdObject = self:CreateToolToCurrentMap(objectGameDataKey, dummyObjectCFrame)

	elseif GameDataType.WorldInteractor == gameDataType then
		local objectGameDataKey = WorldInteractorUtility:GetGameDataKeyByModelName(dummyObjectName)
		createdObject = self:CreateWorldInteractor(objectGameDataKey, dummyObjectCFrame)

	elseif GameDataType.Npc == gameDataType then
		-- Npc 생성
		-- TODO : Npc 시스템 추가되면 생성 코드 정리
		local objectGameDataKey = NpcUtility:GetGameDataKeyByModelName(dummyObjectName)
		createdObject = self:CreateNpc(objectGameDataKey, dummyObjectCFrame)

	else
		Debug.Assert(false, "비정상입니다. => " .. tostring(gameDataType) .. " : " .. dummyObjectName)
		return nil
	end

	if not createdObject then
		Debug.Assert(false, "비정상입니다. => " .. tostring(gameDataType) .. " : " .. dummyObjectName)
		return nil
	end
	
	return createdObject
end

function ServerGlobalStorage:CreateObjectsFromDummyObjects(gameDataType, dummyObjectsFolder)
	local dummyObjects = dummyObjectsFolder:GetChildren()
	for _, dummyObject in dummyObjects do
		local createdObject = self:CloneObjectFromDummyObject(gameDataType, dummyObject)
		if not createdObject then
			Debug.Assert(false, "비정상입니다.")
			return false
		end

		self.MapController:AddObjectToCurrentMap(gameDataType, createdObject)
	end

	return true
end

function ServerGlobalStorage:CreateMapObjectsByMapTemplate(mapTemplate)
	local mapTools = mapTemplate.GetTools()
	local mapWorldInteractors = mapTemplate:GetWorldInteractors()
	local mapNpcs = mapTemplate:GetNpcs()

	if mapTools then
		if not self:CreateObjectsFromDummyObjects(GameDataType.Tool, mapTools) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end
	end

	if mapWorldInteractors then
		if not self:CreateObjectsFromDummyObjects(GameDataType.WorldInteractor, mapWorldInteractors) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end
	end

	if mapNpcs then
		if not self:CreateObjectsFromDummyObjects(GameDataType.Npc, mapNpcs) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end
	end

	return true
end

function ServerGlobalStorage:SelectRandomMapAndEnterMap(playersInGame)
	local mapTemplate self.MapController:SelectRandomMap()
	if not mapTemplate then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self:CreateMapObjectsByMapTemplate(mapTemplate) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	self.MapController:EnterMap(playersInGame)
	return true
end

function ServerGlobalStorage:SelectDesertMapAndEnterMapTemp(playersInGame)
	local mapTemplate = self.MapController:SelectDesertMapTemp()
	if not mapTemplate then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self:CreateMapObjectsByMapTemplate(mapTemplate) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	self.MapController:EnterMap(playersInGame)
	return true
end


function ServerGlobalStorage:ClearCurrentMap()
	-- Tool 정리
	local tools = self.MapController:GetCurrentMapObjects(GameDataType.Tool)
	if tools then
		local toolsToDelete = tools:GetChildren()
		for _, toolToDelete in pairs(toolsToDelete) do
			if not self:DestroyTool(toolToDelete) then
				Debug.Assert(false, "비정상입니다.")
				return false
			end
		end
	end

	-- WorldInteractor 정리
	local worldInteractors = self.MapController:GetCurrentMapObjects(GameDataType.WorldInteractor)
	if worldInteractors then
		local worldInteractorsToDelete = worldInteractors:GetChildren()
		for _, worldInteractorToDelete in pairs(worldInteractorsToDelete) do
			if not self:DestroyWorldInteractor(worldInteractorToDelete) then
				Debug.Assert(false, "비정상입니다.")
				return false
			end
		end
	end


	-- Npc 정리
	-- TODO : Npc 시스템 추가되면 정리 코드도 추가

	self.MapController:ClearCurrentMap()
end

function ServerGlobalStorage:OnCreateEmptyPlayerData(playerData)

end

function ServerGlobalStorage:ApplyStatToHumanoid(playerId, playerStatistic)
	if not playerId or not playerStatistic then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local player = game.Players:GetPlayerByUserId(playerId)
	local character = player.Character
	if not character then
		Debug.Assert(false, "캐릭터가 없습니다.")
		return false
	end

	local humanoid = character.Humanoid
	if not humanoid then
		Debug.Assert(false, "Humanoid가 없습니다.")
		return false
	end

	local hp = playerStatistic:GetStat(StatType.Hp)
	humanoid.MaxHealth = DefaultPlayerMaxHealth + hp
	humanoid.Health = humanoid.Health + hp

	local move = playerStatistic:GetStat(StatType.Move)
	humanoid.WalkSpeed = DefaultPlayerWalkSpeed + move

	local jump = playerStatistic:GetStat(StatType.Jump)
	humanoid.JumpHeight = DefaultPlayerJumpHeight + jump
	humanoid.JumpPower = DefaultPlayerJumpPower + jump
	
	return true
end

function ServerGlobalStorage:PostUpdateRemovedToolGameData(playerId, playerStatistic)
	return self:ApplyStatToHumanoid(playerId, playerStatistic)
end

function ServerGlobalStorage:PostUpdateAddedToolGameData(playerId, playerStatistic)
	return self:ApplyStatToHumanoid(playerId, playerStatistic)
end

function ServerGlobalStorage:AddKillCountAndNotify(playerId)
	local currentKillCount = self:GetKillCount(playerId)
	if nil == currentKillCount then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	currentKillCount += 1
	if not self:SetKillCount(playerId, currentKillCount) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local player = game.Players:GetPlayerByUserId(playerId)
	SetKillCountSTC:FireClient(player, currentKillCount)

	Debug.Print("AddKillCountAndNotify : " .. player.Name .. " => " .. tostring(currentKillCount))
	return true
end

function ServerGlobalStorage:SetRecentAttackerAndNotify(playerId, attacker)
	if not self:SetRecentAttacker(playerId, attacker) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local player = game.Players:GetPlayerByUserId(playerId)
	SetRecentAttackerSTC:FireClient(player, attacker)
	
	Debug.Print("SetRecentAttackerAndNotify : Attacker : " .. attacker.Name .. " | Attackee : " .. player.Name)
	return true
end

function ServerGlobalStorage:SetSkillLastActivationTimeAndNotify(playerId, skillGameDataKey, lastActivationTime)
	if not self:SetSkillLastActivationTime(playerId, skillGameDataKey, lastActivationTime) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local player = game.Players:GetPlayerByUserId(playerId)
	SetSkillLastActivationTimeSTC:FireClient(player, skillGameDataKey, lastActivationTime)
	return true
end

--[[
function ServerGlobalStorage:GetSkillLastActivationTime(playerId, skillGameDataKey)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return nil
	end

	if not skillGameDataKey then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return self.PlayerTable[playerId].SkillLastActivationTimeTable[skillGameDataKey]
end
--]]
function ServerGlobalStorage:ActivateToolSkill(player, tool, skillIndex)
	if not tool or not skillIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local toolGameData = ToolUtility:GetGameData(tool)
	local equipType = toolGameData.EquipType
	if not equipType then
		Debug.Assert(false, "장착할 수 있는 장비만 스킬을 사용할 수 있습니다.")
		return false
	end
	
	 if  MaxSkillCount < toolGameData.SkillCount
	 or toolGameData.SkillCount < skillIndex 
	 or 0 >= skillIndex then
		Debug.Assert(false, "스킬인덱스가 비정상입니다. => " .. tostring(skillIndex))
		return false
	 end

	-- 장착 검증
	local playerId = player.UserId
	if not self:IsInCharacter(playerId, equipType, tool) then
		Debug.Assert(false, "캐릭터가 해당 도구를 장착하고 있지 않습니다.")
		return false
	end

	local toolSystem = self:GetToolSystem()
	if not toolSystem:ActivateToolSkill(player, tool, skillIndex) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	return true
end

function ServerGlobalStorage:CreateWorldInteractor(worldInteractorKey, worldInteractorCFrame)
	if not worldInteractorCFrame then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local worldInteractorSystem = self:GetWorldInteractorSystem()
	local createdWorldInteractor = worldInteractorSystem:CreateWorldInteractor(worldInteractorKey)
	if not createdWorldInteractor then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	if not self.MapController:AddObjectToCurrentMap(GameDataType.WorldInteractor, createdWorldInteractor) then
		Debug.Assert(false, "맵이 없습니다.")
		return nil
	end

	createdWorldInteractor.Trigger.CFrame = worldInteractorCFrame
	return createdWorldInteractor 
end

function ServerGlobalStorage:DestroyWorldInteractor(worldInteractor)
	if not worldInteractor then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local worldInteractorSystem = self:GetWorldInteractorSystem()
	if not worldInteractorSystem:DestroyWorldInteractor(worldInteractor) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function ServerGlobalStorage:DamageWorldInteractor(targetWorldInteractor, damage)
	if not targetWorldInteractor or not damage then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local worldInteractorSystem = self:GetWorldInteractorSystem()
	if not worldInteractorSystem:DamageWorldInteractor(targetWorldInteractor, damage) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function ServerGlobalStorage:CreateTool(toolKey, parent, toolCFrame)
	if not parent then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local toolSystem = self:GetToolSystem()
	local createdTool = toolSystem:CreateTool(toolKey)
	if not createdTool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	createdTool.Parent = parent
	if toolCFrame then
		createdTool.Handle.CFrame = toolCFrame
	end
	return createdTool 
end

function ServerGlobalStorage:CreateToolToPlayer(toolKey, player)
	local createdTool = self:CreateTool(toolKey, player.Backpack, nil)
	if not createdTool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local toolSystem = self:GetToolSystem()
	if not toolSystem:SetToolOwnerPlayer(createdTool, player) then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	return createdTool
end

function ServerGlobalStorage:CreateToolToCurrentMap(toolKey, toolCFrame)
	local currentMapTools = self.MapController:GetCurrentMapObjects(GameDataType.Tool)
	if not currentMapTools then
		Debug.Assert(false, "맵이 없습니다.")
		return nil
	end

	local createdTool = self:CreateTool(toolKey, currentMapTools, toolCFrame)
	if not createdTool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	return createdTool
end

function ServerGlobalStorage:DestroyTool(tool)
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local toolSystem = self:GetToolSystem()
	if not toolSystem:DestroyTool(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end


function ServerGlobalStorage:DropToolRaw(character, tool)
	

	--[[
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
	--]]


	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	Debug.Assert(humanoidRootPart, "비정상입니다.")

	local characterCFrame = humanoidRootPart.CFrame

	local targetCFrame = characterCFrame + characterCFrame.LookVector * 3
	
	local currentMapTools = self.MapController:GetCurrentMapObjects(GameDataType.Tool)
	if currentMapTools then
		tool.Parent = currentMapTools
	else
		tool.Parent = game.workspace
	end
	
	tool.Handle.CFrame = targetCFrame
	return true
end

function ServerGlobalStorage:DropTool(player, tool)
	local playerId = player.UserId
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local character = player.Character
	if not character then
		Debug.Print("플레이어 캐릭터가 존재하지 않습니다. 있을 수 있는 상황입니다.")
		return false
	end

	if not self:IsInBackpack(playerId, tool) then
		Debug.Assert(false, "플레이어가 소유한 도구가 아닙니다.")
		return false
	end

	if not self:DropToolRaw(character, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local toolSystem = self:GetToolSystem()
	if not toolSystem:SetToolOwnerPlayer(tool, nil) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function ServerGlobalStorage:DropSelectedTool(player, tool)
	local playerId = player.UserId
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	if not self:IsInCharacterRaw(playerId, tool) then
		Debug.Assert(false, "캐릭터가 해당 도구를 들고 있지 않습니다.")
		return false
	end

	local character = player.Character
	if not character then
		Debug.Print("플레이어 캐릭터가 존재하지 않습니다. 있을 수 있는 상황입니다.")
		return false
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		Debug.Print("캐릭터의 휴머노이드가 존재하지 않습니다. 있을 수 있는 상황입니다.")
		return false
	end

	ServerGlobalStorage:CheckAndUnequipIfWeapon(playerId)
	humanoid:UnequipTools()

	if not self:DropToolRaw(character, tool) then
		Debug.Assert(false, "캐릭터가 해당 도구를 들고 있지 않습니다.")
		return false
	end
	return true
end

function ServerGlobalStorage:SelectTool(player, tool, fromWorkspace)
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	local playerId = player.UserId
	if not fromWorkspace then
		if not ServerGlobalStorage:IsInBackpack(playerId, tool) then
			Debug.Assert(false, "플레이어가 소유한 도구가 아닙니다.")
			return false
		end
	end

	local character = player.Character
	if not character then
		Debug.Print("플레이어 캐릭터가 존재하지 않습니다. 있을 수 있는 상황입니다.")
		return false
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		Debug.Print("캐릭터의 휴머노이드가 존재하지 않습니다. 있을 수 있는 상황입니다.")
		return false
	end

	self:CheckAndUnequipIfWeapon(playerId)
	self:CheckAndEquipIfWeapon(playerId, tool, fromWorkspace)
	humanoid:EquipTool(tool)

	return true
end

function ServerGlobalStorage:SelectWorkspaceTool(player, tool)
	local distance = player:DistanceFromCharacter(tool.Handle.Position)
	if distance > MaxPickupDistance then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self:SelectTool(player, tool, true) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local toolSystem = self:GetToolSystem()
	if not toolSystem:SetToolOwnerPlayer(tool, player) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function ServerGlobalStorage:GetBonesByEquipType(character, equipType)
	if not character or not equipType then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local targetBoneNames = EquipTypeToBoneMappingTable[equipType]
	if not targetBoneNames then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local targetBones = {}

	for _, targetBoneName in targetBoneNames do
		local targetBone = character:FindFirstChild(targetBoneName)
		if not targetBone then
			Debug.Assert(false, "해당 이름의 본이 존재하지 않습니다. => " .. targetBoneName)
			return nil
		end

		table.insert(targetBones, targetBone)
	end

	return targetBones
end

function ServerGlobalStorage:SetArmorHandleEnabled(armor, enabled)
	if not armor then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local handle = armor:FindFirstChild("Handle")
	if not handle then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local binder = handle:FindFirstChild("Binder")
	if not binder then
		Debug.Assert(false, "Binder가 없습니다.")
		return false
	end
	
	local weldContraints = binder:GetChildren()
	for _, weldConstraint in weldContraints do
		weldConstraint.Name = "Test"
		weldConstraint.Enabled = enabled
	end

	return true
end

function ServerGlobalStorage:FindAllAttachmentsOfArmor(armor, output)
	if not armor then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local mesh = armor:FindFirstChild("Mesh")

	local allParts = mesh:GetChildren()

	for _, part in allParts do
		local mainPart = part:FindFirstChild("MainPart")
		if not mainPart then
			Debug.Assert(false, "MainPart가 없습니다.")
			return false
		end

		local attachment = mainPart:FindFirstChildOfClass("Attachment")
		if not attachment then
			Debug.Assert(false, "해당 Part의 장착 위치를 결정하기 위해 Attachment를 추가하세요.")
			return false
		end
		table.insert(output, attachment)
	end

	return true
end

--[[
function ServerGlobalStorage:FindAllAttachmentsOfArmor(object, output)
	if not object then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not object:IsA("Instance") then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local children = object:GetChildren()
	for _, child in children do
		if child:IsA("Instance") then
			if not self:FindAllAttachmentsOfArmor(child, output) then
				return false
			end
		end

		if child:IsA("Attachment") then
			table.insert(output, child)
		end
	end

	return true
end
--]]

function ServerGlobalStorage:DetachArmorFromPlayer(player, armor)
	if not player or not armor then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local character = player.Character
	if not character then
		Debug.Assert(false, "캐릭터가 없습니다.")
		return false
	end

	local characterArmorsFolder = character:FindFirstChild("Armors")
	if not characterArmorsFolder then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	-- 장착 검증
	local equippedArmor = characterArmorsFolder:FindFirstChild(armor.Name)
	if equippedArmor ~= armor then
		Debug.Assert(false, "해당 방어구를 장착하고 있지 않습니다.")
		return false
	end
	
	if not self:SetArmorHandleEnabled(armor, true) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	armor.Parent = player.Backpack

	local attachments = {}
	if not self:FindAllAttachmentsOfArmor(armor, attachments) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if #attachments == 0 then
		Debug.Assert(false, "방어구에 부착 위치가 존재하지 않습니다.")
		return false
	end

	for _, attachment in attachments do
		local attachmentChildren = attachment:GetChildren()
		for _, attachmentChild in attachmentChildren do
			Debris:AddItem(attachmentChild, 0)
		end
	end

	return true
end

function ServerGlobalStorage:AttachArmorToPlayer(player, armor)
	if not player or not armor then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local character = player.Character
	if not character then
		Debug.Assert(false, "캐릭터가 없습니다.")
		return false
	end

	local equipType = ToolUtility:GetEquipType(armor)
	if not equipType then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	local characterArmorsFolder = character:FindFirstChild("Armors")
	if not characterArmorsFolder then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	-- 장착 검증
	local equippedArmor = characterArmorsFolder:FindFirstChild(armor.Name)
	if equippedArmor == armor then
		Debug.Assert(false, "장착중인데 다시 장착하려 합니다. 확인해야합니다.")
		return false
	end
	
	armor.Parent = characterArmorsFolder

	if not self:SetArmorHandleEnabled(armor, false) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local targetBones = self:GetBonesByEquipType(character, equipType)
	if not targetBones then
		Debug.Assert(false, "본이 존재하지 않습니다.")
		return false
		--[[
		Debug.Assert(false, "본이 존재하지 않습니다. 가장 상위 본에 부착합니다.")
		targetBone = character:FindFirstChild("HumanoidRootPart")
		Debug.Assert(targetBone, "HumanoidRootPart가 없습니다.")
		--]]
	end

	local attachments = {}
	if not self:FindAllAttachmentsOfArmor(armor, attachments) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if #attachments == 0 then
		Debug.Assert(false, "방어구에 부착 위치가 존재하지 않습니다.")
		return false
	end

	for _, targetBone in targetBones do
		for _, attachment in attachments do
			local boneAttachment = targetBone:FindFirstChild(attachment.Name)
			if not boneAttachment then
				continue
				--Debug.Assert(false, "해당 본에 다음의 부착 위치가 존재하지 않습니다. => " .. targetBones.Name " : " .. attachment.Name)
				--return false
			end
			local tempWeld = Instance.new("RigidConstraint")
			tempWeld.Name = "TempRigidConstraint"
			tempWeld.Attachment0 = attachment
			tempWeld.Attachment1 = boneAttachment
			tempWeld.Parent = attachment
		end
	end

	return true
end

function ServerGlobalStorage:IsInCharacterByEquipType(playerId, equipType)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	local equippedTool = self:GetEquipSlot(playerId, equipType)
	if not equippedTool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return self:IsInCharacter(playerId, equipType, equippedTool)
end

-- Weapon은 명시적으로 장착하는 것이 없다. 그냥 들고 있으면 알아서 EquipSlot에 집어넣어야한다.
function ServerGlobalStorage:CheckAndEquipIfWeapon(playerId, tool, fromWorkspace)
	local equipType = ToolUtility:GetEquipType(tool)
	if not equipType or equipType ~= EquipType.Weapon then
		return false
	end

	if not fromWorkspace then
		if not self:IsInBackpack(playerId, tool) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end
	end


	local prevTool, currentTool = self:EquipTool(playerId, equipType, tool)
	if not currentTool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local player = game.Players:GetPlayerByUserId(playerId)
	EquipToolSTC:FireClient(player, equipType, tool)
	return true
end

function ServerGlobalStorage:CheckAndUnequipIfWeapon(playerId)
	local equippedWeapon = self:GetEquipSlot(playerId, EquipType.Weapon)
	if not equippedWeapon then
		return false
	end

	if not self:IsInCharacter(playerId, EquipType.Weapon, equippedWeapon) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local prevTool = self:UnequipTool(playerId, EquipType.Weapon) 
	if not prevTool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local player = game.Players:GetPlayerByUserId(playerId)
	UnequipToolSTC:FireClient(player, EquipType.Weapon)
	return true
end

function ServerGlobalStorage:AddTool(playerId, tool)
	local player = game.Players:GetPlayerByUserId(playerId)
	if not player then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return false
	end

	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "플레이어 데이터가 존재하지 않습니다.")
		return false
	end
	
	local inventory = self.PlayerTable[playerId][StatusType.Inventory]
	if not inventory:AddTool(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local slotIndex = inventory:GetSlotIndexRaw(tool)
	Debug.Assert(slotIndex, "코드 버그")

	AddToolSTC:FireClient(player, slotIndex, tool)
	return true
end

function ServerGlobalStorage:RemoveTool(playerId, tool)
	local player = game.Players:GetPlayerByUserId(playerId)
	if not player then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return false
	end

	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "플레이어 데이터가 존재하지 않습니다.")
		return false
	end
	
	local inventory = self.PlayerTable[playerId][StatusType.Inventory]
	local slotIndex = inventory:GetSlotIndexRaw(tool)
	Debug.Assert(slotIndex, "코드 버그")

	if not inventory:RemoveTool(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	RemoveToolSTC:FireClient(player, slotIndex, tool)

	-- 삭제하려면 Parent가 nil이다.
	-- 인벤토리에서 빼고 삭제해야해서 이방식대로 처리한다.
	if not tool.Parent then
		local character = player.Character
		local targetCFrame = nil
		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				local characterCFrame = humanoidRootPart.CFrame
				targetCFrame = characterCFrame + characterCFrame.LookVector * 3
			end
		end

		if targetCFrame then
			tool.Handle.CFrame = targetCFrame
		end

		if not self:DestroyTool(tool) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end
	end
	return true
end

function ServerGlobalStorage:RegisterPlayerEvent(player)

	if not player then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local playerId = player.UserId
	player.Backpack.ChildAdded:Connect(function(tool)
		self:AddTool(playerId, tool)
	end)

	player.Backpack.ChildRemoved:Connect(function(tool)
		self:RemoveTool(playerId, tool)
	end)
	
	return true
end

function ServerGlobalStorage:InitializePlayer(player)
	
	if not self:AddPlayer(player) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

return ServerGlobalStorage
