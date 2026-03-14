FROM kukymbr/goose-docker:3.23.0

# Какую папку с миграциями копировать (user-service-db, order-service-db, logistics-service-db)
ARG SERVICE_DIR

COPY ${SERVICE_DIR}/migrations /migrations
