local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonObjectUtilityModule = CommonModule:WaitForChild("CommonObjectUtilityModule")

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local WorldInteractorType = CommonEnum.WorldInteractorType


local WorldInteractorUtility = Utility:DeepCopy(require(CommonObjectUtilityModule:WaitForChild("ObjectUtilityBase")))

function WorldInteractorUtility:Initialize()
	local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
	local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

	if not self:InitializeRaw(CommonGameDataManager, GameDataType.WorldInteractor) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

WorldInteractorUtility:Initialize()
return WorldInteractorUtility
