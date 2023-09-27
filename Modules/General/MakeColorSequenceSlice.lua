-- Creates a color sequence that's a slice of another ColorSequence (Very useful for UI things!)

local function tweenKeys(point1: ColorSequenceKeypoint, point2: ColorSequenceKeypoint, position: number): ColorSequenceKeypoint
	local amount = (position - point1.Time) / (point2.Time - point1.Time)
	return ColorSequenceKeypoint.new(position, Color3.new(
		(point2.Value.R - point1.Value.R) * amount + point1.Value.R,
		(point2.Value.G - point1.Value.G) * amount + point1.Value.G,
		(point2.Value.B - point1.Value.B) * amount + point1.Value.B
	))
end

local function scaleKey(key: ColorSequenceKeypoint, start: number, length: number): ColorSequenceKeypoint
	return ColorSequenceKeypoint.new((key.Time - start) / length, key.Value)
end

-- Start and finish should be between 0 and 1
return function(start: number, finish: number, sequence: ColorSequence): ColorSequence
	local points = {}
	local length = finish - start
	for i = 1, #sequence.Keypoints - 1 do
		local currentPoint = sequence.Keypoints[i]
		local nextPoint = sequence.Keypoints[i + 1]
		
		-- We're working on the first point
		if #points == 0 then
			if currentPoint.Time == start then
				table.insert(points, scaleKey(currentPoint, start, length))
			elseif currentPoint.Time < start and start < nextPoint.Time then
				table.insert(points, scaleKey(tweenKeys(currentPoint, nextPoint, start), start, length))
			end
		else
			table.insert(points, scaleKey(currentPoint, start, length))
		end
		
		-- Check for finish
		if finish <= nextPoint.Time then
			if finish == nextPoint.Time then
				table.insert(points, scaleKey(nextPoint, start, length))
			else
				table.insert(points, scaleKey(tweenKeys(currentPoint, nextPoint, finish), start, length))
			end
			break
		end
	end
	return ColorSequence.new(points)
end