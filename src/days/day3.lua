require("compat")
local util = require("util")

local PART1_MUL_PATTERN = "mul%((%d%d?%d?),(%d%d?%d?)%)"

local function part1()
	local input = util.loadInput(3)

	local sum = 0
	for _, line in ipairs(input) do
		-- find all matches of the mul function
		for a, b in string.gmatch(line, PART1_MUL_PATTERN) do
			sum = sum + a * b
		end
	end

	print("Part 1:", sum)
end

-- Lua patterns can't handle alternations, so we have to parse the input manually
-- This function returns an iterator that returns valid matches
-- Valid matches are the following operations:
-- - do(): enable the following operations
-- - don't(): disable the following operations
-- - mul(xxx,yyy): multiply xxx with yyy
local function opIter(input)
	local i = 1
	local len = #input
	return function()
		while i <= len do
			local oldI = i
			local c = input:sub(i, i)
			if c == "d" then
				if input:sub(i, i + 3) == "do()" then
					i = i + 4
					return "do", oldI, i
				elseif input:sub(i, i + 6) == "don't()" then
					i = i + 7
					return "don't", oldI, i
				end
			elseif c == "m" then
				if input:sub(i, i + 3) == "mul(" then
					-- advance to the first number
					i = i + 4

					-- include the closing parenthesis in the match, to ensure it's a valid match
					local a, b = input:match("^(%d%d?%d?),(%d%d?%d?)%)", i)

					-- if the match is invalid, rollback the index
					if not a then
						i = oldI
					else
						-- consume all numbers, the comma and the closing parenthesis
						i = i + #a + #b + 2
						return "mul", oldI, i, a, b
					end
				end
			end
			i = i + 1
		end
	end
end

local function part2()
	local input = util.loadInput(3)

	local sum = 0
	local enable = true
	for _, line in ipairs(input) do
		for op, from, to, a, b in opIter(line) do

			local sub = line:sub(from, to - 1)
			--print("Identified op: " .. op .. " from " .. from .. " to " .. to .. " : " .. sub)

			if op == "do" then
				--print("do")
				enable = true
			elseif op == "don't" then
				--print("don't")
				enable = false
			elseif op == "mul" and enable then
				--print("mul", a, b)
				sum = sum + a * b
			end
		end
	end

	print("Part 2:", sum)
end

part1()
part2()
