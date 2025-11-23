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
