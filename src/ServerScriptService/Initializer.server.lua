local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeGameStateSTC = ReplicatedStorage:WaitForChild("ChangeGameStateSTC")


local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager

local GameStateType = ServerModuleFacade.CommonEnum.GameStateType
local GameDataType = ServerModuleFacade.ServerEnum.GameDataType

local ToolModule = ServerModuleFacade.ToolModule
local DamagerScript = ToolModule:WaitForChild("Damager")
local InteractorScript = ToolModule:WaitForChild("Interactor")

local Tools = ServerStorage:WaitForChild("Tools")


function testFunction()
	
	local Utility = ServerModuleFacade.Utility
	local array = Utility.DeepCopy(ServerModuleFacade.TArray)
	array:Initialize(30)
	array:Set(1,"Test")
	array:Set(30, "Foo")
	array:Set(15, "Bar")
	
	local temp1 = array:Get(30)
	local temp2 = array:Get(15)
	
	local list = Utility.DeepCopy(ServerModuleFacade.TList)
	list:Initialize(20)
	

	local temp3 = list:Get(5)
	for i = 1, 20 do
		list:Push("test" .. tostring(i))
	end
	
	local temp4 = list:Get(21)
	
	local temp5 = list:Pop(3)
	local temp6 = list:PopBack()
	
	for i = 1, list.CurrentCount do
		print(tostring(i) .. tostring(list:Get(i)))
	end
end

--testFunction()



--[[
-- 모듈스크립트 local 변수 테스트
local Utility = ServerModuleFacade.Utility
local CopyTest1 = Utility.DeepCopy(require(ToolModule:WaitForChild("CopyTest")))
local CopyTest2 = Utility.DeepCopy(require(ToolModule:WaitForChild("CopyTest")))

-- 모듈스트립트의 local 변수는 모듈 스크립트 사이에서 공유되는 값이 맞다
CopyTest2:Set(5)
CopyTest2:Print()
CopyTest1:Set(3)
CopyTest2:Print()

local CopyTestScript = (ToolModule:WaitForChild("CopyTestScript"))
local CopyTestScript1 = CopyTestScript:Clone()
local CopyTestScript2 = CopyTestScript:Clone()

-- 일반 스크립트는 local 변수까지 완벽하게 복사된다.
local part1 = Instance.new("Part")
part1.Name = "aaa"
part1.Parent = workspace
CopyTestScript1.Parent = part1

local part2 = Instance.new("Part")
part2.Name = "bbb"
part2.Parent = workspace
CopyTestScript2.Parent = part2
--]]


local function InitializeGlobal()

	
end

local function InitializeTools()
	local toolList = Tools:GetChildren()
	
	local toolCount = #toolList
	for i = 1, toolCount do
		if toolList[i].Damager then
			local clonedDamagerScript = DamagerScript:Clone()
			clonedDamagerScript.Parent = toolList[i]
			
		elseif toolList[i].Interactor then
			local clonedInteractorScript = InteractorScript:Clone()
			clonedInteractorScript.Parent = toolList[i]
			
		else
			ServerModuleFacade.Assert(false, "도구 용도에 맞게 태그를 지정하세요")
		end
	end
	
	local test = 1
end

local function InitializePlayers()
	
	game.Players.PlayerRemoving:Connect(function(player)
		ServerGlobalStorage:RemovePlayer(player)
	end)
	
	game.Players.PlayerAdded:Connect(function(player)
		ServerGlobalStorage:AddPlayer(player)
		
		local leaderstatsFolder = Instance.new("Folder")
		leaderstatsFolder.Name = "leaderstats"
		leaderstatsFolder.Parent = player

		local coins = Instance.new("IntValue")
		coins.Name = "Coins"
		coins.Value = 50
		coins.Parent = leaderstatsFolder
		
		player.CharacterRemoving:Connect(function(character)
			ServerGlobalStorage:ClearPlayer(player)
		end)
		
		-- 캐릭터가 추가되거나 리스폰된 경우 CharacterRemoving도 있음
		player.CharacterAdded:Connect(function(character)
			--ServerGlobalStorage:AddCharacter(character)
			
			local characterGameData = ServerGameDataManager[GameDataType.Character]:Get(1)
			if not characterGameData then
				Debug.Assert(false, "데이터가 존재하지 않습니다.")
			end
			ServerGlobalStorage:AddGameData(character, characterGameData)
			
			--[[
			local characterDataTable = Instance.new("ObjectValue")
			characterDataTable.Name = "CharacterDataTable"
			characterDataTable.Parent = character
			--]]
			
			character.Humanoid.Died:Connect(function()
				-- 죽었을 때
				if character:FindFirstChild("AliveTag")  then
					character.AliveTag:Destroy()
				end

				ChangeGameStateSTC:FireClient(player, GameStateType.Dead)


				--player:LoadCharacterBlocking()


				ChangeGameStateSTC:FireClient(player, GameStateType.WaitingForFinishing)
			end)
		end)
		
		ChangeGameStateSTC:FireClient(player, GameStateType.Waiting)
	end)
	
end

local function InitializeGame()
	
	--Debug.Assert(false, "test")
	InitializeTools()
	InitializePlayers()	
	
end

InitializeGame()


