-- Splits a string into an array of strings seperated by the seperator
-- i.e. SplitString("Hello-World", "-") -> {"Hello", "World"}
return function(inputString: string, seperator: string) : {string}
	local strings = {}
	for subString in string.gmatch(inputString, "([^"..seperator.."]+)") do
		table.insert(strings, subString)
	end
	return strings
end