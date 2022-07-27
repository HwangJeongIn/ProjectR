local function GetValueByKey(table, key)
	
if table[key] then return table[key] end
	
	-- 메타테이블에서 추가로 찾아본다.	
	local metatable = getmetatable(table)
	
	if not metatable or not metatable.__index then return nil end
	
	return metatable.__index(key)
	
end

local table1 = {
	value1 = 1,
	value2 = 2,
	value3 = 3,
	print = function() print("print function in table1") end,
	printValue = function(value) print("printValue function in table1 => " .. tostring(value)) end
}

--table1.__index = table1

--[[
table1.__index = function(table, key) 
	return table[key] 
end
--]]

local table2 = setmetatable({
	value4 = 4,
	value5 = 5}, table1)

local metatableOftable2 = getmetatable(table2)
--local rv = metatableOftable2.__index.value1
local rv2 = table2["value1"]


--local table3 = {}
--local metatableOftable3 = getmetatable(table3)

GetValueByKey(table2, "value1")


--table2.print()
--table2.printValue()




local a = 3
local b = 2