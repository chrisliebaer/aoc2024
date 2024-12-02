local util = require("util")

local function reportUpSafe(line)
	-- elements of each line must all increase by 1-3
	for i = 2, #line do
		local distance = line[i] - line[i - 1]
		if distance < 1 or distance > 3 then
			return false
		end
	end
	return true
end

local function reportLinientSafe(line)
	-- attempt to remove a single element from the line and check if it becomes safe
	for i = 1, #line do
		local copy = {table.unpack(line)}
		table.remove(copy, i)
		if reportUpSafe(copy) ~= reportUpSafe(util.reverse(copy)) then
			return true
		end
	end
	return false
end

local function part1()
	local input = util.loadInput(2)

	local validReports = 0
	for _, line in ipairs(input) do
		local report = util.splitLine(line)
		
		-- report can be valid for both reversed and non-reversed order
		if reportUpSafe(report) ~= reportUpSafe(util.reverse(report)) then
			validReports = validReports + 1
		end
	end

	print("Part 1:", validReports)
end

local function part2()
	local input = util.loadInput(2)

	local validReports = 0
	for _, line in ipairs(input) do
		local report = util.splitLine(line)

		if reportLinientSafe(report) then
			validReports = validReports + 1
		end
	end

	print("Part 2:", validReports)
end

part1()
part2()
