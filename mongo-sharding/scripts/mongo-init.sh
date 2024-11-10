#!/bin/bash

###
# Инициализируем сервера конфигурации
###
printf 'Инициализия сервера конфигурации\n'
docker compose exec -T configSrv mongosh --port 27017  --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF

sleep 5

###
# Инициализируем шард #1
###

printf 'Инициализия шард #1\n'
docker compose exec -T shard1 mongosh --port 27018  --quiet <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27018" },
      ]
    }
);
EOF

sleep 5

###
# Инициализируем шард #2
###

printf 'Инициализия шард #2\n'
docker compose exec -T shard2 mongosh --port 27019  --quiet <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 1, host : "shard2:27019" }
      ]
    }
  );
EOF

sleep 5

###
# Инициализируем роутер и наполните его тестовыми данными
###
printf 'Инициализия роута, наполнения данными\n'

docker compose exec -T mongos_router mongosh --port 27020  --quiet <<EOF
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
EOF

sleep 20

printf 'Документов в БД: \n'
docker compose exec -T mongos_router mongosh --port 27020  --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF
sleep 5

###
# Кол-во документов на шарде #1
###
printf 'Документов на шарде #1: \n'
docker compose exec -T shard1 mongosh --port 27018  --quiet <<EOF

use somedb
db.helloDoc.countDocuments()
EOF
sleep 5

###
# Кол-во документов на шарде #2
###
printf 'Документов на шарде #2: \n'
docker compose exec -T shard2 mongosh --port 27019  --quiet <<EOF

use somedb
db.helloDoc.countDocuments()
EOF
printf '\n '