local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility
local CommonEnum = CommonModuleFacade.CommonEnum

local ServerEnum = {
	InteractableObjectType = {
		Tool = 1,
		WorldInteractor = 2,
		Count = 3
	},

	CollisionGroupType = {
		Player = 1,
		Skill = 2,
		WorldInteractor = 3,
		Npc = 4,
		Wall = 5,
		Count = 6
	},

	SkillDataType = {
		SkillImpl = 1,
        SkillDataParameter = 2,
		Count = 3
	},

	SkillImplType = {
        ValidateTargetInRange = 1,
        ApplySkillToTarget = 2,
		Count = 3
	},

	SkillDataParameterType = {
		SkillCollisionSize = 1,
        SkillCollisionOffset = 2,
		SkillCollisionDirection = 3,
		SkillCollisionSpeed = 4,
		SkillCollisionDetailMovementType = 5,
		SkillCollisionDuration = 6,

		SkillAnimation = 7,
		SkillDuration = 8,

		SkillEffect = 9,
		SkillOnDestroyingEffect = 10,
		Count = 11
	},

	SkillCollisionDetailMovementType = {

	},

}

-- 필요하면 추가
ServerEnum.InteractableObjectType.Converter = {
	[ServerEnum.InteractableObjectType.Tool] = "Tool",
	[ServerEnum.InteractableObjectType.WorldInteractor] = "WorldInteractor",
}
Debug.Assert(ServerEnum.InteractableObjectType.Count == #ServerEnum.InteractableObjectType.Converter + 1, "비정상입니다.")


ServerEnum.SkillImplType.Converter = {
	[ServerEnum.SkillImplType.ValidateTargetInRange] = "ValidateTargetInRange",
	[ServerEnum.SkillImplType.ApplySkillToTarget] = "ApplySkillToTarget",
}
Debug.Assert(ServerEnum.SkillImplType.Count == #ServerEnum.SkillImplType.Converter + 1, "비정상입니다.")


ServerEnum.SkillDataParameterType.Converter = {
	[ServerEnum.SkillDataParameterType.SkillCollisionSize] = "SkillCollisionSize",
	[ServerEnum.SkillDataParameterType.SkillCollisionOffset] = "SkillCollisionOffset",
	[ServerEnum.SkillDataParameterType.SkillCollisionDirection] = "SkillCollisionDirection",
	[ServerEnum.SkillDataParameterType.SkillCollisionSpeed] = "SkillCollisionSpeed",
	[ServerEnum.SkillDataParameterType.SkillCollisionDetailMovementType] = "SkillCollisionDetailMovementType",
	[ServerEnum.SkillDataParameterType.SkillCollisionDuration] = "SkillCollisionDuration",

	[ServerEnum.SkillDataParameterType.SkillAnimation] = "SkillAnimation",
	[ServerEnum.SkillDataParameterType.SkillDuration] = "SkillDuration",

	[ServerEnum.SkillDataParameterType.SkillEffect] = "SkillEffect",
	[ServerEnum.SkillDataParameterType.SkillOnDestroyingEffect] = "SkillOnDestroyingEffect",
}
Debug.Assert(ServerEnum.SkillDataParameterType.Count == #ServerEnum.SkillDataParameterType.Converter + 1, "비정상입니다.")

ServerEnum.__index = Utility.Inheritable__index
ServerEnum.__newindex = Utility.Inheritable__newindex
setmetatable(ServerEnum, CommonEnum)

return ServerEnum