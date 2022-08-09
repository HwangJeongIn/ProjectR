local Inheritable__index = function(table, key)
	local metatable = getmetatable(table)
	return metatable[key]
end

local Inheritable__newindex = function(table, key, value)
	local metatable = getmetatable(table)
	
	-- 부모 클래스도 없으면 그냥 본인 테이블에 넣는 것으로 정했다.
	local rv = metatable[key]
	if not rv then
		rawset(table, key, value)
	else
		metatable[key] = value
	end
end


function Immutable__newindex() end

local Utility = {
	Inheritable__index = Inheritable__index,
	Inheritable__newindex = Inheritable__newindex,
	Immutable__newindex = Immutable__newindex,
	EmptyFunction = Immutable__newindex
}

Utility.__index = Inheritable__index
Utility.__newindex = Immutable__newindex


function Utility:AddClonedObjectModuleScriptToObject(object, objectModuleSript)
	local clonedObjectModuleScript = objectModuleSript:Clone()
	clonedObjectModuleScript.Parent = object
	clonedObjectModuleScript.Name = "RawObjectData"

	return require(clonedObjectModuleScript)
end

function Utility:ShallowCopy(original)
	local originalType = type(original)
	local copy = {}

	if originalType == 'table' then
		for key, value in next, original, nil do
			copy[key] = value
		end
	end

	return copy
end

function Utility:DeepCopy(original)

	local originalType = type(original)
	local copy = {}

	if originalType == 'table' then

		for key, value in next, original, nil do
			copy[Utility:DeepCopy(key)] = Utility:DeepCopy(value)
		end
		setmetatable(copy, Utility:DeepCopy(getmetatable(original)))

	else -- number, string, boolean, etc
		copy = original
	end

	return copy
end

function Utility:DeepCopyWithoutMetatable(original)

	local originalType = type(original)
	local copy = {}

	if originalType == 'table' then

		for key, value in next, original, nil do
			copy[Utility:DeepCopy(key)] = Utility:DeepCopy(value)
		end
		setmetatable(copy, getmetatable(original))

	else -- number, string, boolean, etc
		copy = original
	end

	return copy
end


return Utility
