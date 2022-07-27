local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility
local CommonGlobalStorage = CommonModuleFacade.CommonGlobalStorage

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))
local GameDataType = ServerEnum.GameDataType

local ServerGlobalStorage = {}

-- static 변수 반드시 싱글톤으로 사용해야 한다.
local Characters = {}


function ServerGlobalStorage:CheckCharacter(character)
	if Characters[character] then
		return true
	end
	return false
end

function ServerGlobalStorage:AddCharacter(character)
	
	if self:CheckCharacter(character) then
		Debug.Assert(false, "두 번 추가하려고 합니다.")
		return
	end
	
	Characters[character] = {}
	
end

function ServerGlobalStorage:RemoveCharacter(character)
	
	Characters[character] = nil
	
end

function ServerGlobalStorage:GetGameData(character, gameDataType)
	
	if not self:CheckCharacter(character) then
		Debug.Assert(false, "캐릭터가 없습니다.")
		return nil
	end
	
	if not Characters[character][gameDataType] then
		Debug.Print("게임 데이터 type(" .. tostring(gameDataType) .. ")가 초기화되지 않았습니다. => ".. character.Name)
		return nil
	end
	
	return Characters[character][gameDataType]
	
end


function ServerGlobalStorage:AddGameData(character, gameData)
	
	if not gameData then
		Debug.Assert(false, "입력으로 들어온 gameData가 비정상입니다.")
		return false
	end
	
	if not self:CheckCharacter(character) then
		Debug.Assert(false, "캐릭터가 없습니다.")
		return false
	end
	
	local gameDataType = gameData:GetGameDataType()
	Characters[character][gameDataType] = gameData
end

function ServerGlobalStorage:RemoveGameData(character, gameDataType)
	
	if not self:CheckCharacter(character) then
		Debug.Assert(false, "캐릭터가 없습니다.")
		return nil
	end
	
	Characters[character][gameDataType] = nil
	
end

ServerGlobalStorage.__index = Utility.Inheritable__index
ServerGlobalStorage.__newindex = Utility.Inheritable__newindex

setmetatable(ServerGlobalStorage, CommonGlobalStorage)


return ServerGlobalStorage
