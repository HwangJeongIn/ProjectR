local root = script.Parent

local SuperClassCDO = require(root.SuperClass)

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


SubClassCDO.__index = SuperClassCDO.__index
SubClassCDO.__newindex = SuperClassCDO.__newindex


function SubClassCDO.Clone()

	local derivedCopy = SubClassCDO:DeepCopy(SubClassCDO)
	return setmetatable({}, derivedCopy)

end

function SubClassCDO.public:PrintDerived()

	local this = self:GetThisByCDO(SubClassCDO)

	print("SubClassCDO.public:PrintDerived() => " .. tostring(this.public.value3) .. tostring(this.private.value4))

	this.private.PrintPrivateDerived(self)
	this:PrintBase(self)

end


function SubClassCDO.private:PrintPrivateDerived()

	local this = self:GetThisByCDO(SubClassCDO)

	print("SubClassCDO.private:PrintPrivateDerived() =>")

end

-- 같은 이름의 함수를 허용하려면 이 위로 정의한다.

setmetatable(SubClassCDO, SuperClassCDO:DeepCopy(SuperClassCDO))
SubClassCDO:SetType("SubClass")

-- 같은 이름의 함수를 완전히 덮어쓰려면 이 아래에 정의한다. -- 오버라이딩과 비슷하게 동작한다.


return SubClassCDO