# ДЗ-1

## Поднятие баз данных

Для поднятия всех баз данных выполните команду:

```bash
docker-compose up -d
```

Для остановки всех контейнеров выполните команду:

```bash
docker-compose down
```

Для просмотра логов всех контейнеров выполните команду:

```bash
docker-compose logs -f
```

## Вставка моковых данных

```bash
./load_csv.sh ~/Downloads/mock_data/order_service_orders.csv ORDERS postgresql://postgres:postgres@localhost:5433/postgres
```
