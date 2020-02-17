---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local bit = require "bit"
local object = require "classic"
local posix_socket = require "posix.sys.socket"
local posix_fcntl = require "posix.fcntl"

---
-- Wrapper for the posix socket API.
--
local Socket = object:extend()


---
-- The file descriptor of the socket that is managed by this Socket instance
--
-- @tfield int posixSocket
--
Socket.fileDescriptor = nil

---
-- Stores whether this Socket is currently in blocking mode
--
-- @tfield bool isInBlockingMode
--
Socket.isInBlockingMode = nil

---
-- Stores whether this Socket allows connections from other sockets
--
-- @tfield bool allowsConnections
--
Socket.allowsConnections = nil

---
-- The list of file descriptors of the currently connected sockets
--
-- @tfield int[] connectedSocketFileDescriptors
--
Socket.connectedSocketFileDescriptors = nil


---
-- Socket constructor.
--
-- @tparam int _socketFileDescriptor The file descriptor of the socket to manage with this Socket
--
function Socket:new(_socketFileDescriptor)
  self.fileDescriptor = _socketFileDescriptor
  self.isInBlockingMode = true
  self.allowsConnections = false
  self.connectedSocketFileDescriptors = {}
end

---
-- Creates a Socket instance from a specified socket configuration.
--
-- @tparam int _domain one of AF_INET, AF_INET6, AF_UNIX or AF_NETLINK
-- @tparam int _type one of SOCK_STREAM, SOCK_DGRAM or SOCK_RAW
-- @tparam int _options usually 0, but some socket types might implement other protocols
--
-- @treturn Socket The Socket instance
--
-- @throws error The error if the socket could not be created
--
function Socket:createNewPosixSocket(_domain, _type, _options)

  local socketFileDescriptor, errorMessage, errorNumber = posix_socket.socket(_domain, _type, _options)
  if (socketFileDescriptor == nil) then
    error("Could not create socket: " .. errorMessage .. " (" .. errorNumber .. ")")
  end

  return socketFileDescriptor

end


-- Public Methods

---
-- Enables non blocking mode for this Socket.
--
function Socket:enableNonBlockingMode()

  if (self.isInBlockingMode) then
    -- Add O_NONBLOCK to the flags and set the flags
    local currentFlags = self:getFileFlags()
    local newFlags = bit.bor(currentFlags, posix_fcntl.O_NONBLOCK)
    self:setFileFlags(newFlags)

    self.isInBlockingMode = false
  end

end

---
-- Disables non blocking mode for this Socket.
--
function Socket:disableNonBlockingMode()

  if (not self.isInBlockingMode) then
    -- Remove O_NONBLOCK from the flags and set the flags
    local currentFlags = self:getFileFlags()
    local newFlags = bit.band(currentFlags, bit.bnot(posix_fcntl.O_NONBLOCK))
    self:setFileFlags(newFlags)

    self.isInBlockingMode = true
  end

end


---
-- Accepts a single connection on this Socket.
--
-- @treturn Socket The Socket that connected to this socket
--
-- @throws error The error if the current pending connection could not be accepted
--
function Socket:acceptConnection()

  local connectedSocketFileDescriptor, errorMessage, errorNumber = posix_socket.accept(self.fileDescriptor)
  if (connectedSocketFileDescriptor == nil) then
    if (self.isInBlockingMode) then
      self:handlePosixErrorResult("Could not accept incoming connection", errorMessage, errorNumber)
    end

  else
    table.insert(self.connectedSocketFileDescriptors, connectedSocketFileDescriptor)
    return self.__index(connectedSocketFileDescriptor)
  end

end

---
-- Binds this Socket to a specified address.
--
-- @tparam table _socketAddress The socket address to bind this Socket to
--
-- @throws error The error if this Socket could not be bound to the specified socket address
--
function Socket:bindToAddress(_socketAddress)

  local success, errorMessage, errorNumber = posix_socket.bind(self.fileDescriptor, _socketAddress)
  if (success == nil) then
    self:handlePosixErrorResult("Could not bind socket to address", errorMessage, errorNumber)
  end

end

---
-- Connects this Socket to another socket.
--
-- @tparam table _socketAddress The socket address of the socket to connect this Socket to
--
-- @throws error The error if the connection to the other socket could not be established
--
function Socket:connectToSocket(_socketAddress)

  local connectResult, errorMessage, errorNumber = posix_socket.connect(self.fileDescriptor, _socketAddress)
  if (connectResult == nil) then
    self:handlePosixErrorResult("Could not connect to socket", errorMessage, errorNumber)
  end

end

