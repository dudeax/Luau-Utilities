-- This method will perform a deep copy of any value passed in, and will work on metadata and ciclic tables
--   Adapted from Kristopher38 on https://gist.github.com/tylerneylon/81333721109155b2d244
local function deepCopy(object: any, seen: {any : boolean}?): any
	-- Handle non-tables and previously-seen tables.
	if type(object) ~= 'table' then return object end
	if seen ~= nil and seen[object] ~= nil then return seen[object] end

	-- New table; mark it as seen an copy recursively.
	local currentSeen = if seen ~= nil then seen else {}
	local result = {}
	currentSeen[object] = result
	for index, value in object do result[deepCopy(index, currentSeen)] = deepCopy(value, currentSeen) end
	return setmetatable(result, getmetatable(object))
end

return deepCopy