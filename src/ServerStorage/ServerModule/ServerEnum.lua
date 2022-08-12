local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility
local CommonEnum = CommonModuleFacade.CommonEnum

local ServerEnum = {
	WorldInteractorType = {
		ItemBox = 1,
		Count = 2
	}
}

-- 필요하면 추가
ServerEnum.WorldInteractorType.Converter = {
	[ServerEnum.WorldInteractorType.ItemBox] = "ItemBox"
}
Debug.Assert(ServerEnum.WorldInteractorType.Count == #ServerEnum.WorldInteractorType.Converter + 1, "비정상입니다.")


ServerEnum.__index = Utility.Inheritable__index
ServerEnum.__newindex = Utility.Inheritable__newindex
setmetatable(ServerEnum, CommonEnum)

return ServerEnum
