local util = require("util")

local OPS = {
	["+"] = function(a, b) return a + b end,
	["*"] = function(a, b) return a * b end,
}

local OPS_PART2 = {
	["+"] = function(a, b) return a + b end,
	["*"] = function(a, b) return a * b end,
	["||"] = function(a, b)
		local as, bs = tostring(a), tostring(b)
		return tonumber(as .. bs)
	end,
}


local function displayMath(value, numbers, ops)
	local str =  tostring(value) .. " = " .. numbers[1]
	for i, op in ipairs(ops) do
		str = str .. " " .. op[1] .. " " .. numbers[i + 1]
	end
	return str
end

-- This function generates all combinations of ops for the given length
local function generateOps(length, availableOps)

	-- if no ops are given, use the default ops
	availableOps = availableOps or OPS

	return coroutine.wrap(function()
		local ops = {}
		
		local function traverse()
			-- if we have reached the desired length, yield the ops
			if #ops == length then
				coroutine.yield(ops)
				return
			end
			
			-- for each op, add it to the ops table and traverse
			for op, func in pairs(availableOps) do
				table.insert(ops, {op, func})
				traverse()
				
				-- remove the last op to try the next one
				table.remove(ops)
			end
		end
		
		traverse()
	end)
end

local function parseLine(line)
	-- parse lines in form of: 123: 1 2 3
	local value, parts = line:match("(%d+): (.+)")
	local numbers = {}
	for number in parts:gmatch("%d+") do
		table.insert(numbers, tonumber(number))
	end

	return tonumber(value), numbers
end

local function solveLine(value, numbers, validOps)
	-- attempt to find a combination of ops that results in the desired value
	for ops in generateOps(#numbers - 1, validOps) do
		local result = numbers[1]

		-- ops operate from left to right (ignoring operator precedence)
		for i, op in ipairs(ops) do
			local nextValue = numbers[i + 1]
			result = op[2](result, nextValue)
		end

		if result == value then
			return ops
		end
	end

	-- if no solution was found, return nil
	return nil
end

local function solveWithOps(lines, validOps)
	-- record value of solveable lines
	local valueSum = 0
	for lineno, line in ipairs(lines) do

		-- skip empty lines
		if line == "" then
			goto continue
		end

		local value, numbers = parseLine(line)
		local ops = solveLine(value, numbers, validOps)
		if ops then
			print("Solving line " .. lineno .. ": " .. displayMath(value, numbers, ops))
			valueSum = valueSum + value
		else
			print("No solution for line " .. lineno .. ": " .. line)
		end

		::continue::
	end

	return valueSum
end

local function part1()
	local input = util.loadInput(7)
	print("Part 1: " .. solveWithOps(input))
end

local function part2()
	local input = util.loadInput(7)
	print("Part 2: " .. solveWithOps(input, OPS_PART2))
end

part1()
part2()
