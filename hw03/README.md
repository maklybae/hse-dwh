# ДЗ-3: Финалочка

## Основная информация

**Состав команды:**

- Зенин Вадим (tg: [@zuganin](https://t.me/zuganin))
- Клычков Максим (tg: [@maklybae](https://t.me/maklybae))
- Сёмкин Арсений (tg: [@arsemkin](https://t.me/arsemkin))

**Выполненные пункты задания:**

- [Поднят Airflow](airflow/)
- [ETL для витрины 1 через dbt](dbt/marketplace/models/presentation/fct_purchase_analytics_daily.sql)
- [ETL для витрины 2 через dbt](dbt/marketplace/models/presentation/fct_warehouse_delivery_daily.sql)
- [Поднята BI-система Metabase](docker-compose-dwh.yaml)
- Для реализации ETL использован dbt

## Быстрый старт

1. Создать сети docker:

```bash
./scripts/create-networks.sh
```

2. Поднять DWH инфраструктуру:

```bash
docker-compose -f docker-compose-dwh.yaml up
```

3. Поднять все остальное (OLTP, Kafka, Debezium):

```bash
docker-compose -f docker-compose.yaml up
```

4. Поднять Airflow:

```bash
DWH_HOST_ROOT=<локальный абсолютный путь до hw03> docker-compose -f airflow/docker-compose.yaml up
```

5. Вставить [тестовые данные](https://clck.ru/3QCYgU):

```bash
./scripts/load_all_csv.sh ~/path/to/mock_data
```

При выполнении скрипта загружается одновременно достаточно большой объём данных (у нас это занимало ~1-1.5 минуты), наблюдали в админке minio и логах коннектора, как данные поступают в Iceberg-таблицы.

6. Построить детальный слой DWH:

Или запустить DAG dbt_pipeline в [Airflow](http://localhost:80)

7*. Spark SQL для проверки:

```sql
./scripts/spark-sql.sh
```

8. Построить витрины

Через DAG в [Airflow](http://localhost:80)

- [dbt_purchase_analytics_mart](airflow/dags/dbt_purchase_analytics_mart.py)
- [dbt_warehouse_delivery_mart](airflow/dags/dbt_warehouse_delivery_mart.py)

9.  Остановить:

```bash
docker-compose -f airflow/docker-compose.yaml down -v
docker-compose down -v
docker-compose -f docker-compose-dwh.yaml down -v
```

## Подключение к [Metabase](http://localhost:3000)

Для подключения к metabase необходимо использовать

- host: `spark-thrift-server`
- port: `10000`
- database: `presentation`

### Web UI

| Сервис               | URL                   | Описание                             |
| -------------------- | --------------------- | ------------------------------------ |
| MinIO Console        | http://localhost:9001 | S3-хранилище (minioadmin/minioadmin) |
| Iceberg REST Catalog | http://localhost:8181 | REST API каталога                    |
| Spark Master         | http://localhost:8080 | Spark кластер                        |
| Spark Worker         | http://localhost:8081 | Worker node                          |
| Airflow              | http://localhost:80   | Оркестрация ETL                      |
| Metabase             | http://localhost:3000 | BI-система                           |
