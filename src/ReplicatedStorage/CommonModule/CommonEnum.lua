local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonEnum = {
	
	GameStateType = {
		Waiting = 1,
		Starting = 2,
		Playing = 3,
		Dead = 4,
		WaitingForFinishing = 5
	},
	
	WinnerType =  {
		Player = 0,
		NoOne_TimeIsUp = 1,
		NoOne_AllPlayersWereDead = 2,
		Ai = 3
	},
	
	GameDataType = {
		Character = 1,
		Tool = 2,
		Vehicle = 3,
		WorldInteractor = 4,
	},
	
	ToolType = {
		All = 1,
		Weapon = 2,
		Armor = 3,
		Consumable = 4
	},
	
	ArmorType = {
		Helmet = 1,
		Chestplate = 2,
		Leggings = 3,
		Boots = 4,
		Count = 5
	},
	
	StatusType = {
		Statistic = 1,
		EquipSlots = 2,
		Inventory = 3,
		QuickSlots = 4, -- 클라이언트 전용
	}
	
	--[[,
	
	MessageType = {
		Main = 0,
		Event = 1
	}--]]
}

CommonEnum.__index = Utility.Inheritable__index
CommonEnum.__newindex = Utility.Inheritable__newindex

return CommonEnum
