---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local IpcCommunicationPartner = require "ipc.CommunicationPartner.IpcCommunicationPartner"
local OutgoingIpcMessage = require "ipc.Message.OutgoingIpcMessage"

---
-- Connects to and sends messages to a IpcReceiver and can listen for its responses.
-- Requires a message receiver that runs in a different process to which it can connect.
--
local IpcSender = IpcCommunicationPartner:extend()


---
-- The target path to connect this IpcSender to
--
-- @tfield string targetPath
--
IpcSender.targetPath = nil


---
-- IpcSender constructor.
--
-- @tparam string _targetPath The target path to connect this IpcSender to
--
function IpcSender:new(_targetPath)
  self.targetPath = _targetPath
  self.super.new(self)
end


-- Public Methods

---
-- Initializes this IpcSender.
--
-- @tparam function[] The custom list of event handlers (Available events are: "onMessageReceived")
--
function IpcSender:initialize(_eventHandlers)
  self:initializeEventHandlers(_eventHandlers)
end

---
-- Sends data to the configured target path.
--
-- @tparam string _data The data to send
--
function IpcSender:sendData(_data)
  local message = OutgoingIpcMessage(self.unixSocket, _data, self.targetPath)
  message:send()
end


-- Protected methods

---
-- Initializes the unix socket for this IpcSender.
-- Connects the socket to the configured target path.
--
-- @tparam UnixSocket _unixSocket The unix socket to initialize
--
function IpcSender:initializeUnixSocket(_unixSocket)
  _unixSocket:connectToPath(self.targetPath)
end


return IpcSender
