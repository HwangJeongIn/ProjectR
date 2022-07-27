local module = {}
local lifePoint = 20
local object = script.Parent

function module:TakeDamage(damage) -- boolean
	lifePoint -= damage

	print(lifePoint)
	if lifePoint <= 0 then
		object:Destroy()
	end
end

return module
