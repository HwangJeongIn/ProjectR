local PhysicsService = game:GetService("PhysicsService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug

--[[
local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))
--]]

local ObjectCollisionGroupUtility = {
    CollisionNames = {
        Player = "PlayerCollision",
        Skill = "SkiilCollision",
    }
}

function ObjectCollisionGroupUtility:DisableCollisionGroup(targetCollisionName)
    PhysicsService:CollisionGroupSetCollidable(targetCollisionName, "Default", false)

    local allCollisionNames = self.CollisionNames
    for _, collisionName in pairs(allCollisionNames) do
        PhysicsService:CollisionGroupSetCollidable(targetCollisionName, collisionName, false)
    end
end

function ObjectCollisionGroupUtility:EnableCollisionGroup(collisionName1, collisionName2)
    PhysicsService:CollisionGroupSetCollidable(collisionName1, collisionName2, true)
end

function ObjectCollisionGroupUtility:Initialize()
    local allCollisionNames = self.CollisionNames
    for _, collisionName in pairs(allCollisionNames) do
        PhysicsService:CreateCollisionGroup(collisionName)
    end

    self:DisableCollisionGroup(allCollisionNames.Skill)
    self:EnableCollisionGroup(allCollisionNames.Skill, allCollisionNames.Player)
end

function ObjectCollisionGroupUtility:RegisterCollision(part, collisionName)
    if not collisionName or not part then
        Debug.Assert(false, "비정상입니다.")
        return false
    end
    
    PhysicsService:SetPartCollisionGroup(part, collisionName)
    return true
end

function ObjectCollisionGroupUtility:RegisterPlayerCollision(player)
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

    if not self:RegisterCollision(humanoidRootPart, self.CollisionNames.Player) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

function ObjectCollisionGroupUtility:RegisterSkillCollision(skillCollision)
    if not skillCollision then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:RegisterCollision(skillCollision, self.CollisionNames.Skill) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

ObjectCollisionGroupUtility:Initialize()
return ObjectCollisionGroupUtility