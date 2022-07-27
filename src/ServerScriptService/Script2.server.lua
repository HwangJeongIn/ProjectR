local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage



function TestFunction()

	task.desynchronize()

	debug.profilebegin("Start!")
	for i = 1, 1000000 do
		ServerStorage.a = 1
	end
	debug.profileend()

	task.synchronize()
	for i = 1, 10000000 do
		ServerStorage.a = 2
	end

end



while wait(0.1) do
	TestFunction()
end