
#!/bin/bash

apt-get update


# Required for luabitop
apt-get install -y git

apt-get install -y luarocks

# Install the dependencies
luarocks install classic
luarocks install luabitop
luarocks install luaposix
