-- 인스턴스로 만들 때 독립적인 인스턴스를 CDO에서 복사하여 생성하여야 한다.

-- local ClassBaseInstance = setmetatable({}, ClassBase)

--local AccessType = {P1 = 1, P2 = 2, P3 = 3}

--[[
local __indexFunction = function(table, key)
	print("table =>")
	print(table)
	local matetable = getmetatable(table)
	print("matetable =>")
	print(matetable)
	
	local rv = rawget(matetable.public, key)
	
	if rv then
		return rv
	end
	
	return matetable[key]
end

local test1 = {public = {v1 = 1}}
test1.__index = __indexFunction
local test2 = setmetatable({public = {v2 = 2}}, test1)
test2.__index = __indexFunction
local test3 = setmetatable({public = {v3 = 3}}, test2)
test3.__index = __indexFunction

local v1Value = test3.v1
local fdnskalf

--]]

--[[


local ClassBase = require(script.ClassBase)


-- SuperClass 구현

local SuperClassCDO = {
	
	public = {
		value1 = 1,
		GetClassTypeForInstance = function() return "SuperClass" end
	},
	private = {
		value2 = 2}
}

SuperClassCDO.__index = ClassBase.__index
SuperClassCDO.__newindex = ClassBase.__newindex


local temp3 = getmetatable(SuperClassCDO)

local a  =2

-- 상속 받은 다른 클래스에서 접근 지정자에 따라 접근할 수 있도록 해준다.

function SuperClassCDO.Clone()
	
	local baseCopy = SuperClassCDO:DeepCopy(SuperClassCDO)
	return setmetatable({}, baseCopy)
	
end

function SuperClassCDO.public:GetPrivateValue2()
	
	return SuperClassCDO.private.value2
	
end


function SuperClassCDO.public:PrintBase()

	local this = self:GetThisByCDO(SuperClassCDO)
	
	print("SuperClassCDO.public:PrintBase() => ")
	print(this.public.value1)
	print(this.private.value2)
	
end

-- 마지막에 연결해야한다.
setmetatable(SuperClassCDO, ClassBase.public:DeepCopy(ClassBase))
SuperClassCDO.SetType(SuperClassCDO, "SuperClass")

-- SubClass 구현

local SubClassCDO = {

	public = {
		value3 = 3,
		GetClassTypeForInstance = function() return "SubClass" end
	},
	private = {
		value4 = 4
	}
}


local temp1 = getmetatable(SubClassCDO)
local temp2 = getmetatable(temp1)

SubClassCDO.__index = ClassBase.__index
SubClassCDO.__newindex = ClassBase.__newindex




function SubClassCDO.Clone()

	local derivedCopy = SubClassCDO:DeepCopy(SubClassCDO)
	return setmetatable({}, derivedCopy)

end

function SubClassCDO.public:PrintDerived()
	
	local this = self:GetThisByCDO(SubClassCDO)
	
	print("SubClassCDO.public:PrintDerived() =>")
	print(this.public.value3)
	print(this.private.value4)
	
	this.private.PrintPrivateDerived(self)
	this:PrintBase(self)
	
end


function SubClassCDO.private:PrintPrivateDerived()

	local this = self:GetThisByCDO(SubClassCDO)

	print("SubClassCDO.private:PrintPrivateDerived() =>")

end

-- 마지막에 연결해야한다.
setmetatable(SubClassCDO, SuperClassCDO:DeepCopy(SuperClassCDO))
SubClassCDO:SetType("SubClass")


local SubClassObject = SubClassCDO.Clone()
SubClassObject.PrintDerived(SubClassObject)

-- SuperClass에 있는 함수
SubClassObject.PrintBase(SubClassObject)
local a = SubClassObject:GetPrivateValue2()


local b = 2

--]]