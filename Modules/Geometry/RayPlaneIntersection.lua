local EPSILON = 0.0001

return function(origin : Vector3, direction : Vector3, pointOnPlane : Vector3, normal : Vector3) : number
	local denominator = normal:Dot(direction)
	if (denominator > EPSILON) then
		local offset = pointOnPlane - origin;
		return offset:Dot(normal) / denominator; 
	end
	return math.huge
end