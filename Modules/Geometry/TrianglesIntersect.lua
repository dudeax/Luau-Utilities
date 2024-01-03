-- Addapted for luau from https://github.com/robonrrd/csg/blob/master/src/libcsg.cpp

type intersectionReturnValue = {coplanar : boolean, source : Vector3, target : Vector3, alpha : number, beta : number}

local function orient2d(a : Vector2, b : Vector2, c : Vector2)
	return (a.X - c.X) * (b.Y - c.Y) - (a.Y - c.Y) * (b.X - c.X)
end

local function intersectionTestVertex(p1 : Vector2, q1 : Vector2, r1 : Vector2,
	p2 : Vector2, q2 : Vector2, r2 : Vector2,
	returnValue : intersectionReturnValue): intersectionReturnValue?
	if (orient2d(r2, p2, q1) >= 0.0) then
      	if (orient2d(r2, q2, q1) <= 0.0) then
         	if (orient2d(p1, p2, q1) > 0.0) then
            	if (orient2d(p1, q2, q1) <= 0.0) then
					return returnValue
               	end
         	else
            	if (orient2d(p1, p2, r1) >= 0.0) then
               		if (orient2d(q1, r1, p2) >= 0.0) then
						return returnValue
                  	end
               	end
         	end
      	elseif (orient2d(p1, q2, q1) <= 0.0) then
         	if (orient2d(r2, q2, r1) <= 0.0) then
            	if (orient2d(q1, r1, q2) >= 0.0) then
					return returnValue
               	end
            end
        end
   	elseif (orient2d(r2, p2, r1) >= 0.0) then
      	if (orient2d(q1, r1, r2) >= 0.0) then
         	if (orient2d(p1, p2, r1) >= 0.0) then
				return returnValue
            end
      	elseif (orient2d(q1, r1, q2) >= 0.0) then
         	if (orient2d(r2, r1, q2) >= 0.0) then
				return returnValue
            end
        end
	end
	return
end

local function intersectionTestEdge(p1 : Vector2, q1 : Vector2, r1 : Vector2,
	p2 : Vector2, q2 : Vector2, r2 : Vector2,
	returnValue : intersectionReturnValue): intersectionReturnValue?
	if (orient2d(r2, p2, q1) >= 0.0) then
      	if (orient2d(p1, p2, q1) >= 0.0) then
         	if (orient2d(p1, q1, r2) >= 0.0) then
            	return returnValue
            end
      	else
         	if (orient2d(q1, r1, p2) >= 0.0) then
            	if (orient2d(r1, p1, p2) >= 0.0) then
               		return returnValue
               	end
            end
      	end
   	else
      	if (orient2d(r2, p2, r1) >= 0.0) then
         	if (orient2d(p1, p2, r1) >= 0.0) then
            	if (orient2d(p1, r1, r2) >= 0.0) then
					return returnValue
            	else
               		if (orient2d(q1, r1, r2) >= 0.0) then
                  		return returnValue
                  	end
            	end
            end
        end
	end
	return
end

local function ccwTriTriIntersection2d(p1 : Vector2, q1 : Vector2, r1 : Vector2,
	p2 : Vector2, q2 : Vector2, r2 : Vector2,
	returnValue : intersectionReturnValue): intersectionReturnValue?
	if (orient2d(p2, q2, p1) >= 0.0) then
      	if (orient2d(q2, r2, p1) >= 0.0) then
         	if (orient2d(r2, p2, p1) >= 0.0) then
            	return returnValue
         	else
				return intersectionTestEdge(p1, q1, r1, p2, q2, r2, returnValue)
           	end
      	else
         	if (orient2d(r2, p2, p1) >= 0.0) then
				return intersectionTestEdge(p1, q1, r1, r2, p2, q2, returnValue)
         	else
				return intersectionTestVertex(p1, q1, r1, p2, q2, r2, returnValue)
           	end
      	end
   	else
      	if (orient2d(q2, r2, p1) >= 0.0) then
         	if (orient2d(r2, p2, p1) >= 0.0) then
				return intersectionTestEdge(p1, q1, r1, q2, r2, p2, returnValue)
         	else
				return intersectionTestVertex(p1, q1, r1, q2, r2, p2, returnValue)
            end
      	else
			return intersectionTestVertex(p1, q1, r1, r2, p2, q2, returnValue)
        end
    end
