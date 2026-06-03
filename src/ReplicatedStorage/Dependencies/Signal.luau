--!strict
--!optimize 2
--[[
    Copyright © 2025 gopher town
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    Distrubted under MIT license
--]]

--[[
	utility focused signal lib
	
	--Signal
	new<T...>() -> (Signal<T...>)
		Disconnect all connections. Clears the linked list and relevent items get GC'd.
			disconnectAll: (signal: Signal<T...>) -> (),

		Bind a function to the signal. This is the default connection which all other connection types inherit from.
			connect: (signal: Signal<T...>, callback: (T...) -> ()) -> (Connection<T...>),
			
		Bind a function to the signal, after one usage it will be automatically disconnected and gc'd.
			once: (signal: Signal<T...>, callback: (T...) -> ()) -> (Connection<T...>),
		
		Bind a function to the signal, after <amount: number> uses, it will automatically disconnect.
			limit: (signal: Signal<T...>, amount: number, callback: (T...) -> ()) -> (Connection<T...>),
			
		Bind a function to the signal, after each signal fire <evaluationFunction: (T...) -> (boolean)> will be executed. 
		If it returns true it will automatically disconnect.
			each: (signal: Signal<T...>, evaluationFunction: (T...) -> (boolean), callback: (T...) -> ()) -> (Connection<T...>),
			
		Bind a function to the signal, after <disconnectAfterSeconds: number> seconds, it will automatically disconnect.
			after: (signal: Signal<T...>, disconnectAfterSeconds: number, callback: (T...) -> ()) -> (Connection<T...>),
			
		Yields execution until the signal is fired. Returns T... after the signal has been fired.
			wait: (signal: Signal<T...>) -> (T...),
			
		Yields execution until the signal has been fired or <timeOut: number> has elapsed. If it times out, nil will be returned in place of T...
			waitUntil: (signal: Signal<T...>, timeOut: number) -> (T...),
			
		Fires the signal with T... as arguments. 
			fire: (signal: Signal<T...>, T...) -> (),
			
		Fires the signal with T... as arguments. Awaits until all execution has haulted.
			yieldingFire: (signal: Signal<T...>, T...) -> (),
			
		Destroys the signal and connections.
			destroy: (signal: Signal<T...>) -> ()
		
	--Connection
	connect: (signal: Signal<T...>, callback: (T...) -> ()) -> (Connection<T...>),
		Disconnects the connection.
			disconnect: (connection: Connection<T...>) -> ()
		Whether or not the signal is currently connected.
			connected: boolean,
		The amount of times the signal has been called.
			calls: number,

	@%%%%%%%%%%%%%%%%@@%%%%%%%%%%##########*#================================++++
	%%%%%%%%%%%%%%%%@@%%%%%%%%%%@####%#######=+=====+==========================++
	%%%%%%%%%%%%%%%@@@%%%%%%%%%%@##%#####%###==*=====+======+===================+
	%%%%%%%%%%%%%%%=**%%%%%%%%%#@##%#@##%%%##*=*+=====+======+===================
	%%%%%%%%%@%%%%=+++%%%%%%%%#*@#%##%##@%###+*=#===========+====================
	%%%%%%%%@%%%@@=++*%%%%%%%%===++*@##+%@#@+=+*=#=====+======#======+===========
	%%%%%%%@@%%@@@#++#%%%%%%%%===*%*+++*@#%%=+++++*++++++++++*+*+++++*++++====+==
	%%%%%%@@%%@@@@@+=#%%%%%%%%====+@%=@@%%@*#@@@++*+*+++*++++++#+++++#+++++++++*+
	%%%%%@@%%@@@@@@@@#%%%%%%%#======**#####=+#==*=+*+**+++++++*#+++++#+++++++++**
	%%%%@@@%@@@@@@@@+#%%%%%%%*========###===+======**++++++++++#*++++#+++++*++++#
	%%%%@@@@@@@@@@@++*%%%%%%%*=======+=====+=======**++++++++++##+++*#+++++#++++*
	@%@@@@@@@@@@@@++=+%@%@%%@*=======+====+++++=====*+*+++++#++##+++#*+++++##++++
	%@@@@@@@@@@@#+===+%@@%%%@*======*#====++++======*+#+++++#++*+++##++++++##++++
	@@@@@@@@@@@*+====+@@@@%@%#====#+#===============++#+++++#*++*+###++#++###++++
	@@@@@@@@@@@@*=+===%@@%%@%%====+##==+============+**++++*##+**+##*+#++####++++
	@@@@@@@@@@@@@@%=+=+@@%%%%%===*###==============++#*++++###*#####+##*#####++#+
	@@@@@@@@@@@@@@@@@=*@@@%%%@===*###==============**#+++++#%*#####*###%####**#*+
	@@@@@@@@@@@@@@@@@@%+@@@%%@@@@*##*=++++++++++++=*##++++#*######%###########**%
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#@#*+++++++++++++##**+++#**%###%%##########*#@@@
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@%###%#@@#%#***##**+*+***##*#**%%@%###%%@@@@@@@
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%##%%@@@#%##%#**#*****##%#**%*#%%%%%%@@@@@@@@
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%#%@@@@@**#*#****%#******##*%@@@@@@@@@@@@@@@
	@%@%%%%###@@@@@@@@@@@@@@@@@@@@@@@@%%@@%***##***#***********#%@@@@@@@@@@@@@@@@
]]


