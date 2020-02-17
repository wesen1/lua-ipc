---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

package.path = package.path .. ";../src/?.lua";

local IpcSender = require "ipc.CommunicationPartner.IpcSender"
local socket = require "socket"

local receivedResponse = false

local function onMessageReceived(_message)
  print("Received data \"" .. _message.data .. "\" from socket " .. _message.receiveSocket.fileDescriptor)
  receivedResponse = true
end

local sender = IpcSender("\0gema_scores")
sender:initialize({
    ["onMessageReceived"] = onMessageReceived
})


local uniqueId = os.time()
sender:sendData("Hello from " .. uniqueId)

local numberOfSentMessages = 0
while (numberOfSentMessages < 10 or not receivedResponse) do

  sender:listen()

  if (numberOfSentMessages < 10) then
    numberOfSentMessages = numberOfSentMessages + 1

    print("Sending message #" .. numberOfSentMessages)
    sender:sendData("Message #" .. numberOfSentMessages .. " from " .. uniqueId)
  end

  socket.sleep(0.01)

end