---
-- Starts listening for connections on this Socket.
--
-- @tparam int _maximumNumberOfPendingConnections The maximum number of pending connections
--
-- @throws error The error if the listening for connections could not be initialized
--
function Socket:startListening(_maximumNumberOfPendingConnections)

  local listenResult, errorMessage, errorNumber = posix_socket.listen(self.fileDescriptor, _maximumNumberOfPendingConnections)
  if (listenResult == nil) then
    self:handlePosixErrorResult("Could not initialize listening for the socket", errorMessage, errorNumber)
  end

  self.allowsConnections = true

end

---
-- Reads and returns the next segment of the next message.
--
-- @tparam int _segmentSizeInBytes The size of the segment to fetch in bytes
-- @tparam Socket _receiveSocket The socket to receive the next data segment from (optional)
--
-- @treturn string The received data
-- @treturn Socket The Socket on which the data was received
--
function Socket:receiveNextDataSegment(_segmentSizeInBytes, _receiveSocket)

  local data, errorMessage, errorNumber, receiveSocket

  if (self.allowsConnections) then

    if (not _receiveSocket) then
      -- Check all connected sockets
      for i, socketFileDescriptor in ipairs(self.connectedSocketFileDescriptors) do
        data, errorMessage, errorNumber = posix_socket.recv(socketFileDescriptor, _segmentSizeInBytes)
        if (data == nil) then
          if (self.isInBlockingMode) then
            self:handlePosixErrorResult("Could not receive data", errorMessage, errorNumber)
          end

        elseif (data == "") then
          -- Socket shutdown
          table.remove(self.connectedSocketFileDescriptors, i)
          data = nil
        else
          receiveSocket = self.__index(socketFileDescriptor)
          break
        end
      end

    else
      data, errorMessage, errorNumber = posix_socket.recv(_receiveSocket.fileDescriptor, _segmentSizeInBytes)
      if (data == nil) then
        if (self.isInBlockingMode) then
          self:handlePosixErrorResult("Could not receive data", errorMessage, errorNumber)
        end
      end

      return data, _receiveSocket
    end

  else

    data, errorMessage, errorNumber = posix_socket.recv(self.fileDescriptor, _segmentSizeInBytes)
    if (data == nil) then
      if (self.isInBlockingMode) then
        self:handlePosixErrorResult("Could not receive data", errorMessage, errorNumber)
      end

    elseif (data == "") then
      -- Socket shutdown

    else
      receiveSocket = self
    end
  end


  return data, receiveSocket

end

---
-- Sends data to this Socket.
--
-- @tparam string _data The data to send
--
-- @throws error The error when the data could not be sent to this Socket
--
function Socket:sendData(_data)

  local sendResult, errorMessage, errorNumber = posix_socket.send(self.fileDescriptor, _data)
  if (sendResult == nil) then
    self:handlePosixErrorResult("Could not send data to socket", errorMessage, errorNumber)
  end

end

---
-- Shuts down this Socket.
--
-- @throws error The error when this Socket could not be shut down
--
function Socket:shutdown()
  local shutdownResult, errorMessage, errorNumber = posix_socket.shutdown(self.fileDescriptor, posix_socket.SHUT_RDWR)
  if (shutdownResult == nil) then
    self:handlePosixErrorResult("Could not shutdown socket", errorMessage, errorNumber)
  end
end


-- Private Methods

---
-- Returns the current file flags of this Socket.
--
-- @treturn int The current file flags of this Socket
--
-- @throws error The error if the flags of the socket file descriptor could not be fetched
-- @private
--
function Socket:getFileFlags()

  local currentFlags, errorMessage, errorNumber = posix_fcntl.fcntl(self.fileDescriptor, posix_fcntl.F_GETFL, 0)
  if (currentFlags == nil) then
    self:handlePosixErrorResult("Could not fetch current flags of socket file descriptor: ", errorMessage, errorNumber)
  end

  return currentFlags

end

---
-- Sets the file flags of this Socket.
--
-- @tparam int _flags The new file flags for this Socket
--
-- @throws error The error if the flags of the socket file descriptor could not be modified
-- @private
--
function Socket:setFileFlags(_flags)

  local success, errorMessage, errorNumber = posix_fcntl.fcntl(self.fileDescriptor, posix_fcntl.F_SETFL, _flags)
  if (success == nil) then
    self:handlePosixErrorResult("Could not set flags for socket file descriptor", errorMessage, errorNumber)
  end

end

---
-- Handles a posix error result.
--
-- @tparam string _errorMessage The custom error message
-- @tparam string _posixErrorMessage The posix error message
-- @tparam int _posixErrorNumber The posix error number
--
-- @throws error The error message for the error result
-- @private
--
function Socket:handlePosixErrorResult(_message, _posixErrorMessage, _posixErrorNumber)
  error(_message .. ": " .. _posixErrorMessage .. " (" .. _posixErrorNumber .. ")")
end


return Socket
