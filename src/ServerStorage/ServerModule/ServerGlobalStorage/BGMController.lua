--local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug


local FadeTime = 5
local MaxBGMVolume = 1.0

local BGMTemplate = require(script.Parent:WaitForChild("BGMTemplate"))


local BGMController = {
    PrevMapType = nil,
    CurrentMapType = nil,
    BGMPlaylist = {

    }
}

function BGMController:ClearUpdateFadeInFadeOutConnection()
	if self.UpdateFadeInFadeOutConnection then
		self.UpdateFadeInFadeOutConnection:Disconnect()
        if self.PrevMapType and self.BGMPlaylist[self.PrevMapType] then
            if self.BGMPlaylist[self.PrevMapType].Playing then
                self.BGMPlaylist[self.PrevMapType]:Stop()
            end
        end
        
        if self.BGMPlaylist[self.CurrentMapType] then
            self.BGMPlaylist[self.CurrentMapType].Volume = MaxBGMVolume
        end
	end
end

function BGMController:UpdateFadeInFadeOut(deltaTime)
    local deltaVolume = MaxBGMVolume * (deltaTime / FadeTime)

    local finished = true
    if self.PrevMapType and self.BGMPlaylist[self.PrevMapType] then
        if self.BGMPlaylist[self.PrevMapType].Playing then
            local fadeOutVolume = math.max(0, self.BGMPlaylist[self.PrevMapType].Volume - deltaVolume)
            if 0 < fadeOutVolume then
                self.BGMPlaylist[self.PrevMapType].Volume = fadeOutVolume
                finished = false
            else
                self.BGMPlaylist[self.PrevMapType]:Stop()
            end
        end
    end

    if self.BGMPlaylist[self.CurrentMapType] then
        local fadeInVolume = math.min(MaxBGMVolume, self.BGMPlaylist[self.CurrentMapType].Volume + deltaVolume)
        if MaxBGMVolume > fadeInVolume then
            finished = false
        end
        self.BGMPlaylist[self.CurrentMapType].Volume = fadeInVolume
    end

    if finished then
		self:ClearUpdateFadeInFadeOutConnection()
    end
end

function BGMController:StopAndPlayByMapType(mapType, fadeInFadeOut)
    if not mapType then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    self:ClearUpdateFadeInFadeOutConnection()

    self.PrevMapType = self.CurrentMapType
    self.CurrentMapType = mapType

    if not self.BGMPlaylist[self.CurrentMapType] then
        local targetBGM = BGMTemplate:GetBGMByMapType(mapType)
        if targetBGM then
            self.BGMPlaylist[self.CurrentMapType] = targetBGM:Clone()
            self.BGMPlaylist[self.CurrentMapType].Parent = workspace
        end
    end

    if not fadeInFadeOut then
        if self.PrevMapType and self.BGMPlaylist[self.PrevMapType] then
            self.BGMPlaylist[self.PrevMapType]:Stop()
        end

        if self.BGMPlaylist[self.CurrentMapType] then
            self.BGMPlaylist[self.PrevMapType].Volume = MaxBGMVolume
            self.BGMPlaylist[self.CurrentMapType]:Play()
        end
    else
        local updateFlag = false
        if self.PrevMapType and self.BGMPlaylist[self.PrevMapType] then
            self.BGMPlaylist[self.PrevMapType].Volume = MaxBGMVolume
            updateFlag = true
        end

        if self.BGMPlaylist[self.CurrentMapType] then
            self.BGMPlaylist[self.CurrentMapType].Volume = 0
            self.BGMPlaylist[self.CurrentMapType]:Play()
            updateFlag = true
        end

        if updateFlag then
            self.UpdateFadeInFadeOutConnection = RunService.Heartbeat:Connect(function(deltaTime)
                self:UpdateFadeInFadeOut(deltaTime)
            end)
        end
    end

    return true
end



return BGMController
