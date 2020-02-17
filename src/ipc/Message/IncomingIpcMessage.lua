---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local IpcMessage = require "ipc.Message.IpcMessage"
local OutgoingIpcMessage = require "ipc.Message.OutgoingIpcMessage"

---
-- Represents an incoming IPC message.
--
-- @type IncomingIpcMessage
--
local IncomingIpcMessage = IpcMessage:extend()


---
-- The socket on which the message was received
--
-- @tfield Socket receiveSocket
--
IncomingIpcMessage.receiveSocket = nil


---
-- IncomingIpcMessage constructor.
--
-- @tparam Socket _receiveSocket The socket on which this IncomingIpcMessage was received
-- @tparam string _data The data that was sent
--
function IncomingIpcMessage:new(_receiveSocket, _data)
  IncomingIpcMessage.super.new(self, _data)
  self.receiveSocket = _receiveSocket
end


---
-- Sends a response to the sender of this IncomingIpcMessage.
--
-- @tparam string _data The data to respond to this IncomingIpcMessage with
--
function IncomingIpcMessage:respond(_data)
  local responseMessage = OutgoingIpcMessage(self.receiveSocket, _data)
  responseMessage:send()
end


return IncomingIpcMessage
