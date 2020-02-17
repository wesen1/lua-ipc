---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Socket = require "socket.Socket"
local posix_socket = require "posix.sys.socket"

---
-- Socket implementation that uses unix domain sockets.
--
-- @type UnixSocket
--
local UnixSocket = Socket:extend()


---
-- UnixSocket constructor.
--
-- @tparam int _unixSocketFileDescriptor The unix socket file descriptor to manage by this UnixSocket (optional)
--
function UnixSocket:new(_unixSocketFileDescriptor)

  local socketFileDescriptor
  if (_unixSocketFileDescriptor) then
    socketFileDescriptor = _unixSocketFileDescriptor
  else
    socketFileDescriptor = self:createNewPosixSocket(posix_socket.AF_UNIX, posix_socket.SOCK_STREAM, 0)
  end

  self.super.new(self, socketFileDescriptor)

end


---
-- Binds this UnixSocket to a specified path.
--
-- @tparam string _path The path to bind this UnixSocket to
--
function UnixSocket:bindToPath(_path)
  self:bindToAddress({
      family = posix_socket.AF_UNIX,
      path = _path
  })
end

---
-- Connects this UnixSocket to a specified path.
--
-- @tparam string _path The path to connect this UnixSocket to
--
function UnixSocket:connectToPath(_path)
  Socket.connectToSocket(self, {
    family = posix_socket.AF_UNIX,
    path = _path
  })
end


return UnixSocket
