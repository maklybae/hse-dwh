import os
import time
import logging
from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, lit, current_timestamp, sha2, concat_ws, get_json_object, expr
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, TimestampType, BooleanType, DoubleType

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

KAFKA_BOOTSTRAP_SERVERS = os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'kafka:9092')
MINIO_ENDPOINT = os.getenv('MINIO_ENDPOINT', 'http://minio:9000')
MINIO_ACCESS_KEY = os.getenv('MINIO_ACCESS_KEY', 'minioadmin')
MINIO_SECRET_KEY = os.getenv('MINIO_SECRET_KEY', 'minioadmin')
HIVE_METASTORE_URI = os.getenv('HIVE_METASTORE_URI', 'thrift://hive-metastore:9083')

def create_spark_session():
    logger.info("Creating Spark session...")
    
    spark = SparkSession.builder \
        .appName("DWH-DMP-DataVault") \
        .config("spark.sql.catalog.iceberg", "org.apache.iceberg.spark.SparkCatalog") \
        .config("spark.sql.catalog.iceberg.type", "hive") \
        .config("spark.sql.catalog.iceberg.uri", HIVE_METASTORE_URI) \
        .config("spark.sql.catalog.iceberg.warehouse", "s3a://warehouse/") \
        .config("spark.sql.catalog.iceberg.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
        .config("spark.sql.catalog.iceberg.s3.endpoint", MINIO_ENDPOINT) \
        .config("spark.sql.catalog.iceberg.s3.path-style-access", "true") \
        .config("spark.hadoop.fs.s3a.endpoint", MINIO_ENDPOINT) \
        .config("spark.hadoop.fs.s3a.access.key", MINIO_ACCESS_KEY) \
        .config("spark.hadoop.fs.s3a.secret.key", MINIO_SECRET_KEY) \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false") \
        .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
        .config("spark.sql.defaultCatalog", "iceberg") \
        .getOrCreate()
    
    logger.info("Spark session created successfully")
    return spark

def create_dwh_database(spark):
    logger.info("Creating DWH database...")
    spark.sql("CREATE DATABASE IF NOT EXISTS iceberg.dwh_detailed")
    logger.info("Database created")

def create_hub_user(spark):
    logger.info("Creating hub_user table...")
    
    spark.sql("""
        CREATE TABLE IF NOT EXISTS iceberg.dwh_detailed.hub_user (
            hub_user_id STRING,
            user_external_id STRING,
            source_system_id STRING,
            load_date TIMESTAMP,
            loaded_by STRING
        )
        USING iceberg
        TBLPROPERTIES (
            'write.format.default' = 'parquet',
            'write.parquet.compression-codec' = 'snappy'
        )
    """)
    logger.info("hub_user table created")

def create_hub_order(spark):
    logger.info("Creating hub_order table...")
    
    spark.sql("""
        CREATE TABLE IF NOT EXISTS iceberg.dwh_detailed.hub_order (
            hub_order_id STRING,
            order_external_id STRING,
            source_system_id STRING,
            load_date TIMESTAMP,
            loaded_by STRING
        )
        USING iceberg
        TBLPROPERTIES (
            'write.format.default' = 'parquet',
            'write.parquet.compression-codec' = 'snappy'
        )
    """)
    logger.info("hub_order table created")

def create_sat_user_profile(spark):
    logger.info("Creating sat_user_profile table...")
    
    spark.sql("""
        CREATE TABLE IF NOT EXISTS iceberg.dwh_detailed.sat_user_profile (
            sat_id STRING,
            hub_user_id STRING,
            email STRING,
            first_name STRING,
            last_name STRING,
            phone STRING,
            date_of_birth DATE,
            registration_date TIMESTAMP,
            load_date TIMESTAMP,
            load_end_date TIMESTAMP,
            is_current BOOLEAN,
            source_system_id STRING,
            loaded_by STRING,
            hash_diff STRING
        )
        USING iceberg
        TBLPROPERTIES (
            'write.format.default' = 'parquet',
            'write.parquet.compression-codec' = 'snappy'
        )
    """)
    logger.info("sat_user_profile table created")

def create_sat_order_details(spark):
    logger.info("Creating sat_order_details table...")
    
    spark.sql("""
        CREATE TABLE IF NOT EXISTS iceberg.dwh_detailed.sat_order_details (
            sat_id STRING,
            hub_order_id STRING,
            order_number STRING,
            order_date TIMESTAMP,
            subtotal DOUBLE,
            tax_amount DOUBLE,
            shipping_cost DOUBLE,
            discount_amount DOUBLE,
            total_amount DOUBLE,
            currency STRING,
            load_date TIMESTAMP,
            load_end_date TIMESTAMP,
            is_current BOOLEAN,
            source_system_id STRING,
            loaded_by STRING,
            hash_diff STRING
        )
        USING iceberg
        TBLPROPERTIES (
            'write.format.default' = 'parquet',
            'write.parquet.compression-codec' = 'snappy'
        )
    """)
    logger.info("sat_order_details table created")

def create_link_user_order(spark):
    logger.info("Creating link_user_order table...")
    
    spark.sql("""
        CREATE TABLE IF NOT EXISTS iceberg.dwh_detailed.link_user_order (
            link_user_order_id STRING,
            hub_user_id STRING,
            hub_order_id STRING,
            source_system_id STRING,
            load_date TIMESTAMP,
            loaded_by STRING
        )
        USING iceberg
        TBLPROPERTIES (
            'write.format.default' = 'parquet',
            'write.parquet.compression-codec' = 'snappy'
        )
    """)
    logger.info("link_user_order table created")

def init_dwh_schema(spark):
    logger.info("Initializing DWH schema...")
    
    create_dwh_database(spark)
    
    # Создание Hubs
    create_hub_user(spark)
    create_hub_order(spark)
    
    # Создание Satellites
    create_sat_user_profile(spark)
    create_sat_order_details(spark)
    
    # Создание Links
    create_link_user_order(spark)
    
    logger.info("DWH schema initialized successfully")

def process_user_events(spark):
    """Обработка событий пользователей из Kafka"""
    logger.info("Starting user events processing...")
    
    # Схема Debezium события для пользователей
    user_schema = StructType([
        StructField("user_id", IntegerType(), True),
        StructField("user_external_id", StringType(), True),
        StructField("email", StringType(), True),
        StructField("first_name", StringType(), True),
        StructField("last_name", StringType(), True),
        StructField("phone", StringType(), True),
        StructField("date_of_birth", StringType(), True),
        StructField("registration_date", TimestampType(), True),
        StructField("status", StringType(), True),
        StructField("created_at", TimestampType(), True),
        StructField("updated_at", TimestampType(), True)
    ])
    
    # Чтение из Kafka
    df = spark.readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", KAFKA_BOOTSTRAP_SERVERS) \
        .option("subscribe", "debezium-user-service.public.users") \
        .option("startingOffsets", "earliest") \
        .load()
    
    # Парсинг JSON из Kafka - Debezium формат
    parsed_df = df.select(
        get_json_object(col("value").cast("string"), "$.payload.after.user_external_id").alias("user_external_id"),
        get_json_object(col("value").cast("string"), "$.payload.after.email").alias("email"),
        get_json_object(col("value").cast("string"), "$.payload.after.first_name").alias("first_name"),
        get_json_object(col("value").cast("string"), "$.payload.after.last_name").alias("last_name"),
        get_json_object(col("value").cast("string"), "$.payload.after.phone").alias("phone"),
        get_json_object(col("value").cast("string"), "$.payload.after.date_of_birth").cast("int").alias("date_of_birth_days"),
        get_json_object(col("value").cast("string"), "$.payload.after.registration_date").cast("long").alias("registration_date_us"),
        get_json_object(col("value").cast("string"), "$.payload.after.status").alias("status")
    ).filter(col("user_external_id").isNotNull())
    
    hub_df = parsed_df.select(
        sha2(col("user_external_id"), 256).alias("hub_user_id"),
        col("user_external_id"),
        lit("user-service").alias("source_system_id"),
        current_timestamp().alias("load_date"),
        lit("dmp-spark").alias("loaded_by")
    ).dropDuplicates(["user_external_id"])
    
    hub_query = hub_df.writeStream \
        .format("iceberg") \
        .outputMode("append") \
        .option("checkpointLocation", "/tmp/checkpoint/hub_user") \
        .option("path", "iceberg.dwh_detailed.hub_user") \
        .start()
    
    # Создание Satellite записей
    sat_df = parsed_df.select(
        sha2(concat_ws("_", col("user_external_id"), current_timestamp()), 256).alias("sat_id"),
        sha2(col("user_external_id"), 256).alias("hub_user_id"),
        col("email"),
        col("first_name"),
        col("last_name"),
        col("phone"),
        expr("date_add(to_date('1970-01-01'), date_of_birth_days)").alias("date_of_birth"),
        expr("timestamp_micros(registration_date_us)").alias("registration_date"),
        current_timestamp().alias("load_date"),
        lit(None).cast("timestamp").alias("load_end_date"),
        lit(True).alias("is_current"),
        lit("user-service").alias("source_system_id"),
        lit("dmp-spark").alias("loaded_by"),
        sha2(concat_ws("|", col("email"), col("first_name"), col("last_name"), col("phone"), col("status")), 256).alias("hash_diff")
    )
    
    # Запись в Satellite
    sat_query = sat_df.writeStream \
        .format("iceberg") \
        .outputMode("append") \
        .option("checkpointLocation", "/tmp/checkpoint/sat_user_profile") \
        .option("path", "iceberg.dwh_detailed.sat_user_profile") \
        .start()
    
    return [hub_query, sat_query]

def process_order_events(spark):
    """Обработка событий заказов из Kafka"""
    logger.info("Starting order events processing...")
    
    # Схема Debezium события для заказов
    order_schema = StructType([
        StructField("order_id", IntegerType(), True),
        StructField("order_external_id", StringType(), True),
        StructField("user_external_id", StringType(), True),
        StructField("order_number", StringType(), True),
        StructField("order_date", TimestampType(), True),
        StructField("status", StringType(), True),
        StructField("subtotal", DoubleType(), True),
        StructField("tax_amount", DoubleType(), True),
        StructField("shipping_cost", DoubleType(), True),
        StructField("discount_amount", DoubleType(), True),
        StructField("total_amount", DoubleType(), True),
        StructField("currency", StringType(), True)
    ])
    
    # Чтение из Kafka
    df = spark.readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", KAFKA_BOOTSTRAP_SERVERS) \
        .option("subscribe", "debezium-order-service.public.orders") \
        .option("startingOffsets", "earliest") \
        .load()
    
    # Парсинг JSON - Debezium формат
    parsed_df = df.select(
        get_json_object(col("value").cast("string"), "$.payload.after.order_external_id").alias("order_external_id"),
        get_json_object(col("value").cast("string"), "$.payload.after.user_external_id").alias("user_external_id"),
        get_json_object(col("value").cast("string"), "$.payload.after.order_number").alias("order_number"),
        get_json_object(col("value").cast("string"), "$.payload.after.order_date").cast("long").alias("order_date_us"),
        get_json_object(col("value").cast("string"), "$.payload.after.status").alias("status"),
        get_json_object(col("value").cast("string"), "$.payload.after.subtotal").cast("double").alias("subtotal"),
        get_json_object(col("value").cast("string"), "$.payload.after.tax_amount").cast("double").alias("tax_amount"),
        get_json_object(col("value").cast("string"), "$.payload.after.shipping_cost").cast("double").alias("shipping_cost"),
        get_json_object(col("value").cast("string"), "$.payload.after.discount_amount").cast("double").alias("discount_amount"),
        get_json_object(col("value").cast("string"), "$.payload.after.total_amount").cast("double").alias("total_amount"),
        get_json_object(col("value").cast("string"), "$.payload.after.currency").alias("currency")
    ).filter(col("order_external_id").isNotNull())
    
    hub_df = parsed_df.select(
        sha2(col("order_external_id"), 256).alias("hub_order_id"),
        col("order_external_id"),
        lit("order-service").alias("source_system_id"),
        current_timestamp().alias("load_date"),
        lit("dmp-spark").alias("loaded_by")
    ).dropDuplicates(["order_external_id"])
    
    hub_query = hub_df.writeStream \
        .format("iceberg") \
        .outputMode("append") \
        .option("checkpointLocation", "/tmp/checkpoint/hub_order") \
        .option("path", "iceberg.dwh_detailed.hub_order") \
        .start()
    
    # Satellite Order Details
    sat_df = parsed_df.select(
        sha2(concat_ws("_", col("order_external_id"), current_timestamp()), 256).alias("sat_id"),
        sha2(col("order_external_id"), 256).alias("hub_order_id"),
        col("order_number"),
        expr("timestamp_micros(order_date_us)").alias("order_date"),
        col("subtotal"),
        col("tax_amount"),
        col("shipping_cost"),
        col("discount_amount"),
        col("total_amount"),
        col("currency"),
        current_timestamp().alias("load_date"),
        lit(None).cast("timestamp").alias("load_end_date"),
        lit(True).alias("is_current"),
        lit("order-service").alias("source_system_id"),
        lit("dmp-spark").alias("loaded_by"),
        sha2(concat_ws("|", col("order_number"), col("subtotal"), col("tax_amount"), col("shipping_cost"), col("discount_amount"), col("total_amount"), col("currency")), 256).alias("hash_diff")
    )
    
    sat_query = sat_df.writeStream \
        .format("iceberg") \
        .outputMode("append") \
        .option("checkpointLocation", "/tmp/checkpoint/sat_order_details") \
        .option("path", "iceberg.dwh_detailed.sat_order_details") \
        .start()
    
    # Link User-Order
    link_df = parsed_df.select(
        sha2(concat_ws("_", col("user_external_id"), col("order_external_id")), 256).alias("link_user_order_id"),
        sha2(col("user_external_id"), 256).alias("hub_user_id"),
        sha2(col("order_external_id"), 256).alias("hub_order_id"),
        lit("order-service").alias("source_system_id"),
        current_timestamp().alias("load_date"),
        lit("dmp-spark").alias("loaded_by")
    ).dropDuplicates(["hub_user_id", "hub_order_id"])
    
    link_query = link_df.writeStream \
        .format("iceberg") \
        .outputMode("append") \
        .option("checkpointLocation", "/tmp/checkpoint/link_user_order") \
        .option("path", "iceberg.dwh_detailed.link_user_order") \
        .start()
    
    return [hub_query, sat_query, link_query]

def main():
    logger.info("Starting DMP service...")
    
    try:
        spark = create_spark_session()
        
        init_dwh_schema(spark)
        
        user_queries = process_user_events(spark)
        order_queries = process_order_events(spark)
        
        all_queries = user_queries + order_queries
        
        logger.info(f"Started {len(all_queries)} streaming queries")
        
        for query in all_queries:
            query.awaitTermination()
            
    except Exception as e:
        logger.error(f"Error in DMP: {e}", exc_info=True)
        raise
    finally:
        logger.info("DMP service stopped")

if __name__ == "__main__":
    main()
