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

## Строки подключения

### user-service-db (порт 5432)
```
postgresql://postgres:postgres@localhost:5432/postgres
```

### order-service-db (порт 5433)
```
postgresql://postgres:postgres@localhost:5433/postgres
```

### logistics-service-db (порт 5434)
```
postgresql://postgres:postgres@localhost:5434/postgres
```

## HA-Postgres кластеры

Для каждого кластера поднято по три ноды PostgreSQL с репликацией и автоматическим failover с помощью Patroni и Etcd. Все подключения происходят через HAProxy, который балансирует нагрузку между нодами.

Рассмотрим топологию кластера order-service-db, остальные кластеры устроены аналогично.

Для подключения к кластеру используем HAProxy, который слушает порт 5432 на localhost и балансирует нагрузку между тремя нодами PostgreSQL. Сейчас вся нагрузка направляется в мастер ноду (в текущей конфигурации HAProxy только мастер нода active). Можно улучшить этот момент и отдавать отдельные порты для чтения (реплики) и записи (мастер).

HAProxy поллит 8008 порты, на которых располагается апишка patroni (`GET /` — return HTTP status code 200 only when the Patroni node is running as the primary with leader lock).

## Миграции

Для миграций используется простая утилита `goose`, которая запускается после поднятия кластера через HAProxy.

## Когортный анализ

### Выполнение SQL-скрипта когортного анализа

```bash
psql "postgresql://postgres:postgres@localhost:5433/postgres" -f order-service-db/queries/cohort_analysis.sql
```

### Создание и использование VIEW

Создать VIEW:
```bash
psql "postgresql://postgres:postgres@localhost:5433/postgres" -f order-service-db/queries/cohort_analysis_view.sql
```

Запросить данные из VIEW:
```bash
psql "postgresql://postgres:postgres@localhost:5433/postgres" -c "SELECT * FROM cohort_analysis_view ORDER BY cohort_month;"
```
