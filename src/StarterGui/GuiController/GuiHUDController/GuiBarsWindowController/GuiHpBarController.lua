local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage
local Debug = ClientModuleFacade.Debug
--[[
local Utility = ClientModuleFacade.Utility
local ToolUtility = ClientModuleFacade.ToolUtility

local CommonConstant = ClientModuleFacade.CommonConstant
local CommonEnum = ClientModuleFacade.CommonEnum
--]]

local GuiHpBarController = {}

function GuiHpBarController:Initialize()

    local LocalPlayer = game.Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

    LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character.Humanoid

        humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
            local maxHealth = humanoid.MaxHealth
            self:SetMaxHp(maxHealth)
        end)
    
        character.Humanoid.HealthChanged:Connect(function(health)
            self:SetCurrentHp(health)
        end)
    end)
    
    self.GuiHpBar = GuiFacade.GuiHpBar
    --[[
    self.MaxHpBarSize = self.GuiHpBar.Size
    if 0 ~= self.MaxHpBarSize.X.Offset or 0 ~= self.MaxHpBarSize.Y.Offset then
        Debug.Assert(false, "비정상입니다. Offset을 0으로 맞춰주세요.")
        return false
    end
    --]]

    return true
end

function GuiHpBarController:Recalculate()
    local percent = self.CurrentHp / self.MaxHp
	--self.GuiHpBar.Size = UDim2.new(self.MaxHpBarSize.X.Scale * percent, 0, self.MaxHpBarSize.Y.Scale, 0)
	self.GuiHpBar.Size = UDim2.new(percent, 0, 1, 0)

    if percent < 0.2 then
		self.GuiHpBar.BackgroundColor3 = Color3.new(1, 0, 0) -- black
	elseif percent < 0.5 then
		self.GuiHpBar.BackgroundColor3 = Color3.new(1, 1, 0) -- yellow
	else
		self.GuiHpBar.BackgroundColor3 = Color3.new(0, 1, 0) -- green
	end
end


function GuiHpBarController:SetMaxHp(value)
    self.MaxHp = value
    self:Recalculate()
end

function GuiHpBarController:SetCurrentHp(value)
    self.CurrentHp = value
    self:Recalculate()
end


GuiHpBarController:Initialize()
return GuiHpBarController