end

local function triTriOverlapTest2d(p1 : Vector2, q1 : Vector2, r1 : Vector2,
	p2 : Vector2, q2 : Vector2, r2 : Vector2,
	returnValue : intersectionReturnValue): intersectionReturnValue?
   	if (orient2d(p1, q1, r1) < 0.0) then
      	if (orient2d(p2, q2, r2) < 0.0) then
			return ccwTriTriIntersection2d(p1, r1, q1, p2, r2, q2, returnValue)
      	else
			return ccwTriTriIntersection2d(p1, r1, q1, p2, q2, r2, returnValue)
        end
   	elseif (orient2d(p2, q2, r2) < 0.0) then
		return ccwTriTriIntersection2d(p1, q1, r1, p2, r2, q2, returnValue)
   	else
		return ccwTriTriIntersection2d(p1, q1, r1, p2, q2, r2, returnValue)
    end
end

local function coplanarTriTri3d(p1 : Vector3, q1 : Vector3, r1 : Vector3,
	p2 : Vector3, q2 : Vector3, r2 : Vector3, N1 : Vector3,
	returnValue : intersectionReturnValue): intersectionReturnValue?
	returnValue.coplanar = true
	
	local P1, Q1, R1;
   	local P2, Q2, R2;

   	local n_x = math.abs(N1.X)
   	local n_y = math.abs(N1.Y)
   	local n_z = math.abs(N1.Z)


   --Projection of the triangles in 3D onto 2D such that the area of the projection is maximized.
   	if ((n_x > n_z) and (n_x >= n_y)) then
      	-- Project onto plane YZ
      	P1 = Vector2.new(q1.Z, q1.Y)
     	Q1 = Vector2.new(p1.Z, p1.Y)
     	R1 = Vector2.new(r1.Z, r1.Y)

     	P2 = Vector2.new(q2.Z, q2.Y)
      	Q2 = Vector2.new(p2.Z, p2.Y)
      	R2 = Vector2.new(r2.Z, r2.Y)
   	elseif ((n_y > n_z) and (n_y >= n_x)) then
      	-- Project onto plane XZ
      	P1 = Vector2.new(q1.X, q1.Z)
      	Q1 = Vector2.new(p1.X. p1.Z)
      	R1 = Vector2.new(r1.X. r1.Z)

      	P2 = Vector2.new(q2.X, q2.Z)
      	Q2 = Vector2.new(p2.X, p2.Z)
      	R2 = Vector2.new(r2.X, r2.Z)
   	else
      	-- Project onto plane XY
      	P1 = Vector2.new(p1.X, p1.Y)
      	Q1 = Vector2.new(q1.X, q1.Y)
      	R1 = Vector2.new(r1.X, r1.Y)

      	P2 = Vector2.new(p2.X, p2.Y)
      	Q2 = Vector2.new(q2.X, q2.Y)
      	R2 = Vector2.new(r2.X, r2.Y)
   	end

	return triTriOverlapTest2d(P1, Q1, R1, P2, Q2, R2, returnValue);
end

