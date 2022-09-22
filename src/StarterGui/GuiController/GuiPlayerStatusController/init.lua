local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))
local Debug = ClientModuleFacade.Debug


local GuiPlayerStatusController = {}

function GuiPlayerStatusController:Initialize()
	self.GuiEquipSlotsController = require(script:WaitForChild("GuiEquipSlotsController"))
	self.GuiInventoryController = require(script:WaitForChild("GuiInventoryController"))
end

function GuiPlayerStatusController:SetInventoryToolSlot(slotIndex, tool)
	if not self.GuiInventoryController:SetToolSlot(slotIndex, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function GuiPlayerStatusController:SetEquipToolSlot(equipType, tool)
	if not self.GuiEquipSlotsController:SetToolSlot(equipType, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end


GuiPlayerStatusController:Initialize()
return GuiPlayerStatusController
