return function(part: BasePart, inset : number) : Vector3
	local x = (part.size.X - inset) * (math.random() - 0.5)
	local y = (part.size.Y - inset) * (math.random() - 0.5)
	local z = (part.size.Z - inset) * (math.random() - 0.5)
	return part.CFrame:PointToWorldSpace(Vector3.new(x, y, z))
end