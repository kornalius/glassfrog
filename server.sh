#!/bin/zsh

function finish {
  pkill -f redis-server
  pkill -f grunt
  pkill -f mongod
  pkill -f node
}

trap finish EXIT

/opt/local/bin/mongod --dbpath ./server/data/db &

redis-server &

/opt/local/bin/grunt
