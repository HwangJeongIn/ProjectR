local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModule = StarterPlayerScripts:WaitForChild("ClientModule")

require(ClientModule:WaitForChild("KeyBinder"))
require(ClientModule:WaitForChild("ClientGlobalStorage"))
