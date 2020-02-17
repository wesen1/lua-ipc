---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ConnectMessage = require "ipc.Message.ConnectMessage"
local IpcCommunicationPartner = require "ipc.CommunicationPartner.IpcCommunicationPartner"

---
-- Accepts connections from IpcSender's and can listen for new messages.
--
local IpcReceiver = IpcCommunicationPartner:extend()


---
-- The name of this IpcReceiver
-- IpcSender's can connect to this IpcReceiver by targeting this name
--
-- @tparam string name
--
IpcReceiver.name = nil


---
-- IpcReceiver constructor.
--
-- @tparam sting _name The name of this IpcReceiver
--
function IpcReceiver:new(_name)
  self.name = _name
  self.super.new(self)
end


-- Public Methods

---
-- Initializes this IpcReceiver.
--
-- @tparam int _maximumNumberOfPendingConnections The maximum number of pending connections on the unix socket
-- @tparam function[] The custom list of event handlers (Available events are: "onMessageReceived", "onConnection")
--
function IpcReceiver:initialize(_maximumNumberOfPendingConnections, _eventHandlers)
  self.unixSocket:startListening(_maximumNumberOfPendingConnections)
  self:initializeEventHandlers(_eventHandlers)
end


---
-- A single listen cycle that checks if there is a new connection request or a new message in the message queue.
-- If there is a connection request, the connection will be accepted and the "onConnection" event will be triggerd.
-- If there is a new message the "onMessageReceived" event handler will be called.
--
function IpcReceiver:listen()

  -- Check if there is an incoming connection
  local connectedSocket = self.unixSocket:acceptConnection()
  if (connectedSocket) then
    if (self.eventHandlers["onConnection"]) then
      self.eventHandlers["onConnection"](ConnectMessage(connectedSocket))
    end
    return
  end

  self.super.listen(self)

end


-- Protected methods

---
-- Initializes the unix socket for this IpcReceiver.
-- Binds the socket to the configured name.
--
-- @tparam UnixSocket _unixSocket The unix socket to initialize
--
function IpcCommunicationPartner:initializeUnixSocket(_unixSocket)
  _unixSocket:bindToPath(self.name)
end


return IpcReceiver
