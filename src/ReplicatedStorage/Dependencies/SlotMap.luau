-- SlotMap.lua
-- Stable ID storage with generation checks
-- Suitable for editor-side graph data

export type Id = {
	index: number,
	generation: number,
}

export type SlotMap<T> = {
	_data: { [number]: T? },
	_generation: { [number]: number },
	_free: { number },
}

local SlotMap = {}
SlotMap.__index = SlotMap

-- Create a new slot map
function SlotMap.new<T>(): SlotMap<T>
	return setmetatable({
		_data = {},
		_generation = {},
		_free = {},
	}, SlotMap)
end

-- Insert a value and receive a stable Id
function SlotMap:insert<T>(value: T): Id
	local index: number

	if #self._free > 0 then
		index = table.remove(self._free)
	else
		index = #self._data + 1
	end

	self._data[index] = value
	self._generation[index] = (self._generation[index] or 0) + 1

	return {
		index = index,
		generation = self._generation[index],
	}
end

-- Remove a value by Id
function SlotMap:remove<T>(id: Id): T
	if self._generation[id.index] ~= id.generation then
		return -- stale or already removed
	end
	
	local data = self._data[id.index]
	
	self._data[id.index] = nil
	table.insert(self._free, id.index)
	
	return data
end

-- Get a value safely
function SlotMap:get<T>(id: Id): T?
	if self._generation[id.index] ~= id.generation then
		return nil
	end

	return self._data[id.index]
end

-- Unsafe get (assumes validity, faster)
function SlotMap:getUnchecked<T>(id: Id): T
	return self._data[id.index] :: T
end

-- Check if an Id is still valid
function SlotMap:isValid(id: Id): boolean
	return self._generation[id.index] == id.generation
end

-- Iterate over live entries
function SlotMap:iteratable()
	return self._data
end

-- Clear all data (invalidates all Ids)
function SlotMap:clear()
	table.clear(self._data)
	table.clear(self._generation)
	table.clear(self._free)
end

return SlotMap