local function constructIntersection(p1 : Vector3, q1 : Vector3, r1 : Vector3,
	p2 : Vector3, q2 : Vector3, r2 : Vector3, N1 : Vector3, N2 : Vector3,
	returnValue : intersectionReturnValue): intersectionReturnValue?
	local v1 = q1 - p1
   	local v2 = r2 - p1
   	local N = v1:Cross(v2)
   	local v = p2 - p1

   	if (v:Dot(N) > 0.0) then
      	v1 = r1 - p1
      	N = v1:Cross(v2)
      	if (v:Dot(N) <= 0.0) then
         	v2 = q2 - p1
         	N = v1:Cross(v2)
         	if (v:Dot(N) > 0.0) then
            	v1 = p1 - p2
            	v2 = p1 - r1
            	returnValue.alpha = v1:Dot(N2) / v2:Dot(N2)
				v1 = returnValue.alpha * v2
            	returnValue.source = p1 - v1
            	v1 = p2 - p1
            	v2 = p2 - r2
            	returnValue.beta = v1:Dot(N1) / v2:Dot(N1)
				v1 = returnValue.beta * v2
            	returnValue.target = p2 - v1
            	return returnValue
         	else
            	v1 = p2 - p1
            	v2 = p2 - q2
            	returnValue.alpha = v1:Dot(N1) / v2:Dot(N1)
				v1 = returnValue.alpha * v2
            	returnValue.source = p2 - v1
            	v1 = p2 - p1
            	v2 = p2 - r2
            	returnValue.beta = v1:Dot(N1) / v2:Dot(N1)
				v1 = returnValue.beta * v2
            	returnValue.target = p2 - v1
            	return returnValue
        	end
      	else
        	return
      	end
   	else
      	v2 = q2 - p1
      	N = v1:Cross(v2)
      	if (v:Dot(N) < 0.0) then
        	return
      	else
         	v1 = r1 - p1
         	N = v1:Cross(v2)
         	if (v:Dot(N) >= 0.0) then
            	v1 = p1 - p2
            	v2 = p1 - r1
            	returnValue.alpha = v1:Dot(N2) / v2:Dot(N2)
				v1 = returnValue.alpha * v2
            	returnValue.source = p1 - v1
            	v1 = p1 - p2
            	v2 = p1 - q1
            	returnValue.beta = v1:Dot(N2) / v2:Dot(N2)
				v1 = returnValue.beta * v2
            	returnValue.target = p1 - v1
            	return returnValue
         	else
            	v1 = p2 - p1
            	v2 = p2 - q2
            	returnValue.alpha = v1:Dot(N1) / v2:Dot(N1)
				v1 = returnValue.alpha * v2
            	returnValue.source = p2 - v1
            	v1 = p1 - p2
            	v2 = p1 - q1
            	returnValue.beta = v1:Dot(N2) / v2:Dot(N2)
				v1 = returnValue.beta * v2
            	returnValue.target = p1 - v1
            	return returnValue
         	end
      	end
   	end
end

local function triTriInter3d(p1 : Vector3, q1 : Vector3, r1 : Vector3,
	p2 : Vector3, q2 : Vector3, r2 : Vector3, N1 : Vector3, N2 : Vector3,
	returnValue : intersectionReturnValue, dp2 : number, dq2 : number, dr2 : number) : intersectionReturnValue?
	if (dp2 > 0.0) then
      	if (dq2 > 0.0) then
        	return constructIntersection(p1, r1, q1, r2, p2, q2, N1, N2, returnValue)
      	elseif (dr2 > 0.0) then
        	return constructIntersection(p1, r1, q1, q2, r2, p2, N1, N2, returnValue)
      	else
         	return constructIntersection(p1, q1, r1, p2, q2, r2, N1, N2, returnValue)
        end
   	elseif (dp2 < 0.0) then
      	if (dq2 < 0.0) then
         	return constructIntersection(p1, q1, r1, r2, p2, q2, N1, N2, returnValue)
      	elseif (dr2 < 0.0) then
         	return constructIntersection(p1, q1, r1, q2, r2, p2, N1, N2, returnValue)
      	else
         	return constructIntersection(p1, r1, q1, p2, q2, r2, N1, N2, returnValue)
        end
   	else
      	if (dq2 < 0.0) then
         	if (dr2 >= 0.0) then
            	return constructIntersection(p1, r1, q1, q2, r2, p2, N1, N2, returnValue)
         	else
            	return constructIntersection(p1, q1, r1, p2, q2, r2, N1, N2, returnValue)
            end
      	elseif (dq2 > 0.0) then
         	if (dr2 > 0.0) then
            	return constructIntersection(p1, r1, q1, p2, q2, r2, N1, N2, returnValue)
         	else
            	return constructIntersection(p1, q1, r1, q2, r2, p2, N1, N2, returnValue)
            end
      	else
        	if (dr2 > 0.0) then
            	return constructIntersection(p1, q1, r1, r2, p2, q2, N1, N2, returnValue)
         	elseif (dr2 < 0.0) then
            	return constructIntersection(p1, r1, q1, r2, p2, q2, N1, N2, returnValue)
         	else
            	return coplanarTriTri3d(p1, q1, r1, p2, q2, r2, N1, returnValue)
         	end
      	end
    end
