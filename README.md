# Задание 2

## Как запустить

Запускаем mongodb и приложение

```shell
cd ./mongo-sharding/ 
docker compose up -d

```

Запускаем процесс инициализации шардов и заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

# Задание 3

## Как запустить

Запускаем mongodb и приложение

```shell
cd ./mongo-sharding-repl/ 
docker compose up -d

```

Запускаем процесс инициализации шардов и заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```