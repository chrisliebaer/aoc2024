local util = require("util")

local GUARD_ICON = {"^", ">", "v" , "<"}
local DIRECTIONS = {
	{0, -1}, -- up
	{1, 0}, -- right
	{0, 1}, -- down
	{-1, 0}, -- left
}

local function rotateRight(direction)
	return {-direction[2], direction[1]}
end

local function guardWalkIter(grid, start, direction)
	local x, y = start[1], start[2]

	local started = true

	return function()
		-- if we haven't started yet, return the starting cell
		if started then
			started = false
			return x, y, direction
		end


		-- get next cell
		local nextX, nextY = x + direction[1], y + direction[2]
		local cell = grid:getCell(nextX, nextY)

		-- if cell is nil, out of bounds, end iteration
		if not cell then
			return nil
		end

		-- if cell a wall "#", turn right and return current position with new direction
		if cell == "#" then
			direction = rotateRight(direction)
		else
			-- move to the next cell
			x, y = nextX, nextY
		end

		return x, y, direction
	end
end

-- reuse char grid from day 4
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

		-- find the starting position, the initial direction, and replace it with a dot
		for y = 1, grid:height() do
			for x = 1, grid:width() do
				local cell = grid:getCell(x, y)
				for i, icon in ipairs(GUARD_ICON) do
					if cell == icon then
						local start = {x, y}
						local direction = DIRECTIONS[i]
						grid[y][x] = "."

						return grid, start, direction
					end
				end
			end
		end
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

local function printVisitedMap(visited, grid, char)
	if not char then
		char = "X"
	end

	print("Visited map:")
	for y = 1, grid:height() do
		for x = 1, grid:width() do
			if visited[x .. "," .. y] then
				io.write(char)
			else
				io.write(grid:getCell(x, y))
			end
		end
		io.write("\n")
	end
	print()
end

local function stateTerminates(grid, pos, dir)
	local x, y = pos[1], pos[2]
	local dx, dy = dir[1], dir[2]

	local seenStates = {}
	for x, y, dir in guardWalkIter(grid, pos, dir) do
		local key = x .. "," .. y .. "," .. dir[1] .. "," .. dir[2]
		if seenStates[key] then
			-- already visited this state, loop detected
			return false
		end
		seenStates[key] = true
	end

	-- guard walked off the grid, no loop detected
	return true
end

local function part1()
	local lines = util.loadInput(6)
	local grid, start, dir = CharGrid:create(lines)
	print("Grid size: " .. grid:width() .. "x" .. grid:height() .. " Start: " .. start[1] .. "," .. start[2] .. " Direction: " .. dir[1] .. "," .. dir[2])

	-- keep track of unique cells visited
	local visited = {}
	for x, y, dir in guardWalkIter(grid, start, dir) do
		visited[x .. "," .. y] = true
	end

	-- count unique cells visited
	local count = 0
	for _, _ in pairs(visited) do
		count = count + 1
	end

	printVisitedMap(visited, grid)

	print("Part 1: " .. count)
end

-- part 2 starts similar to part 1, but we need to find all locations in which placing a wall would result in a loop
local function part2()
	local lines = util.loadInput(6)
	local grid, start, dir = CharGrid:create(lines)

	-- run once to find all visited cells including the orientation of the guard
	local visited = {}
	for x, y, dir in guardWalkIter(grid, start, dir) do
		table.insert(visited, {x, y, dir})
	end

	-- for each location, try to place a wall in front of the guard and see if it results in a loop
	local validWalls = {}

	-- keep track of visited cells
	local checkedCells = {}
	for _, state in ipairs(visited) do
		local x, y, dx, dy = state[1], state[2], state[3][1], state[3][2]

		-- check if placing a wall in front of the guard is possible
		local wallX, wallY = x + dx, y + dy
		local cell = grid:getCell(wallX, wallY)
		if cell == "#" or cell == nil then
			goto continue
		end

		-- we can't place a wall where the guard has already been, it would make reaching the current state impossible
		if checkedCells[wallX .. "," .. wallY] then
			goto continue
		end

		-- place a wall in front of the guard
		grid[wallY][wallX] = "#"

		-- starting at the same location, find a loop or the end of the path
		if not stateTerminates(grid, {x, y}, {dx, dy}) then
			-- wall resulted in a loop, this is a valid wall
			validWalls[wallX .. "," .. wallY] = true
		end

		-- remove the wall
		grid[wallY][wallX] = "."

		::continue::
		checkedCells[x .. "," .. y] = true
	end

	-- the starting location is not a valid wall
	validWalls[start[1] .. "," .. start[2]] = nil

	-- count valid walls
	local count = 0
	for _, _ in pairs(validWalls) do
		count = count + 1
	end

	printVisitedMap(validWalls, grid, "O")

	print("Part 2: " .. count)
end

-- brute force solution to part 2, since the initial solution did not work
function part2BruteForce()
	local lines = util.loadInput(6)
	local grid, start, dir = CharGrid:create(lines)
	local startX, startY = start[1], start[2]

	-- for each cell that isn't a wall or the starting location, try to place a wall and see if it results in a loop
	local validWalls = {}
	for y = 1, grid:height() do
		for x = 1, grid:width() do
			local cell = grid:getCell(x, y)

			if cell == "#" or (x == startX and y == startY) then
				goto continue
			end

			-- place a wall in front of the guard
			grid[y][x] = "#"

			-- starting at the same location, find a loop or the end of the path
			if not stateTerminates(grid, start, dir) then
				-- wall resulted in a loop, this is a valid wall
				validWalls[x .. "," .. y] = true
			end

			-- remove the wall
			grid[y][x] = "."

			::continue::
		end
	end

	local count = 0
	for _, _ in pairs(validWalls) do
		count = count + 1
	end

	printVisitedMap(validWalls, grid, "O")

	print("Part 2 (brute force): " .. count)
end

part1()
part2()
-- part2BruteForce()
