#!/usr/bin/env python3
"""
Примеры запросов к Data Vault таблицам в Iceberg.
Запускается с правильной конфигурацией AWS credentials.
"""

import os
from pyspark.sql import SparkSession

# Настройка окружения
os.environ['AWS_REGION'] = 'us-east-1'
os.environ['AWS_ACCESS_KEY_ID'] = 'minioadmin'
os.environ['AWS_SECRET_ACCESS_KEY'] = 'minioadmin'

def create_spark_session():
    """Создание Spark сессии с поддержкой Iceberg"""
    return SparkSession.builder \
        .appName("QueryExamples") \
        .config("spark.sql.catalog.iceberg", "org.apache.iceberg.spark.SparkCatalog") \
        .config("spark.sql.catalog.iceberg.type", "rest") \
        .config("spark.sql.catalog.iceberg.uri", "http://iceberg-rest:8181") \
        .config("spark.sql.catalog.iceberg.warehouse", "s3://warehouse/") \
        .config("spark.sql.catalog.iceberg.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
        .config("spark.sql.catalog.iceberg.s3.endpoint", "http://minio:9000") \
        .config("spark.sql.catalog.iceberg.s3.path-style-access", "true") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
        .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.secret.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider") \
        .getOrCreate()

def main():
    spark = create_spark_session()
    
    print("\n" + "="*80)
    print("📊 DATA WAREHOUSE STATISTICS")
    print("="*80)
    
    # 1. Показать все базы данных
    print("\n1️⃣  DATABASES:")
    print("-" * 80)
    spark.sql("SHOW DATABASES").show(truncate=False)
    
    # 2. Показать все таблицы
    print("\n2️⃣  TABLES IN dwh_detailed:")
    print("-" * 80)
    spark.sql("SHOW TABLES IN iceberg.dwh_detailed").show(truncate=False)
    
    # 3. Статистика по Hub User
    print("\n3️⃣  HUB_USER STATISTICS:")
    print("-" * 80)
    spark.sql("SELECT COUNT(*) as total_users FROM iceberg.dwh_detailed.hub_user").show()
    print("\nSample data:")
    spark.sql("SELECT * FROM iceberg.dwh_detailed.hub_user LIMIT 5").show(truncate=False)
    
    # 4. Статистика по Hub Order
    print("\n4️⃣  HUB_ORDER STATISTICS:")
    print("-" * 80)
    spark.sql("SELECT COUNT(*) as total_orders FROM iceberg.dwh_detailed.hub_order").show()
    print("\nSample data:")
    spark.sql("SELECT * FROM iceberg.dwh_detailed.hub_order LIMIT 5").show(truncate=False)
    
    # 5. Статистика по Satellite User Profile
    print("\n5️⃣  SAT_USER_PROFILE STATISTICS:")
    print("-" * 80)
    spark.sql("SELECT COUNT(*) as total_profiles FROM iceberg.dwh_detailed.sat_user_profile").show()
    print("\nSample data:")
    spark.sql("SELECT * FROM iceberg.dwh_detailed.sat_user_profile LIMIT 5").show(truncate=False)
    
    # 6. Статистика по Satellite Order Details
    print("\n6️⃣  SAT_ORDER_DETAILS STATISTICS:")
    print("-" * 80)
    spark.sql("SELECT COUNT(*) as total_order_details FROM iceberg.dwh_detailed.sat_order_details").show()
    print("\nSample data:")
    spark.sql("SELECT * FROM iceberg.dwh_detailed.sat_order_details LIMIT 5").show(truncate=False)
    
    # 7. Статистика по Link User-Order
    print("\n7️⃣  LINK_USER_ORDER STATISTICS:")
    print("-" * 80)
    spark.sql("SELECT COUNT(*) as total_links FROM iceberg.dwh_detailed.link_user_order").show()
    print("\nSample data:")
    spark.sql("SELECT * FROM iceberg.dwh_detailed.link_user_order LIMIT 5").show(truncate=False)
    
    # 8. Бизнес-запрос: Пользователи с их заказами
    print("\n8️⃣  BUSINESS VIEW: Users with Orders:")
    print("-" * 80)
    query = """
    SELECT 
        u.user_external_id,
        up.email,
        up.first_name,
        up.last_name,
        o.order_external_id,
        od.total_amount,
        od.order_date
    FROM iceberg.dwh_detailed.hub_user u
    JOIN iceberg.dwh_detailed.link_user_order l ON u.hub_user_id = l.hub_user_id
    JOIN iceberg.dwh_detailed.hub_order o ON l.hub_order_id = o.hub_order_id
    LEFT JOIN iceberg.dwh_detailed.sat_user_profile up ON u.hub_user_id = up.hub_user_id AND up.is_current = true
    LEFT JOIN iceberg.dwh_detailed.sat_order_details od ON o.hub_order_id = od.hub_order_id AND od.is_current = true
    LIMIT 10
    """
    spark.sql(query).show(truncate=False)
    
    print("\n" + "="*80)
    print("✅ QUERY EXAMPLES COMPLETED")
    print("="*80 + "\n")
    
    spark.stop()

if __name__ == "__main__":
    main()
