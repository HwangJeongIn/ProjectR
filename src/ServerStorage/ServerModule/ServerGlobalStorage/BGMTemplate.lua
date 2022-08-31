local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility

local CommonEnum = CommonModuleFacade.CommonEnum
local MapType = CommonEnum.MapType
local MapTypeConverter = MapType.Converter

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ResourceTemplateModule = ServerModule:WaitForChild("ResourceTemplateModule")


local BGMTemplate = Utility:DeepCopy(require(ResourceTemplateModule:WaitForChild("SoundTemplate")))

BGMTemplate.MapTypeToBGMMappingTable = {
    [MapType.MainMap] = "ColdComfort",
    [MapType.DesertMap] = "DesertCaravan",
    [MapType.DesertMap2] = "ColdComfort",
    [MapType.ForestMap] = "ColdComfort",
    [MapType.NeonArenaMap] = "ColdComfort",
}

function BGMTemplate:ValidateSound(sound)
    if not sound.Looped then
        Debug.Assert(false, "BGM은 무조건 Looped 옵션이 켜져있어야 합니다. => " .. sound.Name)
        return false
    end
    
    return true
end

function BGMTemplate:Initialize()
    local SoundsFolder = ServerStorage:WaitForChild("Sounds")
    local BGMs = SoundsFolder:WaitForChild("BGMs")

    if not self:InitializeAllSounds(BGMs) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    -- 매핑 테이블 검증
    for _, BGMName in pairs(BGMTemplate.MapTypeToBGMMappingTable) do
        if not self:Get(BGMName) then
            Debug.Assert(false, "해당 이름의 BGM이 존재하지 않습니다. => " .. BGMName)
            return false
        end
    end

    return true
end

function BGMTemplate:GetBGMByMapType(mapType)
    if not mapType then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    if not self.MapTypeToBGMMappingTable[mapType] then
        Debug.Print("해당 맵에 등록된 BGM이 없습니다. BGM이 재생되지 않습니다. => " ..tostring(MapTypeConverter[mapType]))
        return nil
    end

    return self:Get(self.MapTypeToBGMMappingTable[mapType])
end


BGMTemplate:Initialize()
return BGMTemplate