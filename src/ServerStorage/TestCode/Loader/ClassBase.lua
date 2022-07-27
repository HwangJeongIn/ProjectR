function AccessProtection__index(table, key)

	--print("AccessProtection__index => " .. tostring(key))
	--print(table)
	local classBody = getmetatable(table)
	
	-- 있으면 반환한다.
	local value = rawget(classBody.public, key)
	if value then
		return value
	end
	
	-- 부모 클래스를 확인한다.
	return classBody[key]
end

function AccessProtection__newindex(table, key, value)

	--print("AccessProtection__newindex => " .. tostring(key))
	--print(table)
	
	local alreadyExistKey = table[key] -- 부모 클래스에서 찾아보는 과정
	if alreadyExistKey then
		alreadyExistKey = value
	else -- 찾아보고 없으면 그냥 테이블에 할당한다.
		rawset(table, key, value)
	end
	
end


local ClassBase = {
	
	public = {
	},
	
	private = {
		reflectionData = {type = "ClassBase"},		
	},
	
	IsClassBase = true
}

ClassBase.__index = AccessProtection__index
ClassBase.__newindex = AccessProtection__newindex


function IsEmpty(target)
	
	local rv = rawget(target, "IsClassBase")
	if rv  then
		return true
	end

	return false
end

function CastToRawClassBase(target)
	
	if not target then
		return nil
	end
	
	-- 처음부터 ClassBase가 들어올 수 없다.
	local fromClassBody = getmetatable(target)
	if not fromClassBody then return nil end
	
	if IsEmpty(fromClassBody) then
		return fromClassBody
	end
	
	return CastToRawClassBase(fromClassBody)
end


function DeepCopyDetail(original)

	local originalType = type(original)
	local copy = {}

	if originalType == 'table' then

		for key, value in next, original, nil do
			copy[DeepCopyDetail(key)] = DeepCopyDetail(value)
		end
		setmetatable(copy, DeepCopyDetail(getmetatable(original)))

	else -- number, string, boolean, etc
		copy = original
	end

	return copy
	
end

function ClassBase.public.GetClassTypeForInstance()
	return "ClassBase"
end

function ClassBase.public:GetClassTypeForCDO()
	return self.public.GetClassTypeForInstance()
end

function ClassBase.public.DeepCopy(target)
	return DeepCopyDetail(target)
end

function ClassBase.public:CastByType(toClassType)

	local classType = self.GetClassTypeForInstance()

	if toClassType == classType then
		return self
	end

	local fromClassBody = getmetatable(self)
	if not fromClassBody or IsEmpty(fromClassBody) then return nil end

	return fromClassBody:CastByType(toClassType)
end

function ClassBase.public:CastByCDO(toClassBody)

	if not toClassBody or IsEmpty(toClassBody) then
		return nil
	end

	return self:CastByType(toClassBody:GetClassTypeForCDO())
end

function ClassBase.public:IsAByType(toClassType)

	local rv = self:CastByType(toClassType)
	if rv  then
		return true
	end

	return false

end

function ClassBase.public:IsAByCDO(toClassBody)

	local rv = self:CastByCDO(toClassBody)
	if rv  then
		return true
	end

	return false
end

function ClassBase.public:IsItselfByType(toClassType)

	if not toClassType then
		return false
	end

	-- 다른 클래스의 GetType이 호출되지 않도록 하기 위해 가장 클래스를 맨앞으로 가져온다.
	local fromClassBody = getmetatable(self)
	if not fromClassBody or IsEmpty(fromClassBody) then return false end

	local fromClassType = fromClassBody.GetClassTypeForInstance()

	if toClassType == fromClassType then
		return true
	end

	return false

end

function ClassBase.public:IsItselfByCDO(toClassBody)

	if not toClassBody or IsEmpty(toClassBody)  then
		return false
	end
	
	return self:IsItselfByType(toClassBody:GetClassTypeForCDO())

end

function ClassBase.public:GetThisByCDO(toClassBody)
	
	local thisInstance = self:CastByCDO(toClassBody)
	
	if not thisInstance then
		-- 발생하면 원칙을 잘 지키지 않고 코드를 작성한 경우다.
		return nil
	end
	
	-- 이렇게 하면 해당 클래스에서 접근 가능하다. 대신 public, private 과 같은 이름을 앞에 붙여줘야 한다.
	local this = getmetatable(thisInstance)
	
	return this
end

function ClassBase.public:SetType(inputString)

	local typeString = type(inputString)
	if typeString ~= "string" then
		return
	end

	local this = CastToRawClassBase(self)

	-- 이 메소드에 들어왔기 때문에 무조건 캐스팅이 보장된다.
	--if not this then return end

	this.private.reflectionData.type = inputString
end

function ClassBase.public:GetType()
	
	local this = CastToRawClassBase(self)
	
	return this.private.reflectionData.type
end


return ClassBase 
