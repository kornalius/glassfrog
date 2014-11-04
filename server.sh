#!/bin/zsh

function finish {
  pkill -f redis-server
  pkill -f grunt
  pkill -f mongod
  pkill -f node
  pkill -f node-inspector
}

trap finish EXIT

mongod --dbpath ./server/data/db &

redis-server &

node-inspector --web-host localhost --web-port 8080 --debug-port 5858 --no-preload --stack-trace-limit 250 &

grunt
