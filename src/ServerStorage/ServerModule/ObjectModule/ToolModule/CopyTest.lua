local module = {b = 1}

local a = 0

function module:Set(input)
	
	a = input
	self.b = input
end

function module:Print()

	print("a => " .. tostring(a))
	print("b => " .. tostring(self.b))
	
end

return module
