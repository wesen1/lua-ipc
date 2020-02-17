---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local IpcMessage = require "ipc.Message.IpcMessage"

---
-- Represents an outgoing IPC message.
--
-- @type OutgoingIpcMessage
--
local OutgoingIpcMessage = IpcMessage:extend()


---
-- The socket to which this OutgoingIpcMessage will be sent
--
-- @tfield Socket targetSocket
--
OutgoingIpcMessage.targetSocket = nil


---
-- OutgoingIpcMessage constructor.
--
-- @tfield Socket _targetSocket The socket to which this OutgoingIpcMessage will be sent
-- @tfield string _data The data to send
--
function OutgoingIpcMessage:new(_targetSocket, _data)
  OutgoingIpcMessage.super.new(self, _data)
  self.targetSocket = _targetSocket
end


---
-- Sends this OutgoingIpcMessage to the target socket.
--
function OutgoingIpcMessage:send()
  self.targetSocket:sendData(#self.data .. " " .. self.data)
end


return OutgoingIpcMessage
