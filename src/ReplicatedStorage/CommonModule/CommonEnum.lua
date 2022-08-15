local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonEnum = {
	
	GameStateType = {
		Waiting = 1,
		Starting = 2,
		Playing = 3,
		Dead = 4,
		WaitingForFinishing = 5,
		Count = 6
	},
	
	WinnerType =  {
		Player = 1,
		NoOne_TimeIsUp = 2,
		NoOne_AllPlayersWereDead = 3,
		Ai = 4,
		Count = 5
	},
	
	GameDataType = {
		Character = 1,
		Tool = 2,
		Vehicle = 3,
		WorldInteractor = 4,
		Skill = 5,
		Count = 6
	},
	
	ToolType = {
		Weapon = 1,
		Armor = 2,
		Consumable = 3,
		All = 4,
		Count = 5
	},

	EquipType = {
		Weapon = 1,
		Helmet = 2,
		Chestplate = 3,
		Leggings = 4,
		Boots = 5,
		Count = 6
	},

	SlotType = {
		InventorySlot = 1,
		EquipSlot = 2,
		QuickSlot = 3,
		SkillSlot = 4,
		SkillOwnerToolSlot = 5,
		Count = 6
	},
	
	StatusType = {
		Statistic = 1,
		EquipSlots = 2,
		Inventory = 3,
		QuickSlots = 4, -- 클라이언트 전용
		Count = 5
	},
	
	StatType = {
		STR = 1,
		DEF = 2,
		Move = 3,
		AttackSpeed = 4,
		
		HP = 5,
		MP = 6,
		HIT = 7,
		Dodge = 8,
		Block = 9,
		Critical = 10,
		Sight = 11,
		Count = 12
	},

	SkillType = {
		AttackSkill = 1,
		
	}
}

-- 필요하면 추가
CommonEnum.GameDataType.Converter = {
	[CommonEnum.GameDataType.Character] = "Character",
	[CommonEnum.GameDataType.Tool] = "Tool",
	[CommonEnum.GameDataType.Vehicle] = "Vehicle",
	[CommonEnum.GameDataType.WorldInteractor] = "WorldInteractor",
	[CommonEnum.GameDataType.Skill] = "Skill",
}
Debug.Assert(CommonEnum.GameDataType.Count == #CommonEnum.GameDataType.Converter + 1, "비정상입니다.")

CommonEnum.ToolType.Converter = {
	[CommonEnum.ToolType.Weapon] = "Weapon",
	[CommonEnum.ToolType.Armor] = "Armor",
	[CommonEnum.ToolType.Consumable] = "Consumable",
	[CommonEnum.ToolType.All] = "All",
}
Debug.Assert(CommonEnum.ToolType.Count == #CommonEnum.ToolType.Converter + 1, "비정상입니다.")

CommonEnum.EquipType.Converter = {
	[CommonEnum.EquipType.Weapon] = "Weapon",
	[CommonEnum.EquipType.Helmet] = "Helmet",
	[CommonEnum.EquipType.Chestplate] = "Chestplate",
	[CommonEnum.EquipType.Leggings] = "Leggings",
	[CommonEnum.EquipType.Boots] = "Boots"
}
Debug.Assert(CommonEnum.EquipType.Count == #CommonEnum.EquipType.Converter + 1, "비정상입니다.")

CommonEnum.SlotType.Converter = {
	[CommonEnum.SlotType.InventorySlot] = "InventorySlot",
	[CommonEnum.SlotType.EquipSlot] = "EquipSlot",
	[CommonEnum.SlotType.QuickSlot] = "QuickSlot",
	[CommonEnum.SlotType.SkillSlot] = "SkillSlot",
	[CommonEnum.SlotType.SkillOwnerToolSlot] = "SkillOwnerToolSlot"
}
Debug.Assert(CommonEnum.SlotType.Count == #CommonEnum.SlotType.Converter + 1, "비정상입니다.")

CommonEnum.StatType.Converter = {
	[CommonEnum.StatType.STR] = "STR",
	[CommonEnum.StatType.DEF] = "DEF",
	[CommonEnum.StatType.Move] = "Move",
	[CommonEnum.StatType.AttackSpeed] = "AttackSpeed",
	[CommonEnum.StatType.HP] = "HP",
	[CommonEnum.StatType.MP] = "MP",
	[CommonEnum.StatType.HIT] = "HIT",
	[CommonEnum.StatType.Dodge] = "Dodge",
	[CommonEnum.StatType.Block] = "Block",
	[CommonEnum.StatType.Critical] = "Critical",
	[CommonEnum.StatType.Sight] = "Sight"
}
Debug.Assert(CommonEnum.StatType.Count == #CommonEnum.StatType.Converter + 1, "비정상입니다.")

CommonEnum.__index = Utility.Inheritable__index
CommonEnum.__newindex = Utility.Inheritable__newindex

return CommonEnum
