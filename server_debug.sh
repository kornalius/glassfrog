#!/bin/zsh

function finish {
  pkill -f redis-server
  pkill -f grunt
  pkill -f mongod
  pkill -f node
}

trap finish EXIT

mongod --dbpath ./server/data/db &

redis-server &

grunt debug --noserver
