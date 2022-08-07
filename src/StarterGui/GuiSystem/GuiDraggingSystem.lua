local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage
local Debug = ClientModuleFacade.Debug
local GameStateType = ClientModuleFacade.CommonEnum.GameStateType
local WinnerType = ClientModuleFacade.CommonEnum.WinnerType

local KeyBinder = ClientModuleFacade.KeyBinder


local GuiDraggingSystem = {
    TargetSlotController = nil,
    TargetShadowImage = nil
}

function GuiDraggingSystem:Initialize()

end



function GuiDraggingSystem:SetSlotController(targetSlotController)
    if not targetSlotController then
        Debug.Asssert(false, "비정상입니다.")
        return false
    end

end


return GuiDraggingSystem