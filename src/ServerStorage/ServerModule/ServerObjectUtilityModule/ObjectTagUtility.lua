-- 필요한곳마다 CollectionService를 호출할 수도 있지만, 태그 하는 방식이 달라질 수 있어서 일단 이곳을 통해 태그를 관리하도록 한다.
local CollectionService = game:GetService("CollectionService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug


local ObjectTagUtility = {}

function ObjectTagUtility:AddTag(instance, tagString)
    Debug.Assert(instance, "비정상입니다.")
    Debug.Assert(tagString, "비정상입니다.")

    CollectionService:AddTag(instance, tagString)
end

function ObjectTagUtility:RemoveTag(instance, tagString)
    Debug.Assert(instance, "비정상입니다.")
    Debug.Assert(tagString, "비정상입니다.")
    
    CollectionService:RemoveTag(instance, tagString)
end

function ObjectTagUtility:HasTag(instance, tagString)
    Debug.Assert(instance, "비정상입니다.")
    Debug.Assert(tagString, "비정상입니다.")

    return CollectionService:HasTag(instance, tagString)
end

function ObjectTagUtility:GetTag(instance)
    local tags = CollectionService:GetTags(instance)
    if not tags then
        return nil
    end

    local tagCount = #tags
    if 1 < tagCount then
        Debug.Print("태그가 1개이상 존재합니다. 가장 첫번째 태그를 가져옵니다.")
    end

    return tags[1]
end

function ObjectTagUtility:RemoveAllTags(instance)
    Debug.Assert(instance, "비정상입니다.")
    
    local tags = CollectionService:GetTags(instance)
    for _, tag in pairs(tags) do
        CollectionService:RemoveTag(instance, tag)
    end
end


return ObjectTagUtility