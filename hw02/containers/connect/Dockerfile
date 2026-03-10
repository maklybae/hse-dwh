ARG DEBEZIUM_VERSION=3.4

FROM quay.io/debezium/connect:${DEBEZIUM_VERSION}

ARG ICEBERG_SINK_VERSION=0.4.0

USER root

RUN curl -fSL \
        "https://github.com/getindata/kafka-connect-iceberg-sink/releases/download/${ICEBERG_SINK_VERSION}/kafka-connect-iceberg-sink-${ICEBERG_SINK_VERSION}-plugin.zip" \
        -o /tmp/iceberg-sink-plugin.zip \
    && unzip /tmp/iceberg-sink-plugin.zip -d /kafka/connect/ \
    && rm /tmp/iceberg-sink-plugin.zip

USER kafka
