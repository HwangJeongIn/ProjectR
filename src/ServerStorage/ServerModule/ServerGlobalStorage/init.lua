local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility
local ToolUtility = CommonModuleFacade.ToolUtility
local CommonGlobalStorage = CommonModuleFacade.CommonGlobalStorage

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
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

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- STC
local AddToolSTC = RemoteEvents:WaitForChild("AddToolSTC")
local RemoveToolSTC = RemoteEvents:WaitForChild("RemoveToolSTC")
local EquipToolSTC = RemoteEvents:WaitForChild("EquipToolSTC")
local UnequipToolSTC = RemoteEvents:WaitForChild("UnequipToolSTC")


local ServerGlobalStorage = CommonGlobalStorage
ServerGlobalStorage.__index = Utility.Inheritable__index
ServerGlobalStorage.__newindex = Utility.Inheritable__newindex
--setmetatable(ServerGlobalStorage, CommonGlobalStorage)

function ServerGlobalStorage:Initialize(toolSystem, worldInteractorSystem, monsterSystem)
	if not toolSystem or not worldInteractorSystem or not monsterSystem then
		Debug.Assert(toolSystem, "비정상입니다.")
		Debug.Assert(worldInteractorSystem, "비정상입니다.")
		Debug.Assert(monsterSystem, "비정상입니다.")
		return false
	end

	self.GetToolSystem = function() return toolSystem end
	self.GetWorldInteractorSystem = function() return worldInteractorSystem end
	self.GetMonsterSystem = function() return monsterSystem end

	local ServerRemoteEventImpl = require(script:WaitForChild("ServerRemoteEventImpl"))
	ServerRemoteEventImpl:InitializeRemoteEvents(self)

	return true
end

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
	if not toolSystem:ActivateToolSkill(tool, skillIndex) then
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
		return false
	end
	
	return true
end

function ServerGlobalStorage:CreateToolToWorkspace(toolKey, toolCFrame)
	local createdTool = self:CreateTool(toolKey, game.workspace, toolCFrame)
	if not createdTool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	return true
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
	
	tool.Parent = game.workspace
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
	
	armor.Parent = player.Backpack

	if not self:SetArmorHandleEnabled(armor, true) then
		Debug.Assert(false, "비정상입니다.")
		return false
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
	
	if not self:SetArmorHandleEnabled(armor, false) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	armor.Parent = characterArmorsFolder

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
