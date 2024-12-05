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
		

		-- create of list of pages that come before page y
		if not orderPairs[tonumber(y)] then
			orderPairs[tonumber(y)] = {}
		end
		table.insert(orderPairs[tonumber(y)], tonumber(x))
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

local function sumMiddlePage(jobs)
	local sum = 0

	for _, job in ipairs(jobs) do
		if #job % 2 == 0 then
			error("Job " .. util.arrayToString(job) .. " has even number of pages")
		end

		local middlePage = math.ceil(#job / 2)
		sum = sum + job[middlePage]
	end

	return sum
end

local function isValidJob(job, orderPairs)
	local jobValid = true
	local printed = {}
	for pos, page in ipairs(job) do
		local dependencies = orderPairs[page]

		-- if job has dependencies, AND a dependency is to be printed, it has to be printed before this page
		if dependencies then
			for _, dependency in ipairs(dependencies) do
				local dependencyPartOfJob = util.contains(job, dependency)

				if dependencyPartOfJob and not printed[dependency] then
					print("\tPage " .. page .. " has dependency " .. dependency .. " which is not printed yet")
					jobValid = false
					break
				end
			end
		end

		-- add page to printed list
		printed[page] = true
	end
	return jobValid
end

local function fixJob(job, orderPairsOrig)
	print("Fixing job " .. util.arrayToString(job))

	-- we create a copy of the job and orderPairs
	local job = {table.unpack(job)}
	local orderPairs = {} -- deep copy of orderPairs
	for k, v in pairs(orderPairsOrig) do
		orderPairs[k] = {table.unpack(v)}
	end

	-- we rebuild the job and start with an empty job
	local newJob = {}

	-- in each iteration, we identify the job, which only depends on pages that are already printed
	while #job > 0 do
		-- remove all dependencies on pages that are already printed, these are always satisfied
		for i, dependencies in pairs(orderPairs) do
			-- print("Checking page " .. i .. " for dependencies: " .. util.arrayToString(dependencies))
			local toBeDeleted = {}
			for k, dependency in ipairs(dependencies) do
				-- print("\tChecking dependency " .. dependency)
				-- if dependency is to be printed, keep it
				if not util.contains(job, dependency) then
					-- print("\tRemoving dependency " .. dependency .. " from page " .. i)
					table.insert(toBeDeleted, k)
				end
			end

			-- actually delete the dependencies (but in reverse order)
			for k = #toBeDeleted, 1, -1 do
				table.remove(dependencies, toBeDeleted[k])
			end

			-- it dependency list is empty, we remove the entry from the orderPairs
			if #dependencies == 0 then
				print("\tPage " .. i .. " has no dependencies left")
				orderPairs[i] = nil
			end
		end

		-- we add the first page that has no dependencies left
		local jobsAdded = 0
		for idx, joblet in ipairs(job) do
			if not orderPairs[joblet] then
				print("\tAdding page " .. joblet)
				table.insert(newJob, joblet)
				table.remove(job, idx)
				orderPairs[joblet] = nil
				jobsAdded = jobsAdded + 1
			else
				print("\tPage " .. joblet .. " has dependencies left: " .. util.arrayToString(orderPairs[joblet]))
			end
		end
		-- sanity check to confirm that current newJob is valid
		if not isValidJob(newJob, orderPairsOrig) then
			error("Job " .. util.arrayToString(newJob) .. " is not valid")
		end

		-- if we did not add any jobs, we are stuck
		if jobsAdded == 0 then
			print("\tNo jobs added, we are stuck")
			print("\tRemaining: " .. util.arrayToString(job))
			print("\tCurrent job: " .. util.arrayToString(newJob))
			for y, x in pairs(orderPairs) do
				print("\t" .. util.arrayToString(x) .. "|" .. y)
			end
			error("Job is stuck, help, human!")
		end
	end

	return newJob
end

local function part1()
	local lines = util.loadInput(5)
	local orderPairs, printJobs = parseInput(lines)

	-- walk through each print job, and check if dependencies are already printed
	local validJobs = {}
	for i, job in ipairs(printJobs) do
		print("Checking job " .. i .. ": " .. util.arrayToString(job))

		local jobValid = true

		-- check for each page, if it dependency is in previous slice
		local jobValid = isValidJob(job, orderPairs)

		if jobValid then
			print("\tJob is valid")
			table.insert(validJobs, job)
		else
			print("\tJob is invalid")
		end
		print()
	end

	local sum = sumMiddlePage(validJobs)
	print("Part 1: " .. sum)
end

local function part2()
	local lines = util.loadInput(5)
	local orderPairs, printJobs = parseInput(lines)
	local validJobs = {}
	for i, job in ipairs(printJobs) do
		print("Checking job " .. i .. ": " .. util.arrayToString(job))

		if isValidJob(job, orderPairs) then
			print("\tJob is valid, ignoring")
		else
			print("\tJob is invalid, fixing it")
			job = fixJob(job, orderPairs)
			table.insert(validJobs, job)
		end
		print()
	end

	local sum = sumMiddlePage(validJobs)
	print("Part 2: " .. sum)
end

part1()
part2()
