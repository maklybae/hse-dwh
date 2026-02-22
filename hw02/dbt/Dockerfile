FROM apache/spark:4.0.1

USER root

# Download Iceberg + S3 JARs (must match Spark cluster versions)
RUN cd /opt/spark/jars && \
    curl -fsSL -O https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-4.0_2.13/1.10.1/iceberg-spark-runtime-4.0_2.13-1.10.1.jar && \
    curl -fsSL -O https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.10.1/iceberg-aws-bundle-1.10.1.jar && \
    curl -fsSL -O https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.4.1/hadoop-aws-3.4.1.jar

# Install dbt-spark with session support; pin pyspark to match base image
RUN pip install --no-cache-dir \
    "dbt-core==1.11.6" \
    "dbt-spark[session]==1.10.1" \
    "pyspark==4.0.1"

# Project will be mounted at runtime — no COPY needed
RUN mkdir -p /dbt/project && chown spark:spark /dbt/project

USER spark

ENV SPARK_CONF_DIR=/opt/spark/conf

WORKDIR /dbt/project

# Entrypoint: run dbt deps if packages not yet installed, then exec dbt
COPY --chown=spark:spark entrypoint.sh /usr/local/bin/dbt-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/dbt-entrypoint.sh"]
CMD ["--help"]
