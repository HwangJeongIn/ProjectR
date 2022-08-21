local PhysicsService = game:GetService("PhysicsService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))
local CollisionGroupType = ServerEnum.CollisionGroupType


local ObjectCollisionGroupUtility = {

    DefaultCollisionGroupName = "Default",
    DefaultCollisionGroupId = 0,

    CollisionGroupNameTable = {
        [CollisionGroupType.Player] = "PlayerCollision",
        [CollisionGroupType.Skill] = "SkillCollision",
        [CollisionGroupType.WorldInteractor] = "WorldInteractor",
        [CollisionGroupType.Wall] = "Wall"
    },

    CollisionGroupIdTable = {

    },

    CollidableGroupIdQueryTable = {
        
    }
}

function ObjectCollisionGroupUtility:Initialize()

    self.CollidableGroupIdQueryTable[self.DefaultCollisionGroupId] = {}
    local collisionGroupNames = self.CollisionGroupNameTable
    for collisionGroupType, collisionGroupName in pairs(collisionGroupNames) do
        PhysicsService:CreateCollisionGroup(collisionGroupName)
        local groupId = PhysicsService:GetCollisionGroupId(collisionGroupName)
        self.CollisionGroupIdTable[groupId] = collisionGroupType
        self.CollidableGroupIdQueryTable[groupId] = {}
        Debug.Print(collisionGroupName .. " => " .. tostring(groupId))
    end

    for _, collisionGroupName in pairs(collisionGroupNames) do
        self:SetEnableAllCollisionGroups(collisionGroupName, true)
    end
    
    self:SetEnableAllCollisionGroups(self.CollisionGroupNameTable[CollisionGroupType.Skill], false)

    self:SetEnableCollisionGroup(self.CollisionGroupNameTable[CollisionGroupType.Skill], self.CollisionGroupNameTable[CollisionGroupType.Player], true)
    self:SetEnableCollisionGroup(self.CollisionGroupNameTable[CollisionGroupType.Skill], self.CollisionGroupNameTable[CollisionGroupType.WorldInteractor], true)
    self:SetEnableCollisionGroup(self.CollisionGroupNameTable[CollisionGroupType.Skill], self.CollisionGroupNameTable[CollisionGroupType.Wall], true)
end

function ObjectCollisionGroupUtility:SetEnableCollisionGroup(collisionGroupName1, collisionGroupName2, isEnable)
    PhysicsService:CollisionGroupSetCollidable(collisionGroupName1, collisionGroupName2, isEnable)
    
    local collisionGroupId1 = PhysicsService:GetCollisionGroupId(collisionGroupName1)
    local collisionGroupId2 = PhysicsService:GetCollisionGroupId(collisionGroupName2)

    self.CollidableGroupIdQueryTable[collisionGroupId1][collisionGroupId2] = isEnable
    self.CollidableGroupIdQueryTable[collisionGroupId2][collisionGroupId1] = isEnable
end

function ObjectCollisionGroupUtility:SetEnableAllCollisionGroups(targetCollisionGroupName, isEnable)
    self:SetEnableCollisionGroup(targetCollisionGroupName, self.DefaultCollisionGroupName, isEnable)
    local collisionGroupNames = self.CollisionGroupNameTable
    for _, collisionGroupName in pairs(collisionGroupNames) do
        PhysicsService:CollisionGroupSetCollidable(targetCollisionGroupName, collisionGroupName, isEnable)
    end
end

function ObjectCollisionGroupUtility:SetCollisionGroup(part, collisionGroupName)
    if not collisionGroupName or not part then
        Debug.Assert(false, "비정상입니다.")
        return false
    end
    
    PhysicsService:SetPartCollisionGroup(part, collisionGroupName)
    return true
end

function ObjectCollisionGroupUtility:GetCollisionGroupTypeByCollisionGroupId(collisionGroupId)
    if not self.CollisionGroupIdTable[collisionGroupId] then
        Debug.Assert(false, "해당 아이디로 등록된 타입이 없습니다. => " .. tostring(collisionGroupId))
        return nil
    end
    return self.CollisionGroupIdTable[collisionGroupId]
end

function ObjectCollisionGroupUtility:GetCollisionGroupTypeByPart(part)
    local collisionGroupId = part.CollisionGroupId
    return self:GetCollisionGroupTypeByCollisionGroupId(collisionGroupId)
end

function ObjectCollisionGroupUtility:GetCollisionGroupNameByPart(part)
    local collisionGroupId = part.CollisionGroupId
    local collisionGroupType = self:GetCollisionGroupTypeByCollisionGroupId(collisionGroupId)
    if not collisionGroupType then
        Debug.Assert(false, "Part에 CollisionGroupType이 없습니다.")
        return nil
    end
    
    return self.CollisionGroupNameTable[collisionGroupType]
end

function ObjectCollisionGroupUtility:IsCollidable(collisionGroupId1, collisionGroupId2)
    if not self.CollidableGroupIdQueryTable[collisionGroupId1] then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return self.CollidableGroupIdQueryTable[collisionGroupId1][collisionGroupId2]
end

function ObjectCollisionGroupUtility:IsCollidableByPart(part1, part2)
    local collisionGroupId1 = part1.CollisionGroupId
    local collisionGroupId2 = part2.CollisionGroupId

    return self:IsCollidable(collisionGroupId1, collisionGroupId2)
end

function ObjectCollisionGroupUtility:IsCollidableByCollisionGroupName(collisionGroupName1, collisionGroupName2)
    local collisionGroupId1 = PhysicsService:GetCollisionGroupId(collisionGroupName1)
    local collisionGroupId2 = PhysicsService:GetCollisionGroupId(collisionGroupName2)

    return self:IsCollidable(collisionGroupId1, collisionGroupId2)
end

function ObjectCollisionGroupUtility:SetPlayerCollisionGroup(player)
    if not player then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local character = player.Character
    if not character then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:SetCollisionGroup(humanoidRootPart, self.CollisionGroupNameTable[CollisionGroupType.Player]) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

function ObjectCollisionGroupUtility:SetSkillCollisionGroup(skillCollision)
    if not skillCollision then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:SetCollisionGroup(skillCollision, self.CollisionGroupNameTable[CollisionGroupType.Skill]) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

function ObjectCollisionGroupUtility:SetWallCollisionGroup(wallCollision)
    if not wallCollision then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:SetCollisionGroup(wallCollision, self.CollisionGroupNameTable[CollisionGroupType.Wall]) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

function ObjectCollisionGroupUtility:SetWorldInteractorCollisionGroup(worldInteractor)
    if not worldInteractor then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    Debug.Assert(worldInteractor.Trigger, "비정상입니다.")
    if not self:SetCollisionGroup(worldInteractor.Trigger, self.CollisionGroupNameTable[CollisionGroupType.WorldInteractor]) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

ObjectCollisionGroupUtility:Initialize()
return ObjectCollisionGroupUtility