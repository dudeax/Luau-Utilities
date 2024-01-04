local Plane = {}
Plane.__index = Plane
function Plane.new(normal : Vector3, distance : number)
	local self = setmetatable({}, Plane)
	self.normal = normal or Vector3.new(0, 1, 0)
	self.distance = distance or 0
	return self
end

function Plane:rayIntersectionDistance(origin : Vector3, direction : Vector3)
	local denominator = direction:Dot(self.normal)
	return (self.distance - origin:Dot(self.normal)) / denominator
end

return Plane