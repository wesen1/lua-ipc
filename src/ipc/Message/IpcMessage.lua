---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local object = require "classic"

---
-- Base class for IpcMessage's.
--
-- @type IpcMessage
--
local IpcMessage = object:extend()


---
-- The data of this IpcMessage
--
-- @tfield string data
--
IpcMessage.data = nil


---
-- IpcMessage constructor.
--
-- @tparam string _data The data of this IpcMessage
--
function IpcMessage:new(_data)
  self.data = _data
end


return IpcMessage
