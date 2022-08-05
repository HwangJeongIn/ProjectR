local GuiFacade = {}

function GuiFacade:Initialize()
    local player = game.Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")
    
    -- GUiTemplate
    local GuiTemplate = PlayerGui:WaitForChild("GuiTemplate")
    local GuiToolSlotTemplate = GuiTemplate:WaitForChild("GuiToolSlot")

    -- GuiHUD
    local GuiHUD = PlayerGui:WaitForChild("GuiHUD")
    
    local GuiHUDTop = GuiHUD:WaitForChild("GuiHUDTop")
    local GuiHUDTopWindow = GuiHUDTop:WaitForChild("GuiHUDTopWindow")

    local GuiGameStateWindow = GuiHUDTopWindow:WaitForChild("GuiGameStateWindow")
    local GuiBoardWindow = GuiGameStateWindow:WaitForChild("GuiBoardWindow")
    local GuiBarsWindow = GuiGameStateWindow:WaitForChild("GuiBarsWindow")
    local GuiHpBar = GuiBarsWindow:WaitForChild("GuiHpBar")

    local GuiMinimap = GuiHUDTopWindow:WaitForChild("GuiMinimap")
    
    self.GuiHUD = GuiHUD
    self.GuiHUDTop = GuiHUDTop
    --self.GuiHUDTopWindow = GuiHUDTopWindow
    self.GuiGameStateWindow = GuiGameStateWindow
    self.GuiBoardWindow = GuiBoardWindow
    self.GuiBarsWindow = GuiBarsWindow
    self.GuiHpBar = GuiHpBar
    self.GuiMinimap = GuiMinimap

    local GuiHUDBottom = GuiHUD:WaitForChild("GuiHUDBottom")
    local GuiHUDBottomWindow = GuiHUDBottom:WaitForChild("GuiHUDBottomWindow")
    
    local GuiQuickSlots = GuiHUDBottomWindow:WaitForChild("GuiQuickSlots")
    local GuiSkillSlots = GuiHUDBottomWindow:WaitForChild("GuiSkillSlots")

    self.GuiHUDBottom = GuiHUDBottom
    --self.GuiHUDBottomWindow = GuiHUDBottomWindow
    self.GuiQuickSlots = GuiQuickSlots
    self.GuiSkillSlots = GuiSkillSlots


    -- GuiPlayerStatus
    local GuiPlayerStatus = PlayerGui:WaitForChild("GuiPlayerStatus")
    local GuiPlayerStatusWindow = GuiPlayerStatus:WaitForChild("GuiPlayerStatusWindow")
    local GuiEquipSlots = GuiPlayerStatusWindow:WaitForChild("GuiEquipSlots")
    local GuiInventory = GuiPlayerStatusWindow:WaitForChild("GuiInventory")

    self.GuiPlayerStatus = GuiPlayerStatus
    self.GuiPlayerStatusWindow = GuiPlayerStatusWindow
    self.GuiEquipSlots = GuiEquipSlots
    self.GuiInventory = GuiInventory
    self.GuiTemplate = {
        GuiToolSlot = GuiToolSlotTemplate
    }
    
    -- GuiTooltip
    local GuiTooltip = PlayerGui:WaitForChild("GuiTooltip")
    local GuiTooltipWindow = GuiTooltip:WaitForChild("GuiTooltipWindow")

    self.GuiTooltip = GuiTooltip
    self.GuiTooltipWindow = GuiTooltipWindow

    -- GuiTemplateControllers
    local GuiTemplateControllers = PlayerGui:WaitForChild("GuiTemplateControllers")
    local GuiToolSlotController = require(GuiTemplateControllers:WaitForChild("GuiToolSlotController"))
    self.GuiTemplateController = {
        GuiToolSlotController = GuiToolSlotController
    }

    -- GuiPopupWindowControllers
    local GuiPopupWindowControllers = PlayerGui:WaitForChild("GuiPopupWindowControllers")
    local GuiTooltipController = require(GuiPopupWindowControllers:WaitForChild("GuiTooltipController"))
    self.GuiTooltipController = GuiTooltipController

end

GuiFacade:Initialize()
return GuiFacade