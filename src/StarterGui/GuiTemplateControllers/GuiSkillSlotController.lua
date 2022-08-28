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
	self.RemainingCooldownTime = nil

	self:ClearCalculateCooldownConnection()
	self:SetVisible(false)
end

function GuiSkillSlotController:ClearCalculateCooldownConnection()
	if self.CalculateCooldownConnection then
		self.CalculateCooldownConnection:Disconnect()
		self.CalculateCooldownConnection = nil
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

	if 0 < self.RemainingCooldownTime then
		Debug.Print(tostring("스킬 쿨타임이 " .. self.RemainingCooldownTime) .. " 초 남았습니다.")
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
		self.RemainingCooldownTime = 0
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
	self.RemainingCooldownTime -= deltaTime

	if 0 >= self.RemainingCooldownTime then
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
		self.RemainingCooldownTime = 0
	else
		local elapsedTime = os.clock() - self.SkillLastActivationTime
		self.RemainingCooldownTime = self.SkillGameData.Cooldown - elapsedTime
		self.RemainingCooldownTime = math.max(0, self.RemainingCooldownTime)
	end

	if 0 < self.RemainingCooldownTime then
		-- Heartbeat 델리게이트에 바인딩하여 타이머 실행
		self:ClearCalculateCooldownConnection()
		self.CalculateCooldownConnection = RunService.Heartbeat:Connect(function(deltaTime)
			self:CalculateCooldown(deltaTime)
		end)
	end

	return true
end


return GuiSkillSlotController