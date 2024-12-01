local M = {}

function M.loadInput(day)
	local filepath = "input/" .. day .. ".txt"
	local file = io.open(filepath, "r")
	if not file then
		error("Could not open file: " .. filepath)
	end

	local lines = {}
	for line in file:lines() do
		table.insert(lines, line)
	end

	file:close()
	return lines
end

-- This function splits a single line at each whitespace character.
function M.splitLine(input)
	local words = {}
	for word in input:gmatch("%S+") do
		table.insert(words, word)
	end
	return words
end

-- This function transposes lines of columns into columns of lines.
function M.transpose(lines)
	-- Each column is a row in the transposed table (allocated dynamically).
	local columns = {}

	for _, line in ipairs(lines) do
		local words = M.splitLine(line)
		for i, word in ipairs(words) do
			if not columns[i] then
				-- Allocate a new column if it doesn't exist yet.
				columns[i] = {}
			end
			table.insert(columns[i], word)
		end
	end

	return columns
end

function M.arrayToString(array)
	local str = "["
	for i, v in ipairs(array) do
		str = str .. v
		if i < #array then
			str = str .. ", "
		end
	end
	str = str .. "]"
	return str
end

return M