export type Signal<T...> = {
	disconnectAll: (signal: Signal<T...>) -> (),
	connect: (signal: Signal<T...>, callback: (T...) -> ()) -> (Connection<T...>),
	once: (signal: Signal<T...>, callback: (T...) -> ()) -> (Connection<T...>),
	limit: (signal: Signal<T...>, amount: number, callback: (T...) -> ()) -> (Connection<T...>),
	each: (signal: Signal<T...>, evaluationFunction: (T...) -> (boolean), callback: (T...) -> ()) -> (Connection<T...>),
	after: (signal: Signal<T...>, disconnectAfterSeconds: number, callback: (T...) -> ()) -> (Connection<T...>),
	wait: (signal: Signal<T...>) -> (T...),
	waitUntil: (signal: Signal<T...>, timeOut: number) -> (T...),
	fire: (signal: Signal<T...>, T...) -> (),
	yieldingFire: (signal: Signal<T...>, T...) -> (),
	
	destroy: (signal: Signal<T...>) -> ()
}

export type Connection<T...> = {	
	connected: boolean,
	calls: number,
	disconnect: (connection: Connection<T...>) -> ()
}

type privateSignal<T...> = Signal<T...> & {
	tail: privateConnection<T...>?,
	head: privateConnection<T...>?,
}

type privateConnection<T...> = Connection<T...> & {
	next: privateConnection<T...>?,
	previous: privateConnection<T...>?,
	signal: privateSignal<T...>,
	disconnectAfter: number?,
	callback: (T...) -> (),	
	eval: ((T...) -> (boolean))?
}

local function disconnect<T...>(connection: privateConnection<T...>)
	if not connection.connected then
		return
	end
	
	local nextConnection, previousConnection, signal = connection.next, connection.previous, connection.signal
	
	if nextConnection then
		nextConnection.previous = previousConnection
	else
		signal.head = previousConnection
	end
	
	if previousConnection then
		previousConnection.next = nextConnection
	else
		signal.tail = nextConnection
	end
	
	connection.connected = false
end

local function disconnectAll<T...>(signal: privateSignal<T...>)
	local connection = signal.tail
	while connection do
		if connection.calls == -1 then
			connection.callback()
		end

		connection = connection.next
	end
	
	signal.head = nil
	signal.tail = nil 
end

local function connect<T...>(signal: privateSignal<T...>, callback: (T...) -> ()): (privateConnection<T...>)
	local connection: privateConnection<T...> = {
		disconnect = disconnect :: any,
		calls = 0,
		connected = true,
		signal = signal,
		next = signal.tail,
		callback = callback,
		eval = nil
	} 
	
	if signal.tail then
		signal.tail.previous = connection
		signal.tail = connection
	else
		signal.head = connection
		signal.tail = connection
	end
	
	return connection
end

local function limit<T...>(signal: privateSignal<T...>, amount: number, callback: (T...) -> ()): (privateConnection<T...>)
	local connection = connect(signal, callback)
	
	connection.disconnectAfter = amount
	
	return connection
end

local function once<T...>(signal: privateSignal<T...>, callback: (T...) -> ()): (privateConnection<T...>)
	return limit(signal, 1, callback)
end


local function each<T...>(signal: privateSignal<T...>, evaluationFunction: (T...) -> (boolean), callback: (T...) -> ()): (privateConnection<T...>)
	local connection = connect(signal, callback)

	connection.eval = evaluationFunction

	return connection
end

local function after<T...>(signal: privateSignal<T...>, disconnectAfterSeconds: number, callback: (T...) -> ()): (privateConnection<T...>)
	local connection = connect(signal, callback)
	
	task.delay(disconnectAfterSeconds, connection.disconnect, connection)
	
	return connection
end

local function wait<T...>(signal: privateSignal<T...>): (T...)
	local t = coroutine.running()
	
	local connection = connect(signal, function(...) 
		task.spawn(t, ...)	
	end)
	
	connection.disconnectAfter = 0
	connection.calls = -1
	
	return coroutine.yield()
end

local function waitUntil<T...> (signal: privateSignal<T...>, timeOut: number?): (T...)
	local t = coroutine.running()

	timeOut = timeOut or 5

	local connection = connect(signal, function(...) 
		task.spawn(t, ...)	
	end)

	task.delay(timeOut, function()
		if not connection.connected then
			return
		end
		connection:disconnect()
		coroutine.resume(t)
	end)

	connection.disconnectAfter = 0
	connection.calls = -1

	return coroutine.yield()
end

local function yieldingFire<T...>(signal: privateSignal<T...>, ...: T...): ()
	local connection = signal.tail

	while connection do
		connection.calls += 1

		connection.callback(...)

		if connection.eval and connection.eval(...) then
			local con = connection
			connection = connection.next
			con:disconnect()
			continue
		elseif connection.disconnectAfter and connection.calls >= connection.disconnectAfter then
			local con = connection
			connection = connection.next
			con:disconnect()
			continue
		end

		connection = connection.next
	end
end

local function fire<T...>(signal: privateSignal<T...>, ...: T...): ()
	local connection = signal.tail
	
	while connection do
		connection.calls += 1
		
		task.spawn(connection.callback, ...)
		
		if connection.eval and connection.eval(...) then
			local con = connection
			connection = connection.next
			con:disconnect()
			continue
		elseif connection.disconnectAfter and connection.calls >= connection.disconnectAfter then
			local con = connection
			connection = connection.next
			con:disconnect()
			continue
		end

		connection = connection.next
	end
end

local function destroy<T...>(signal: privateSignal<T...>): ()
	signal:disconnectAll()
	table.clear(signal :: {[string]: any})
end

local signal = {}

function signal.new<T...>(): Signal<T...>
	local signal: any = {
		connect = connect,
		limit = limit,
		once = once,
		each = each,
		after = after,
		
		wait = wait,
		waitUntil = waitUntil,
		
		fire = fire,
		yieldingFire = yieldingFire,

		disconnectAll = disconnectAll,
		destroy = destroy,
		
		tail = nil,
		head = nil
	}
	
	return signal :: Signal<T...>
end

return table.freeze(signal)
