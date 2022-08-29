local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage
local Debug = ClientModuleFacade.Debug
local Utility = ClientModuleFacade.Utility
local ToolUtility = ClientModuleFacade.ToolUtility

local CommonConstant = ClientModuleFacade.CommonConstant
local MaxSkillCount = CommonConstant.SkillCount

local CommonEnum = ClientModuleFacade.CommonEnum
local SlotType = CommonEnum.SlotType

local KeyBinder = ClientModuleFacade.KeyBinder

local player = game.Players.LocalPlayer
local playerId = player.UserId

local PlayerGui = player:WaitForChild("PlayerGui")
local GuiTemplate = PlayerGui:WaitForChild("GuiTemplate")
local GuiSlot = GuiTemplate:WaitForChild("GuiSlot")

local GuiPopupWindowControllers = PlayerGui:WaitForChild("GuiPopupWindowControllers")
local GuiTooltipController = require(GuiPopupWindowControllers:WaitForChild("GuiTooltipController"))

local RunService = game:GetService("RunService")

local GuiSlotController = Utility:DeepCopy(require(script.Parent:WaitForChild("GuiSlotController")))

local GuiSkillSlotController = GuiSlotController

function GuiSkillSlotController:new(slotIndex, newGuiSlot)
	local newGuiSkillSlotController = self:newRaw(SlotType.SkillSlot, slotIndex, newGuiSlot)
	
	newGuiSkillSlotController.GuiSlot.MouseEnter:connect(function(x,y)
		newGuiSkillSlotController.GuiSlot.ImageTransparency = 0.5
	end)
	
	newGuiSkillSlotController.GuiSlot.MouseLeave:connect(function()
		newGuiSkillSlotController.GuiSlot.ImageTransparency = 0
	end)

	-- 추가 쿨타임 표시 텍스트
	local skillCooldownTimeText = Instance.new("TextLabel")
    skillCooldownTimeText.AnchorPoint = Vector2.new(0.5, 0.5)
	skillCooldownTimeText.Position = UDim2.new(0.5, 0, 0.5, 0)
	skillCooldownTimeText.Size = UDim2.new(0.6, 0, 0.6, 0)
	skillCooldownTimeText.TextScaled = true
	skillCooldownTimeText.TextColor3 = Color3.new(1, 0.1, 0.1) 
	skillCooldownTimeText.BackgroundTransparency = 1
	skillCooldownTimeText.Visible = false
	skillCooldownTimeText.Parent = newGuiSkillSlotController.GuiSlot.GuiImage
	newGuiSkillSlotController.GuiSkillCooldown = skillCooldownTimeText

	-- 기존 StackCount로 사용하던 Number 위치 변경(바인딩된 키를 보여주도록 설정)
	newGuiSkillSlotController.GuiSlot.GuiImage.GuiNumber.Size =  UDim2.new(0.3, 0, 0.3, 0)
	newGuiSkillSlotController.GuiSlot.GuiImage.GuiNumber.Position =  UDim2.new(0, 0, 0, 0)

	local targetSlotIndexEnum = ToolUtility.SkillSlotIndexToKeyCodeTable[newGuiSkillSlotController.SlotIndex]
	if not targetSlotIndexEnum then
		Debug.Assert(false, "비정상입니다. 슬롯이 늘어났는지 확인해보세요")
		return
	end

	local skillSlotActionName = tostring(targetSlotIndexEnum)
	newGuiSkillSlotController.SkillKeyName = string.sub(skillSlotActionName, -1)

	KeyBinder:BindAction(Enum.UserInputState.Begin, targetSlotIndexEnum, skillSlotActionName, function(inputObject)
		if not newGuiSkillSlotController:ActivateSkill() then
			Debug.Assert(false, "비정상입니다.")
			return
		end
	end)

	newGuiSkillSlotController.GuiSlot.Activated:Connect(function(inputObject)
		if not newGuiSkillSlotController:ActivateSkill() then
			Debug.Assert(false, "비정상입니다.")
			return
		end
	end)

	newGuiSkillSlotController:ClearSkillData()
	return newGuiSkillSlotController
