require("compat")
local util = require("util")

local function part1()
	local lines = util.loadInput(1)
	local first, second = unpack(util.transpose(lines))

	-- sort both arrays
	table.sort(first)
	table.sort(second)

	local distance = 0
	for i = 1, #first do
		local f = tonumber(first[i])
		local s = tonumber(second[i])
		distance = distance + math.abs(f - s)
	end

	print("Part 1:", distance)
end

local function part2()
	local lines = util.loadInput(1)
	local first, second = unpack(util.transpose(lines))

	-- count occurences of each number in second list
	local occurences = {}
	for _, n in ipairs(second) do
		local n = tonumber(n)
		occurences[n] = (occurences[n] or 0) + 1
	end

	-- revisit first list to add similarity for each number
	local similarity = 0
	for _, n in ipairs(first) do
		local n = tonumber(n)
		similarity = similarity + n * (occurences[n] or 0)
	end

	print("Part 2:", similarity)
end

part1()
part2()
