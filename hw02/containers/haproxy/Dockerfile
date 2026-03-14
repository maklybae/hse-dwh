FROM haproxy:3.2.9-alpine

# Конфиг передаётся как build arg (имя файла из haproxy-configs/)
# Пример: --build-arg CONFIG_FILE=user-haproxy.cfg
ARG CONFIG_FILE

COPY haproxy-configs/${CONFIG_FILE} /usr/local/etc/haproxy/haproxy.cfg
