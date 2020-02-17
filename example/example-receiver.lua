---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

package.path = package.path .. ";../src/?.lua";

local socket = require "socket"
local IpcReceiver = require "ipc.CommunicationPartner.IpcReceiver"

local function onConnection(_connectMessage)
  print("Got a connection")
  _connectMessage:respond("Welcome")
end

local function onMessageReceived(_message)
  print("Received data \"" .. _message.data .. "\" from socket " .. _message.receiveSocket.fileDescriptor)
end


local receiver = IpcReceiver("\0gema_scores")
receiver:initialize(
  20,
  {
    ["onConnection"] = onConnection,
    ["onMessageReceived"] = onMessageReceived
  }
)


while (true) do
  receiver:listen()
  socket.sleep(0.001)
end
