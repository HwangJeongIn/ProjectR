local GuiFacade = {}

function GuiFacade:Initialize()
    local player = game.Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")
    
    -- HUD
    local GuiHUD = PlayerGui:WaitForChild("GuiHUD")
    
    local GuiPlayerMain = GuiHUD:WaitForChild("GuiPlayerMain")
    local GuiMinimap = GuiHUD:WaitForChild("GuiMinimap")
    
    local GuiBarsWindow = GuiPlayerMain:WaitForChild("GuiBarsWindow")
    local GuiSlotsWindow = GuiPlayerMain:WaitForChild("GuiSlotsWindow")
    
    local GuiHpBar = GuiBarsWindow:WaitForChild("GuiHpBar")
    
    local GuiQuickSlots = GuiSlotsWindow:WaitForChild("GuiQuickSlots")
    local GuiSkillSlots = GuiSlotsWindow:WaitForChild("GuiSkillSlots")

    self.GuiHUD = GuiHUD
    self.GuiPlayerMain = GuiPlayerMain
    self.GuiMinimap = GuiMinimap
    self.GuiBarsWindow = GuiBarsWindow
    self.GuiSlotsWindow = GuiSlotsWindow
    self.GuiHpBar = GuiHpBar
    self.GuiQuickSlots = GuiQuickSlots
    self.GuiSkillSlots = GuiSkillSlots

    -- PlayerStatus
    local GuiPlayerStatus = PlayerGui:WaitForChild("GuiPlayerStatus")
    local GuiPlayerStatusWindow = GuiPlayerStatus:WaitForChild("GuiPlayerStatusWindow")
    local GuiEquipSlots = GuiPlayerStatusWindow:WaitForChild("GuiEquipSlots")
    local GuiInventory = GuiPlayerStatusWindow:WaitForChild("GuiInventory")
    
    local GuiTemplate = PlayerGui:WaitForChild("GuiTemplate")
    local GuiToolSlotTemplate = GuiTemplate:WaitForChild("GuiToolSlot")

    self.GuiPlayerStatus = GuiPlayerStatus
    self.GuiPlayerStatusWindow = GuiPlayerStatusWindow
    self.GuiEquipSlots = GuiEquipSlots
    self.GuiInventory = GuiInventory
    self.GuiTemplate = GuiTemplate
    self.GuiToolSlotTemplate = GuiToolSlotTemplate
end

GuiFacade:Initialize()
return GuiFacade