end

function GuiSkillSlotController:ClearSkillData()
	self:ClearData()
	self.SkillOwnerTool = nil
	self.SkillGameData = nil

	self.SkillLastActivationTime = nil
	self.RemainingSkillCooldown = nil

	self:ClearCalculateCooldownConnection()
	self:SetVisible(false)
end

function GuiSkillSlotController:ClearCalculateCooldownConnection()
	if self.CalculateCooldownConnection then
		self.CalculateCooldownConnection:Disconnect()
		self.CalculateCooldownConnection = nil
		self.GuiSkillCooldown.Visible = false
	end
end

function GuiSkillSlotController:IsValid()
	return nil ~= self.SkillOwnerTool
end

function GuiSkillSlotController:ActivateSkill()
	-- 비활성화된 스킬 컨트롤러인지 검증
	if not self:IsValid() then
		return true
	end

	if 0 < self.RemainingSkillCooldown then
		Debug.Print(tostring("스킬 쿨타임이 " .. self.RemainingSkillCooldown) .. " 초 남았습니다.")
		return true
	end

	local skillIndex = self:GetSlotIndex()
	if not skillIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self.SkillOwnerTool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not ClientGlobalStorage:SendActivateToolSkill(self.SkillOwnerTool, skillIndex) then
		Debug.Assert(false, "스킬 사용에 실패했습니다.")
		return false
	end

	return true
end

function GuiSkillSlotController:GetSkillGameDataKey()
	if not self.SkillGameData then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return self.SkillGameData:GetKey()
end

function GuiSkillSlotController:SetSkill(skillOwnerTool, skillGameData)
	if not skillOwnerTool then
		self:ClearSkillData()
		return true
	end

	if not skillGameData then
		Debug.Assert(false, "스킬 정보 초기화에 실패했습니다.")
		self:ClearSkillData()
		return false
	end

	if self:IsValid() then
		self:ClearSkillData()
	end

	self.SkillOwnerTool = skillOwnerTool
	self.SkillGameData = skillGameData

	self:SetImage(skillGameData.Image)
	self:SetName(skillGameData.Name)
	self:SetNumber(self.SkillKeyName)

	self.SkillLastActivationTime = ClientGlobalStorage:GetSkillLastActivationTime(playerId, skillGameData:GetKey())
	if not self.SkillLastActivationTime then
		self.RemainingSkillCooldown = 0
	else
		if not self:RefreshByLastActivationTime(self.SkillLastActivationTime) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end
	end

	self:SetVisible(true)
	return true
end

function GuiSkillSlotController:CalculateCooldown(deltaTime)
	self.RemainingSkillCooldown -= deltaTime

	local cooldownText = tostring(math.floor(self.RemainingSkillCooldown))
	self.GuiSkillCooldown.Text = cooldownText
	if 0 >= self.RemainingSkillCooldown then
		self:ClearCalculateCooldownConnection()
		Debug.Print("Disconnected")
	end
end

function GuiSkillSlotController:RefreshByLastActivationTime(lastActivationTime)
	if not self:IsValid() then
		Debug.Assert(false, "원인을 파악해야 합니다. 코드 버그일 가능성이 높습니다.")
		return false
	end

	self.SkillLastActivationTime = lastActivationTime
	if not self.SkillLastActivationTime then
		self.RemainingSkillCooldown = 0
	else
		local elapsedTime = os.clock() - self.SkillLastActivationTime
		self.RemainingSkillCooldown = self.SkillGameData.Cooldown - elapsedTime
		self.RemainingSkillCooldown = math.max(0, self.RemainingSkillCooldown)
	end

	if 0 < self.RemainingSkillCooldown then
		-- Heartbeat 델리게이트에 바인딩하여 타이머 실행
		self:ClearCalculateCooldownConnection()

		self.GuiSkillCooldown.Visible = true
		self.CalculateCooldownConnection = RunService.Heartbeat:Connect(function(deltaTime)
			self:CalculateCooldown(deltaTime)
		end)
	end

	return true
end


return GuiSkillSlotController