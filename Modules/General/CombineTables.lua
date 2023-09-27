-- Returns a new table that has the values of perferedTable with any missing elements from perferedTable replaced with defaultTable
--   I.e. it will it will combine the data of both, but anything in perfered data will take priority if there's dupes
--   Both perferedTable and defaultTable will remain unchanged

local ModulesFolder = script.Parent.Parent

local DeepCopyTable = require(ModulesFolder.General.DeepCopyTable)

-- Helper function to get the correct index for subtables in returnTable
local function getCurrentIndex(index : any, seen: {any : any}): any
	if type(index) == 'table' then
		return seen[index]
	end
	return index
end

-- Helper for combineTables, returnTable will be changed, but perferedTable and defaultTable will remain unchanged
local function combineTableHelper(returnTable : any, perferedTable : {any : any}, defaultTable : {any : any}, seen: {any : boolean}, handled: {any : boolean}): any
	-- All of returnTable's values should be set from perferedTable so we just need to worry about differences between defaultTable and perferedTable
	for index, value in defaultTable do
		if handled[value] ~= true then
			
			if type(value) == 'table' then
				-- Only try and resolve a table value if we haven't tried before
				handled[value] = true
			end

			local perferedValue = perferedTable[index]
			if perferedValue == nil then
				-- The value exists in defaultTable but not in perferedTable, so we need to copy it
				returnTable[DeepCopyTable(index, seen)] = DeepCopyTable(value, seen)
			elseif perferedValue ~= nil and type(value) == 'table' and type(perferedValue) == 'table' then
				-- The value exists in perferedTable and in defaultTable, but it's a table so we need to recursivly combine
				combineTableHelper(returnTable[getCurrentIndex(index, seen)], perferedValue, value, seen, handled)
			elseif (type(value) == 'table' or type(perferedValue) == 'table') and (type(value) ~= type(perferedValue)) then
				-- The value exists in perferedTable and in defaultTable, but one of the values isn't a table.
				--   Right now this will just throw a warning and the perfered value will remain in returnTable, but you could also change it so it uses the table value instead. Up to your needs
				warn("Table type mismatch between", type(perferedValue), "and", type(value), "at index [", index, "] any changes to this sub-table will not be resolved")
			end
			-- if the index is already in perferedTable and it's value isn't a table then don't do anything
			
		end
	end
end

return function(perferedTable : {any : any}, defaultTable : {any : any}) : {any : any}
	
	local seen = {} -- Used for storing copied tables
	local handled = {} -- Used for resolving circular combinations
	local returnTable = DeepCopyTable(perferedTable, seen) -- Initially populate newData with perferedTable
	
	combineTableHelper(returnTable, perferedTable, defaultTable, seen, handled)
	
	return returnTable
end