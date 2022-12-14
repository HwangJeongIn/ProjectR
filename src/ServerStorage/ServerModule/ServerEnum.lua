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
        SkillSequence = 2,
		Count = 3
	},

	SkillImplType = {
        ValidateTargetInRange = 1,
        ApplySkillToTarget = 2,
		Count = 3
	},

	--[[
	SkillSoundType = {
		OnCreate = 1,
		OnUpdate = 2,
		OnHit = 3,
		OnDestroy = 4,
		Count = 5
	},
	--]]

	SkillCollisionParameterType = {
		SkillCollisionSize = 1,
        SkillCollisionOffset = 2,
		SkillCollisionEffect = 3,
		SkillCollisionOnDestroyEffect = 4,

		SkillCollisionOnCreateSound = 5,
		SkillCollisionOnUpdateSound = 6,
		SkillCollisionOnHitSound = 7,
		SkillCollisionOnDestroySound = 8,
		
		Count = 9
	},

	SkillCollisionSequenceTrackParameterType = {
		SkillCollisionDirection = 1,
		SkillCollisionSpeed = 2,
		SkillCollisionSize = 3,
		SkillCollisionSequenceTrackDuration = 4,
		ListenSkillCollisionEvent = 5,
		Count = 6
	},

	SkillCollisionSequenceStateType = {
		Playing = 1,
		Ended = 2,
		Count = 3
	},

	SkillSequenceAnimationTrackStateType = {
		Playing = 1,
		Ended = 2,
		Count = 3
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


ServerEnum.SkillCollisionParameterType.Converter = {
	[ServerEnum.SkillCollisionParameterType.SkillCollisionSize] = "SkillCollisionSize",
	[ServerEnum.SkillCollisionParameterType.SkillCollisionOffset] = "SkillCollisionOffset",
	[ServerEnum.SkillCollisionParameterType.SkillCollisionEffect] = "SkillCollisionEffect",
	[ServerEnum.SkillCollisionParameterType.SkillCollisionOnDestroyEffect] = "SkillCollisionOnDestroyEffect",

	
	[ServerEnum.SkillCollisionParameterType.SkillCollisionOnCreateSound] = "SkillCollisionOnCreateSound",
	[ServerEnum.SkillCollisionParameterType.SkillCollisionOnUpdateSound] = "SkillCollisionOnUpdateSound",
	[ServerEnum.SkillCollisionParameterType.SkillCollisionOnHitSound] = "SkillCollisionOnHitSound",
	[ServerEnum.SkillCollisionParameterType.SkillCollisionOnDestroySound] = "SkillCollisionOnDestroySound",
}
Debug.Assert(ServerEnum.SkillCollisionParameterType.Count == #ServerEnum.SkillCollisionParameterType.Converter + 1, "비정상입니다.")


ServerEnum.SkillCollisionSequenceTrackParameterType.Converter = {
	[ServerEnum.SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] = "SkillCollisionDirection",
	[ServerEnum.SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed] = "SkillCollisionSpeed",
	[ServerEnum.SkillCollisionSequenceTrackParameterType.SkillCollisionSize] = "SkillCollisionSize",
	[ServerEnum.SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration] = "SkillCollisionSequenceTrackDuration",
	[ServerEnum.SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent] = "ListenSkillCollisionEvent",
}
Debug.Assert(ServerEnum.SkillCollisionSequenceTrackParameterType.Count == #ServerEnum.SkillCollisionSequenceTrackParameterType.Converter + 1, "비정상입니다.")


ServerEnum.__index = Utility.Inheritable__index
ServerEnum.__newindex = Utility.Inheritable__newindex
setmetatable(ServerEnum, CommonEnum)

return ServerEnum