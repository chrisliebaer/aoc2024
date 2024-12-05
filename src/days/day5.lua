local util = require("util")


local function parseInput(line)
	-- first section is in form of "X|Y", where X comes before Y, with X and Y being integers
	local secondSectionStart
	local orderPairs = {}
	for lineno, line in ipairs(line) do
		line = line:gsub("\n", "")
		line = line:gsub("\r", "")

		if line == "" then
			secondSectionStart = lineno + 1
			break
		end

		local x, y = line:match("(%d+)|(%d+)")
		orderPairs[tonumber(y)] = tonumber(x)
	end

	-- second section is in form of "a,b,c,d,e", where a,b,c,d,e are integers
	local printJobs = {}

	for lineno, line in ipairs(line) do
		-- skip first section
		if lineno >= secondSectionStart then
			local printJob = {}
			for printJobStr in line:gmatch("(%d+)") do
				table.insert(printJob, tonumber(printJobStr))
			end
			table.insert(printJobs, printJob)
		end
	end

	return orderPairs, printJobs
end

local function part1()
	local lines = util.loadInput(5)
	local orderPairs, printJobs = parseInput(lines)

	-- walk through each print job, and check if dependencies are already printed
	for i, job in ipairs(printJobs) do
		print("Checking job " .. i .. ": " .. util.arrayToString(job))

		local jobValid = true
		local printed = {}

		-- check for each page, if it dependency is in previous slice
		for pos, page in ipairs(job) do
			local dependency = orderPairs[page]

			-- if job has dependency, AND the dependency is to be printed, it has to be printed before this page
			if dependency then
				local dependencyPartOfJob = util.contains(job, dependency)

				if dependencyPartOfJob and not printed[dependency] then
					print("\tPage " .. page .. " has dependency " .. dependency .. " which is not printed yet")
					jobValid = false
					break
				end
			end

			-- add page to printed list
			printed[page] = true
		end

		if jobValid then
			print("\tJob is valid")
		else
			print("\tJob is invalid")
		end
		print()
	end
end

local function part2()
	
end

part1()
part2()
