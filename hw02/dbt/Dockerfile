FROM apache/spark:4.0.1

USER root

# Download Iceberg + S3 JARs (same as dwh-spark)
RUN cd /opt/spark/jars && \
    curl -fsSL -O https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-4.0_2.13/1.10.1/iceberg-spark-runtime-4.0_2.13-1.10.1.jar && \
    curl -fsSL -O https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.10.1/iceberg-aws-bundle-1.10.1.jar && \
    curl -fsSL -O https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.4.1/hadoop-aws-3.4.1.jar

# Install dbt-spark with session support
# pyspark is already provided by the base apache/spark image
RUN pip install --no-cache-dir \
    "dbt-core==1.11.6" \
    "dbt-spark[session]==1.10.1"

# Copy dbt project into image and fix ownership for spark user
COPY marketplace /dbt/project
RUN chown -R spark:spark /dbt/project

USER spark

WORKDIR /dbt/project

# Download dbt packages (automate_dv, dbt_utils, etc.)
RUN dbt deps

ENTRYPOINT ["dbt"]
CMD ["--help"]
