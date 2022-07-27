local Debug = {}

Debug.__index = function(table, key)
	local metatable = getmetatable(table)
	return metatable[key]
end

--local RedColor = Color3.new(255,0,0)
function Debug.Assert(expression, message)
	if not expression then
		if type(message) ~= "string" then
			message = tostring(message)
		end
		
		warn("Assert => " .. message .. "\nCallStack => " .. tostring(debug.traceback()))
		--printWithColor(RedColor, true, output)
	end
end

function Debug.Log(message)
	if type(message) ~= "string" then
		message = tostring(message)
	end
	warn("Log => " .. message .. "\nCallStack => " .. tostring(debug.traceback()))
end

function Debug.Print(message)
	if type(message) ~= "string" then
		message = tostring(message)
	end
	warn("Print => " .. message)
end

return Debug
