-- Creates a triangle made out of the minimum number of wedges

function GenerateRightTriangle(vectorOne : Vector3, vectorTwo : Vector3, vectorThree : Vector3, thickness : number) : BasePart
	local height = (vectorOne - vectorTwo).magnitude
	local width = (vectorThree - vectorTwo).magnitude

	local forward = (vectorThree - vectorTwo).Unit
	local up = (vectorTwo - vectorOne).Unit
	local right = forward:Cross(up).Unit
	local position = (vectorOne + vectorThree) / 2 - right * thickness / 2

	local TriangleCframe = CFrame.new(position.x, position.y, position.z, 
		right.x,    forward.x,       up.x,
		right.y,    forward.y,       up.y,
		right.z,    forward.z,       up.z)

	local part = Instance.new("WedgePart")
	part.Anchored = true
	part.Size = Vector3.new(thickness, width, height)
	part.CFrame = TriangleCframe
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = Enum.Material.SmoothPlastic
	part.Name = "Triangle"
	return part
end

function GenerateTriangleWithLongSide(vectorOne : Vector3, vectorTwo : Vector3, vectorThree : Vector3, thickness : number) : {BasePart}
	local edgeOne = vectorOne - vectorTwo
	local edgeTwo = vectorTwo - vectorThree
	local edgeThree = vectorThree - vectorOne
	if edgeThree:Dot(edgeTwo) == 0 then
		return {GenerateRightTriangle(vectorOne, vectorThree, vectorTwo, thickness)}
	else
		local centerPoint = vectorOne - (edgeOne.Unit * edgeOne.Unit:Dot(-edgeThree))
		return {
			GenerateRightTriangle(vectorThree, centerPoint, vectorTwo, thickness),
			GenerateRightTriangle(vectorOne, centerPoint, vectorThree, thickness)
		}
	end
end

return function(vectorOne : Vector3, vectorTwo : Vector3, vectorThree : Vector3, thickness : number) : {BasePart}
	local edgeOneMagnitude = (vectorOne - vectorTwo).magnitude
	local edgeTwoMagnitude = (vectorTwo - vectorThree).magnitude
	local edgeThreeMagnitude = (vectorThree - vectorOne).magnitude
	if (edgeOneMagnitude > edgeTwoMagnitude and edgeOneMagnitude > edgeThreeMagnitude) then
		return GenerateTriangleWithLongSide(vectorOne, vectorTwo, vectorThree, thickness)
	elseif (edgeTwoMagnitude > edgeOneMagnitude and edgeTwoMagnitude > edgeThreeMagnitude) then
		return GenerateTriangleWithLongSide(vectorTwo, vectorThree, vectorOne, thickness)
	else
		return GenerateTriangleWithLongSide(vectorThree, vectorOne, vectorTwo, thickness)
	end
end