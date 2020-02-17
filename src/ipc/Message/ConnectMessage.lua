---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local IncomingIpcMessage = require "ipc.Message.IncomingIpcMessage"

---
-- Represents a socket connection.
--
-- @type ConnectMessage
--
local ConnectMessage = IncomingIpcMessage:extend()


---
-- ConnectMessage constructor.
--
-- @tparam Socket _connectedSocket The socket that connected
--
function ConnectMessage:new(_connectedSocket)
  ConnectMessage.super.new(self, _connectedSocket, "")
end


return ConnectMessage
