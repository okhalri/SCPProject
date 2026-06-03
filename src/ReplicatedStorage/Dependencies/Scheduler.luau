--!strict
--!optimize 2
local clock = os.clock
local scheduled: {[string]: {fn: (now: number) -> (), delay: number, last: number, id: string}} = {}

local thread: thread

local function findNext(): (string?, number?)
	local now = clock()
	local nextScheduled = next(scheduled)
	if not nextScheduled then
		return nil, nil
	end
	
	local smallest = nextScheduled
	local smallestDifference = math.huge
	
	while nextScheduled do
		local nextTime = scheduled[nextScheduled].delay - (now - scheduled[nextScheduled].last)
		if nextTime < 0 then
			return nextScheduled, nextTime
		end
		
		if nextTime < smallestDifference then
			smallestDifference = nextTime
			smallest = nextScheduled
		end
		
		nextScheduled = next(scheduled, nextScheduled)
	end
	
	return scheduled[smallest].id, smallestDifference
end

function start()
	while true do
		local nextId, waitTime = findNext()

		if not nextId or not waitTime then
			task.wait()
			continue
		end

		if waitTime > 0 then
			task.wait(waitTime)
		end

		if not scheduled[nextId] then
			continue
		end

		local now = clock()
		task.defer(scheduled[nextId].fn, now - scheduled[nextId].last)
		scheduled[nextId].last = now
	end
end


thread = task.spawn(start)

local scheduler = {}

function scheduler.add(id: string, delay: number, fn: (dt: number) -> ())
	scheduled[id] = {
		fn = fn,
		delay = delay,
		id = id,
		last = clock()
	}
	
	if next(scheduled, next(scheduled) :: string) then
		local nextId, _ = findNext()
		
		if nextId == id then
			task.cancel(thread)
			thread = task.spawn(start)
		end
		
		return
	end
end

function scheduler.remove(id: string)
	scheduled[id] = nil
end

return table.freeze(scheduler)