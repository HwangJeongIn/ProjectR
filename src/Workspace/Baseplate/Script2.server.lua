Window = {}
WindowBase = {x=0, y=0, width=50, height=70,}

function Window.new (o)
	setmetatable(o, WindowBase)
	return o
end

WindowBase.__index = function (table, key, input)
	local a = 3
	local b = 2
	local metatable = getmetatable(table)
	print("table : " .. tostring(table))
	print(table)
	print("key : " .. tostring(key))
	print("input : " .. tostring(input))
	return metatable[key]
end

w = Window.new{x=10, y=20}
w2 = Window.new{x=10, y=20}
--[[

print(tostring(w))
print(tostring(w2))


--local test = WindowBase.__index.width

print("w : " .. tostring(w))
print(w.width)
print(w.height)
print(w.x)

--]]