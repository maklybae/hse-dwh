FROM apache/spark:4.0.1

USER root

RUN pip install --no-cache-dir \
    kafka-python==2.0.2 \
    pyiceberg[s3fs,hive]==0.11.0

RUN cd /opt/spark/jars && \
    curl -O https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-4.0_2.13/1.10.1/iceberg-spark-runtime-4.0_2.13-1.10.1.jar && \
    curl -O https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.10.1/iceberg-aws-bundle-1.10.1.jar && \
    curl -O https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.4.1/hadoop-aws-3.4.1.jar

RUN mkdir -p /opt/spark/.ivy2/cache && chown -R spark:spark /opt/spark/.ivy2

USER spark

WORKDIR /opt/spark-apps