end


return function(p1 : Vector3, q1 : Vector3, r1 : Vector3,
	p2 : Vector3, q2 : Vector3, r2 : Vector3) : intersectionReturnValue?
	
	local returnValue = {
		coplanar = false,
		source = nil,
		target = nil,
		alpha = -1,
		beta = -1
	}

	-- Compute distance signs  of p1, q1 and r1 to the plane of triangle(p2,q2,r2)
	local v1 = p2 - r2
	local v2 = q2 - r2
	local N2 = v1:Cross(v2)

	v1 = p1 - r2
	local dp1 = v1:Dot(N2)
	
	v1 = q1 - r2
	local dq1 = v1:Dot(N2)
	
	v1 = r1 - r2
	local dr1 = v1:Dot(N2)
	

	if (((dp1 * dq1) > 0.0) and ((dp1 * dr1) > 0.0)) then return end

	-- Compute distance signs  of p2, q2 and r2 to the plane of triangle(p1, q1, r1)
	v1 = q1 - p1
	v2 = r1 - p1
	local N1 = v1:Cross(v2)

	v1 = p2 - r1
	local dp2 = v1:Dot(N1)
	v1 = q2 - r1
	local dq2 = v1:Dot(N1)
	v1 = r2 - r1
	local dr2 = v1:Dot(N1)
		
	if (((dp2 * dq2) > 0.0) and ((dp2 * dr2) > 0.0)) then return end
	
	-- Permutation in a canonical form of T1's vertices
	if (dp1 > 0.0) then
		if (dq1 > 0.0) then
			return triTriInter3d(r1, p1, q1, p2, r2, q2, N1, N2, returnValue, dp2, dr2, dq2)
		elseif (dr1 > 0.0) then
			return triTriInter3d(q1, r1, p1, p2, r2, q2, N1, N2, returnValue, dp2, dr2, dq2)
		else
			return triTriInter3d(p1, q1, r1, p2, q2, r2, N1, N2, returnValue, dp2, dq2, dr2)
		end
	elseif (dp1 < 0.0) then
		if (dq1 < 0.0) then
			return triTriInter3d(r1, p1, q1, p2, q2, r2, N1, N2, returnValue, dp2, dq2, dr2)
		elseif (dr1 < 0.0) then
			return triTriInter3d(q1, r1, p1, p2, q2, r2, N1, N2, returnValue, dp2, dq2, dr2)
		else
			return triTriInter3d(p1, q1, r1, p2, r2, q2, N1, N2, returnValue, dp2, dr2, dq2)
		end
	else
		if (dq1 < 0.0) then
			if (dr1 >= 0.0) then
				return triTriInter3d(q1, r1, p1, p2, r2, q2, N1, N2, returnValue, dp2, dr2, dq2)
			else
				return triTriInter3d(p1, q1, r1, p2, q2, r2, N1, N2, returnValue, dp2, dq2, dr2)
			end
		elseif (dq1 > 0.0) then
			if (dr1 > 0.0) then
				return triTriInter3d(p1, q1, r1, p2, r2, q2, N1, N2, returnValue, dp2, dr2, dq2)
			else
				return triTriInter3d(q1, r1, p1, p2, q2, r2, N1, N2, returnValue, dp2, dq2, dr2)
			end
		else
			if (dr1 > 0.0) then
				return triTriInter3d(r1, p1, q1, p2, q2, r2, N1, N2, returnValue, dp2, dq2, dr2)
			elseif (dr1 < 0.0) then
				return triTriInter3d(r1, p1, q1, p2, r2, q2, N1, N2, returnValue, dp2, dr2, dq2)
			else
				return coplanarTriTri3d(p1, q1, r1, p2, q2, r2, N1, returnValue)
			end
		end
	end
end