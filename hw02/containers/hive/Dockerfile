FROM apache/hive:4.0.0

USER root

ADD https://jdbc.postgresql.org/download/postgresql-42.7.1.jar /opt/hive/lib/postgresql-42.7.1.jar
ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.6/hadoop-aws-3.3.6.jar /opt/hive/lib/hadoop-aws-3.3.6.jar
ADD https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar /opt/hive/lib/aws-java-sdk-bundle-1.12.262.jar

RUN chmod 644 /opt/hive/lib/*.jar

RUN apt-get update && \
    apt-get install -y netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY hive-site.xml /opt/hive/conf/hive-site.xml
COPY core-site.xml /opt/hadoop/etc/hadoop/core-site.xml

# Create symlinks for Hadoop to find AWS JARs
RUN ln -s /opt/hive/lib/hadoop-aws-3.3.6.jar /opt/hadoop/share/hadoop/common/lib/hadoop-aws-3.3.6.jar && \
    ln -s /opt/hive/lib/aws-java-sdk-bundle-1.12.262.jar /opt/hadoop/share/hadoop/common/lib/aws-java-sdk-bundle-1.12.262.jar

USER hive
