FROM postgres:17.2-alpine

RUN apk add --no-cache \
    python3 \
    py3-pip \
    python3-dev \
    gcc \
    musl-dev \
    postgresql-dev \
    linux-headers \
    gettext \
    && rm -rf /var/cache/apk/*

COPY requirements.txt /requirements.txt
RUN pip3 install --no-cache-dir -r /requirements.txt --break-system-packages

RUN chmod 700 /var/lib/postgresql/data

COPY patroni.yml /patroni.yml

ENTRYPOINT ["patroni", "/patroni.yml"]
