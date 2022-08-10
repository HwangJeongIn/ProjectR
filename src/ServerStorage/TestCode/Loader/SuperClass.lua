local root = script.Parent

local ClassBase = require(root.ClassBase)

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
	print("SuperClassCDO.public:PrintBase() => " .. tostring(this.public.value1) .. tostring(this.private.value2))

end

-- 같은 이름의 함수를 허용하려면 이 위로 정의한다.

setmetatable(SuperClassCDO, ClassBase.public:DeepCopy(ClassBase))
SuperClassCDO.SetType(SuperClassCDO, "SuperClass")

-- 같은 이름의 함수를 완전히 덮어쓰려면 이 아래에 정의한다. -- 오버라이딩과 비슷하게 동작한다.


return SuperClassCDO