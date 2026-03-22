from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.exceptions import AirflowException
from docker.types import Mount
from datetime import datetime
import os

DBT_IMAGE = os.environ.get("DBT_IMAGE", "dwh-dbt:latest")
DWH_NETWORK = os.environ.get("DWH_NETWORK", "dwh-net")

# Host path visible to Docker daemon (not path inside Airflow container).
# Example: /Users/<user>/Programming/hse-dwh/hw03
DWH_HOST_ROOT = os.environ.get("DWH_HOST_ROOT")

if not DWH_HOST_ROOT:
    raise AirflowException(
        "DWH_HOST_ROOT is not set. Set it to absolute host path, e.g. /Users/<user>/Programming/hse-dwh/hw03"
    )

SPARK_CONF_HOST_PATH = f"{DWH_HOST_ROOT}/dwh-spark/conf"
DBT_PROJECT_HOST_PATH = f"{DWH_HOST_ROOT}/dbt/marketplace"

with DAG(
    dag_id='dbt_pipeline',
    start_date=datetime(2024, 1, 1),
    schedule='@daily',
    catchup=False,
) as dag:

    dbt_run = DockerOperator(
        task_id='dbt_run',
        image=DBT_IMAGE,
        command=['build', '--profiles-dir', '.'],
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
        },
        docker_url='unix://var/run/docker.sock',
        auto_remove='success',
        mount_tmp_dir=False,
    )
