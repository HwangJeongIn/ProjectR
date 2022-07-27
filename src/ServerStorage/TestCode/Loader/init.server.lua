local SubClassCDO = require(script.SubClass)
local SuperClassCDO = require(script.SuperClass)


local subClassObject = SubClassCDO.Clone()
subClassObject.PrintDerived(subClassObject)

-- SuperClass에 있는 변수
print("value1 is in SuperClass public => " .. tostring(subClassObject.value1))
print("value2 is in SuperClass private => " .. tostring(subClassObject.value2))


-- SubClass에 있는 변수
print("value3 is in SuperClass public => " .. tostring(subClassObject.value3))
print("value4 is in SuperClass private => " .. tostring(subClassObject.value4))


local temp1 = subClassObject:CastByCDO(SuperClassCDO)
print("CastByCDO => SuperClassCDO => " .. temp1.GetClassTypeForInstance())
print("RealType(ref from reflection data) =>" .. temp1:GetType())

local temp2 = subClassObject:CastByType(SuperClassCDO:GetClassTypeForCDO())
print("CastByType => SuperClass Type => " .. temp2.GetClassTypeForInstance())
print("RealType(ref from reflection data) => " .. temp2:GetType())


local temp3 = subClassObject:CastByType("ClassBase")
print("CastByType => ClassBase Type => " .. temp3.GetClassTypeForInstance())
print("RealType(ref from reflection data) => " .. temp3:GetType())

-- SuperClass에 있는 함수
subClassObject.PrintBase(subClassObject)
print("GetPrivateValue2 => ".. tostring(subClassObject:GetPrivateValue2()))


local b = 2
