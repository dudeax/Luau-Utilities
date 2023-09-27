-- Connection class which handles individual callbacks
local Connection = {}
Connection.__index = Connection

function Connection.new(callback, event)
	local self = setmetatable({}, Connection)

	self.event = event
	self.callback = callback

	return self
end

-- Called by the event to fire this connections callback
function Connection:_Fire(...)
	self.callback(...)
end

-- Removes the connection from the event and cleans up any references to the event and call back
function Connection:Disconnect()
	self.event:_RemoveConnection(self)
	self.event = nil
	self.callback = nil
end

-- Synonymous with Disconnect
function Connection:Destroy()
	self:Disconnect()
end


local Event = {}
Event.__index = Event

function Event.new()
	local self = setmetatable({}, Event)
	
	self.connections = {}
	
	return self
end

-- _RemoveConnection is used by connection to remove itself from the event
function Event:_RemoveConnection(connection)
	self.connections[connection] = nil
end

-- Returns a connection that can then be disconnected from later
function Event:Connect(callback)
	local connection = Connection.new(callback, self)
	self.connections[connection] = true
	return connection
end

-- Fire will call all the connected callbacks with the given parameters
function Event:Fire(...)
	for connection, _ in pairs(self.connections) do
		connection:_Fire(...)
	end
end

-- Used to remove all the connections to an event. It's safe to dereference after this.
function Event:Disconnect()
	for connection, _ in pairs(self.connections) do connection:Disconnect() end
	self.connections = nil
end

-- Synonymous with Disconnect
function Event:Destroy()
	self:Disconnect()
end

return Event
