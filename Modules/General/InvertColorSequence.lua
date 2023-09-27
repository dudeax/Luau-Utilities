-- Reverses all the keypoints in a color sequence
return function(sequence: ColorSequence): ColorSequence
	local points = {}
	for i = 1, #sequence.Keypoints do
		local point = sequence.Keypoints[#sequence.Keypoints + 1 - i]
		table.insert(points, ColorSequenceKeypoint.new(1 - point.Time, point.Value))
	end
	return ColorSequence.new(points)
end