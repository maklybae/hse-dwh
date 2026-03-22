from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.exceptions import AirflowException
from docker.types import Mount
from datetime import datetime, timedelta
import os
import uuid

DBT_IMAGE = os.environ.get("DBT_IMAGE", "dwh-dbt:latest")
DWH_NETWORK = os.environ.get("DWH_NETWORK", "dwh-net")
SPARK_DRIVER_HOST = os.environ.get(
    "SPARK_DRIVER_HOST",
    f"dwh-dbt-airflow-{uuid.uuid4().hex[:8]}",
)

# Host path visible to Docker daemon (not path inside Airflow container).
# Example: /Users/<user>/Programming/hse-dwh/hw03
DWH_HOST_ROOT = os.environ.get("DWH_HOST_ROOT")

if not DWH_HOST_ROOT:
    raise AirflowException(
        "DWH_HOST_ROOT is not set. Set it to absolute host path, e.g. /Users/<user>/Programming/hse-dwh/hw03"
    )

SPARK_CONF_HOST_PATH = f"{DWH_HOST_ROOT}/dwh-spark/conf"
DBT_PROJECT_HOST_PATH = f"{DWH_HOST_ROOT}/dbt/marketplace"

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='dbt_warehouse_delivery_mart',
    default_args=default_args,
    description='Daily refresh of warehouse delivery performance mart',
    start_date=datetime(2024, 1, 2),
    schedule='@daily',
    catchup=False,
    max_active_runs=1,
    tags=['dbt', 'presentation', 'warehouse_delivery'],
) as dag:

    build_warehouse_delivery_mart = DockerOperator(
        task_id='build_warehouse_delivery_mart',
        image=DBT_IMAGE,
        container_name=SPARK_DRIVER_HOST,
        hostname=SPARK_DRIVER_HOST,
        command=[
            'build',
            '--profiles-dir', '.',
            '--select', '+fct_warehouse_delivery_daily',  # + включает upstream зависимости
            '--vars', '{"business_date": "{{ ds }}"}',  # ds = execution_date в формате YYYY-MM-DD
        ],
        network_mode=DWH_NETWORK,
        mounts=[
            Mount(
                source=SPARK_CONF_HOST_PATH,
                target='/opt/spark/conf',
                type='bind',
                read_only=True,
            ),
            Mount(
                source=DBT_PROJECT_HOST_PATH,
                target='/dbt/project',
                type='bind',
            ),
        ],
        environment={
            'SPARK_HOME': '/opt/spark',
            'SPARK_CONF_DIR': '/opt/spark/conf',
            'AWS_REGION': 'us-east-1',
            'SPARK_DRIVER_HOST': SPARK_DRIVER_HOST,
        },
        docker_url='unix://var/run/docker.sock',
        auto_remove='success',
        mount_tmp_dir=False,
    )
