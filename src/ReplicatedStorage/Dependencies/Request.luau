--!strict
export type Request<T..., U...> = {
	setCallback: (self: Request<T..., U...>, callback: (T...) -> (U...)) -> (),
	invoke: (self: Request<T..., U...>, T...) -> (U...),
}

type privateRequest<T..., U...> = Request<T..., U...> & {
	callback: ((T...) -> (U...))?
}

local function setCallback<T..., U...>(self: privateRequest<T..., U...>, callback: (T...) -> (U...))
	assert(not self.callback, "callback is already assigned. don't reassign callbacks, noob.")
	self.callback = callback
end

local function invoke<T..., U...>(self: privateRequest<T..., U...>, ...: T...): U...
	assert(self.callback, "callback isn't assigned yet, noob.")
	return self.callback(...)
end

local Request = {}

function Request.new<T..., U...>(): Request<T..., U...>
	return {
		setCallback = setCallback,
		invoke = invoke
	} :: any
end

return table.freeze(Request)
