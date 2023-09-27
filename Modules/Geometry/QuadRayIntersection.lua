-- If you need this one, you know what it does. Enjoy not writing it.

--[[
	Implementation based on:
		An Efficient Ray-Quadrilateral Intersection Test
		by Ares Lagae and Philip Dutre
	
	https://graphics.cs.kuleuven.be/publications/LD04ERQIT/LD04ERQIT_paper.pdf
]]

local EPSILON = 0.0001

return function(origin : Vector3, direction : Vector3, point00 : Vector3, point10 : Vector3, point11 : Vector3, point01 : Vector3) : {u : number, v : number, distance : number}?
	-- Reject rays using the barycentric coordinates of the intersection point with respect to T.
	local edge01 = point10 - point00
	local edge03 = point01 - point00
	local p = direction:Cross(edge03)
	local det = edge01:Dot(p)
	
	if (math.abs(det) < EPSILON) then return end
	
	local t = origin - point00
	local alpha = t:Dot(p) / det
	
	if (alpha < 0) then return end
	-- if (alpha > 1) then return end -- Used with vertex reordering
	
	local q = t:Cross(edge01)
	local beta = direction:Dot(q) / det
	
	if (beta < 0) then return end
	-- if (beta > 1) then return end -- Used with vertex reordering
	
	-- Reject rays using the barycentric coordinates ofthe intersection point with respect to tPrime
	if (alpha + beta > 1) then
		local edge23 = point01 - point11
		local edge21 = point10 - point11
		local pPrime = direction:Cross(edge21)
		local detPrime = edge23:Dot(pPrime)
		
		if (math.abs(detPrime) < EPSILON) then return end
		
		local tPrime = origin - point11
		local alphaPrime = tPrime:Dot(pPrime) / detPrime
		
		if (alphaPrime < 0) then return end
		
		local qPrime = tPrime:Cross(edge23)
		local betaPrime = direction:Dot(qPrime) / detPrime
		
		if (betaPrime < 0) then return end
	end
	
	-- Compute the ray parameter of the intersection point.
	local distance = edge03:Dot(q) / det
	if (distance < 0) then return end
	
	-- Compute the barycentric coordinates of V11.
	local edge02 = point11 - point00
	local normal = edge01:Cross(edge03)
	local alpha11, beta11
	
	if ((math.abs(normal.X) >= math.abs(normal.Y)) and (math.abs(normal.X) >= math.abs(normal.Z))) then
		alpha11 = (edge02.Y * edge03.Z - edge02.Z * edge03.Y) / normal.X
		beta11 = (edge01.Y * edge02.Z - edge01.Z * edge02.Y) / normal.X
	elseif ((math.abs(normal.Y) >= math.abs(normal.X)) and (math.abs(normal.Y) >= math.abs(normal.Z))) then
		alpha11 = (edge02.Z * edge03.X - edge02.X * edge03.Z) / normal.Y
		beta11 = (edge01.Z * edge02.X - edge01.X * edge02.Z) / normal.Y
	else
		alpha11 = (edge02.X * edge03.Y - edge02.Y * edge03.X) / normal.Z
		beta11 = (edge01.X * edge02.Y - edge01.Y * edge02.X) / normal.Z
	end
	
	-- Compute the bilinear coordinates of the intersection point.
	local u, v
	if (math.abs(alpha11 - 1) < EPSILON) then
		u = alpha
		if (math.abs(beta11 - 1) < EPSILON) then
			v = beta
		else
			v = beta / (u * (beta11 - 1) + 1)
		end
	elseif (math.abs(beta11 - 1) < EPSILON) then
		v = beta
		u = alpha / (v * (alpha11 - 1) + 1)
	else
		local a = -(beta11 - 1)
		local b = alpha * (beta11 - 1) - beta * (alpha11 - 1) - 1
		local c = alpha
		local delta = b * b - 4 * a * c
		local q = -(b + math.sign(b) * math.sqrt(delta)) / 2
		u = q / a
		if ((u < 0) or (u > 1)) then u = c / q end
		v = beta / (u * (beta11 - 1) + 1)
	end
	
	return {
		distance = distance,
		u = u,
		v = v
	}
end