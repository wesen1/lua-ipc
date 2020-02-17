---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local object = require "classic"
local IncomingIpcMessage = require "ipc.Message.IncomingIpcMessage"

---
-- IpcMessageQueue that fetches each message one by one from a socket.
-- The messages must be in the format "<length> <message>".
--
-- @type IpcMessageQueue
--
local IpcMessageQueue = object:extend()


---
-- The socket from which the IpcMessageQueue will fetch the messages
--
-- @tfield Socket socket
--
IpcMessageQueue.socket = nil


---
-- IpcMessageQueue constructor.
--
-- @tparam Socket _socket The socket to fetch messages from
--
function IpcMessageQueue:new(_socket)
  self.socket = _socket
end


---
-- Fetches and returns the next message from the socket.
--
-- @treturn IncomingIpcMessage|nil The next message
--
function IpcMessageQueue:fetchNextMessage()

  local messageSizeString = ""
  local nextCharacter, receiveSocket
  repeat
    nextCharacter, receiveSocket = self.socket:receiveNextDataSegment(1, receiveSocket)
    if (nextCharacter ~= nil) then
      messageSizeString = messageSizeString .. nextCharacter
    end
  until (nextCharacter == " " or nextCharacter == nil)

  if (nextCharacter == " ") then
    local messageSize = tonumber(messageSizeString)
    local nextMessage
    nextMessage, receiveSocket = self.socket:receiveNextDataSegment(messageSize, receiveSocket)

    return IncomingIpcMessage(receiveSocket, nextMessage)
  end

end


return IpcMessageQueue
