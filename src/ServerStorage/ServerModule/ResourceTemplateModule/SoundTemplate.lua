local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))


local SoundTemplate = {
    Value = {}
}


function SoundTemplate:Get(soundName)
    if not soundName then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.Value[soundName]
end

function SoundTemplate:ValidateSound(sound)
    return true
end

function SoundTemplate:LoadAllSoundFolders(soundFoldersParent)
    local allSoundFolders = soundFoldersParent:GetChildren()
    for _, soundsFolder in pairs(allSoundFolders) do
        local soundsFolderName = soundsFolder.Name
        if not self:InitializeAllSounds(soundsFolder) then
            Debug.Assert(false, "비정상입니다. => " .. soundsFolderName)
            return false
        end
    end

    return true
end

function SoundTemplate:InitializeAllSounds(soundsFolder)

    local allSounds = soundsFolder:GetChildren()
    for _, sound in pairs(allSounds) do
        local soundName = sound.Name
        self.Value[soundName] = sound

        if not self:ValidateSound(sound) then
            Debug.Assert(false, "비정상입니다. => " .. soundName)
            return false
        end
    end

    return true
end


return SoundTemplate