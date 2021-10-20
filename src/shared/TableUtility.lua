local TableUtility = {}

function TableUtility:removeRange(tbl, start, stop)
	local result = {}

	for index = 1, #tbl do
		if index < start or index > stop then
			table.insert(result, tbl[index])
		end
	end

	return result
end

function TableUtility:join(...)
	local result = {}
	local sourceTables = {...}

	for _, tbl in pairs(sourceTables) do
		for index = 1, #tbl do
			table.insert(result, tbl[index])
		end
	end

	return result
end

return TableUtility