--[[
mytable = {}
mymetatable = {value1 = 2}
setmetatable(mytable, mymetatable)

mymetatable1 = getmetatable(mytable)
mymetatable1.value1 = 3

mytable1 = setmetatable({},{})
--]]



























--table1.__index = function(table, key) return table[key] end
--table1.__index = table1



-- 메타테이블로 사용할 수 있는 테이블 정의 객체지향 관점에서 상속받아 사용할 수 있다.
table1 = { value1 = 1, value2 = 2, value3 = 3}
table1.__index = table1
--table1.__index = function(table, key) return table[key] end

--local temp = table1.__index
--print(table1.__index)

--local temp2 = table1
--local rv = temp2(table1, "value1")

table2 = setmetatable({ value4 = 4, value5 = 5}, table1)
table2.__index = table2

--print(table2.value1)



local a = 3
local b = 2