---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local object = require "classic"
local IpcMessageQueue = require "ipc.IpcMessageQueue"
local UnixSocket = require "socket.UnixSocket"

---
-- Base class for a IPC communication partner.
--
-- @type IpcCommunicationPartner
--
local IpcCommunicationPartner = object:extend()


---
-- The list of event handlers
-- Available events are: "onMessageReceived"
--
-- @tfield function[] eventHandlers
--
IpcCommunicationPartner.eventHandlers = {}

---
-- The message queue that will be used to receive messages from the other communication partner
--
-- @tfield IpcMessageQueue messageQueue
--
IpcCommunicationPartner.messageQueue = nil

---
-- The unix socket that will be used to connect to the other communication partner
--
-- @tfield UnixSocket unixSocket
--
IpcCommunicationPartner.unixSocket = nil


---
-- IpcCommunicationPartner constructor.
--
function IpcCommunicationPartner:new()
  self.unixSocket = UnixSocket()
  self.unixSocket:enableNonBlockingMode()
  self:initializeUnixSocket(self.unixSocket)

  self.messageQueue = IpcMessageQueue(self.unixSocket)
end


-- Public Methods

---
-- A single listen cycle that checks if there is a new message in the message queue.
-- If there is the "onMessageReceived" event handler will be called.
--
function IpcCommunicationPartner:listen()

  local nextMessage = self.messageQueue:fetchNextMessage()
  if (nextMessage ~= nil) then
    if (self.eventHandlers["onMessageReceived"]) then
      self.eventHandlers["onMessageReceived"](nextMessage)
    end
  end

end


-- Protected Methods

---
-- Initializes the unix socket for this communication partner.
--
-- @tparam UnixSocket _unixSocket The unix socket to initialize
--
function IpcCommunicationPartner:initializeUnixSocket(_unixSocket)
end

---
-- Initializes the event handlers based on a custom list of event handlers.
--
-- @tfield function[] _eventHandlers The custom list of event handlers
--
function IpcCommunicationPartner:initializeEventHandlers(_eventHandlers)
  if (type(_eventHandlers) == "table") then
    self.eventHandlers = _eventHandlers
  end
end


return IpcCommunicationPartner
