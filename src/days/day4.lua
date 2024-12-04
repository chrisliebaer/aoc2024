local util = require("util")

-- these patterns describe the possible directions in which we need to search, starting from a cell
local ACCESS_PATTERN = {
	{1, 0}, -- right
	{0, 1}, -- down
	{1, 1}, -- diagonal right-down
	{-1, 1}, -- diagonal left-down

	-- given a string, this function will return a list of movements, matching the length of the string
	plan = function(self, x, y, str)
		local plans = {}
		for i, p in ipairs(self) do
			local dx, dy = table.unpack(p)
			plans[i] = {}
			for k = 1, #str do
				local c = str:sub(k, k)
				plans[i][k] = {c, x + dx * (k - 1), y + dy * (k - 1)}
			end
		end
		return plans
	end
}

-- only works for "MAS" and "SAM"
local ACCESS_PATTERN_PART2 = {
	{{0, 0}, {1, 1}, {2, 2}}, -- diagonal right-down
	{{2, 0}, {1, 1}, {0, 2}}, -- diagonal left-down

	-- similar to the previous function, but with a different pattern for part 2
	plan = function(self, x, y)
		local needle = "MAS"

		local plans = {}
		for i, p in ipairs(self) do
			local dx, dy = table.unpack(p)

			-- forward paths for "MAS"
			plans[i] = {}
			for k = 1, 3 do
				local dx, dy = table.unpack(p[k])
				local c = needle:sub(k, k)
				plans[i][k] = {c, x + dx, y + dy}
			end
		end

		-- backward paths for "SAM" (copy existing plans and reverse only first and last character)
		for i = 1, #self do
			local newPlan = {}
			for j = 1, 3 do
				newPlan[j] = {table.unpack(plans[i][j])}
			end

			-- reverse first and last character
			newPlan[1][1] = "S"
			newPlan[3][1] = "M"

			plans[#plans + 1] = newPlan
		end

		return plans
	end
}

local CharGrid = {
	create = function(self, lines)
		local grid = {}

		-- remove trailing whitespace
		for i, line in ipairs(lines) do
			lines[i] = line:gsub("%s+$", "")
		end

		-- remove empty lines
		for i = #lines, 1, -1 do
			if lines[i] == "" then
				table.remove(lines, i)
			end
		end

		-- assume all rows have the same amount of words
		local width = #lines[1]

		for lineno, line in ipairs(lines) do
			-- one character per cell
			for i = 1, width do
				local c = line:sub(i, i)

				grid[lineno] = grid[lineno] or {}
				grid[lineno][i] = c
			end
		end

		setmetatable(grid, {__index = self})
		return grid
	end,

	getCell = function(self, x, y)
		if self[y] and self[y][x] then
			return self[y][x]
		else
			return nil
		end
	end,

	width = function(self)
		return #self[1]
	end,

	height = function(self)
		return #self
	end,
}

local function countMatches(x, y, grid, plans)
	local count = 0
	local matchingCells = {}
	for _, plan in ipairs(plans) do

		-- if the entire plan matches, we have a match (assume it does until mismatch)
		local planMatches = true
		for _, step in ipairs(plan) do
			local c, x, y = table.unpack(step)
			local cell = grid:getCell(x, y)

			if cell ~= c then
				planMatches = false
				break
			end
		end

		if planMatches then
			count = count + 1

			-- store the matching cells for debugging purposes
			for _, step in ipairs(plan) do
				local c, x, y = table.unpack(step)
				matchingCells[#matchingCells + 1] = {x, y}
			end
		end
	end

	-- remove duplicates from matching cells
	local uniqueCells = {}
	for _, cell in ipairs(matchingCells) do
		local key = cell[1] .. "," .. cell[2]
		uniqueCells[key] = cell
	end

	matchingCells = {}
	for _, cell in pairs(uniqueCells) do
		matchingCells[#matchingCells + 1] = cell
	end

	return count, matchingCells
end

local function part1()
	local needles = {"XMAS", "SAMX"}
	local lines = util.loadInput(4)
	local grid = CharGrid:create(lines)

	-- iterate over all cells and plan search for each cell
	local matches = 0
	for x = 1, grid:width() do
		for y = 1, grid:height() do
			for _, needle in ipairs(needles) do
				local plans = ACCESS_PATTERN:plan(x, y, needle)
				matches = matches + countMatches(x, y, grid, plans)
			end
		end
	end

	print("Part 1:", matches)
end

local function part2()
	local lines = util.loadInput(4)
	local grid = CharGrid:create(lines)

	-- iterate over all cells and plan search for each cell
	local matches = 0
	for x = 1, grid:width() do
		for y = 1, grid:height() do
			local plans = ACCESS_PATTERN_PART2:plan(x, y)

			-- there can only be one match per cell
			local count, matchingCells = countMatches(x, y, grid, plans)

			-- full X requires 5 cells to match
			if #matchingCells == 5 then
				matches = matches + 1
			end
		end
	end

	print("Part 2:", matches)
end

part1()
part2()
