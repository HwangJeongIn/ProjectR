
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage
local Debug = ClientModuleFacade.Debug
local KeyBinder = ClientModuleFacade.KeyBinder


local CommonEnum = ClientModuleFacade.CommonEnum
local SlotType = CommonEnum.SlotType
local SlotTypeConverter = SlotType.Converter

local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

local GuiDraggingSystem = {
    SlotControllerCandidate = nil,
    SlotController = nil,
    ShadowImage = nil
}

-- 더 정리할 필요있음
function OnInputBegan(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then

        if not GuiDraggingSystem.SlotControllerCandidate then 
            Debug.Print("후보가 없습니다.")
            return
        end
        
        if not GuiDraggingSystem:SetSlotController(GuiDraggingSystem.SlotControllerCandidate) then
            Debug.Assert(false, "비정상입니다.")
            return
        end

        GuiDraggingSystem.UpdatingMousePosition = RunService.RenderStepped:Connect(function(deltaTime)
            if not GuiDraggingSystem.SlotController then
                Debug.Assert(false, "비정상입니다.")
                return
            end
    
            GuiDraggingSystem:UpdatePosition(Mouse.X, Mouse.Y)
        end)
        
        -- 같은 슬롯을 클릭하고 다른 곳으로 드래그하면 문제가 발생해서 주석 처리
        --GuiDraggingSystem:SetSlotControllerCandidate(nil)
	end
end

function OnInputEnded(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then

        if GuiDraggingSystem.UpdatingMousePosition then
            GuiDraggingSystem.UpdatingMousePosition:Disconnect()
            GuiDraggingSystem.UpdatingMousePosition = nil
        end

        if not GuiDraggingSystem.SlotController then
            GuiDraggingSystem:ClearSlotController()
            Debug.Print("처음에 선택한 위치에 슬롯이 없습니다.")
            return
        end

        if not GuiDraggingSystem.SlotControllerCandidate then
            GuiDraggingSystem:ClearSlotController()
            Debug.Print("마지막 위치에 슬롯이 없습니다.")
            return
        end


        local prevSlotType = GuiDraggingSystem.SlotController.SlotType
        local prevSlotIndex = GuiDraggingSystem.SlotController.SlotIndex

        local currentSlotType = GuiDraggingSystem.SlotControllerCandidate.SlotType
        local currentSlotIndex = GuiDraggingSystem.SlotControllerCandidate.SlotIndex

        print("Swap Slot => ")
        print("From => ".. SlotTypeConverter[prevSlotType] .. " : " .. tostring(prevSlotIndex))
        print("To => ".. SlotTypeConverter[currentSlotType] .. " : " .. tostring(currentSlotIndex))
    
        if prevSlotType == SlotType.InventorySlot then
            if currentSlotType == SlotType.InventorySlot then
                if prevSlotIndex ~= currentSlotIndex then
                    if not ClientGlobalStorage:SendSwapInventorySlot(prevSlotIndex, currentSlotIndex) then
                        Debug.Assert(false, "비정상입니다.")
                    end
                end
            elseif currentSlotType == SlotType.QuickSlot then
				if not ClientGlobalStorage:SetQuickSlotByInventorySlot(currentSlotIndex, prevSlotIndex) then
                    Debug.Assert(false, "비정상입니다.")
                end
            end 
        elseif prevSlotType == SlotType.QuickSlot then
            if currentSlotType == SlotType.QuickSlot then
                if prevSlotIndex ~= currentSlotIndex then
                    if not ClientGlobalStorage:SwapQuickSlot(prevSlotIndex, currentSlotIndex) then
                        Debug.Assert(false, "비정상입니다.")
                    end
                end
            end
        elseif prevSlotType == SlotType.SkillSlot then

        end
        





        GuiDraggingSystem:ClearSlotController()
	end
end

UserInputService.InputBegan:Connect(OnInputBegan)
UserInputService.InputEnded:Connect(OnInputEnded)


function GuiDraggingSystem:Initialize()
    self.Shadow = Instance.new("ScreenGui")
    self.Shadow.Name = "Shadow"

    self.ShadowImage = Instance.new("ImageLabel")
    self.ShadowImage.Name = "ShadowImage"

    self.ShadowImage.BackgroundTransparency = 1
	self.ShadowImage.AnchorPoint = Vector2.new(0.5, 0.5)
    self.ShadowImage.ImageTransparency = 0.75
	self.ShadowImage.Size = UDim2.new(0, 100, 0, 100)
    self.ShadowImage.Position = UDim2.new(0.5, 0, 0.5, 0)

    self.ShadowImage.Image = ""
    
    self.Shadow.Parent = PlayerGui
    self.ShadowImage.Parent = self.Shadow
    self:ClearSlotController()
end

function GuiDraggingSystem:Clear()
    self:SetSlotControllerCandidate(nil)
end

function GuiDraggingSystem:SetSlotControllerCandidate(slotControllerCandidate)
    self.SlotControllerCandidate = slotControllerCandidate
end

function GuiDraggingSystem:ClearSlotController()
    self.SlotController = nil
    self.ShadowImage.Image = ""
    self.Shadow.Enabled = false
end

function GuiDraggingSystem:SetShadowImage(targetImage)
    if not targetImage then
        Debug.Assert(false, "비정상입니다.")
        return false
    end
    
    if targetImage.Image then    
        local targetImageSize = UDim2.new(0, targetImage.AbsoluteSize.X, 0, targetImage.AbsoluteSize.Y)
        self.ShadowImage.Size = targetImageSize
        self.ShadowImage.Image = targetImage.Image

        local targetImagePosition = UDim2.new(0, targetImage.AbsolutePosition.X, 0, targetImage.AbsolutePosition.Y)
        self.ShadowImage.Position = targetImagePosition
        self.Shadow.Enabled = true
    end
    return true
end

function GuiDraggingSystem:SetSlotController(slotController)
    if not slotController then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    self.SlotController = slotController
    if not self:SetShadowImage(slotController:GetImage()) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end
    
    return true
end

function GuiDraggingSystem:UpdatePosition(x, y)
    if self.Shadow.Enabled then
        --print(tostring(x) .. " , " .. tostring(y))
        self.ShadowImage.Position = UDim2.new(0, x, 0, y)
    end
end

GuiDraggingSystem:Initialize()
return GuiDraggingSystem