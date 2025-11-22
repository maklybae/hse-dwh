#!/bin/bash

# NOTE(maklybae): Это вайбкод для удобства тестирования

# Скрипт для загрузки данных из CSV файла в PostgreSQL таблицу
#
# Использование:
#   ./load_csv.sh <csv_path> <table_name> <connection_string>
#
# Примеры:
#   ./load_csv.sh users.csv users "postgresql://postgres:postgres@localhost:5432/postgres"
#   ./load_csv.sh orders.csv orders "postgresql://postgres:postgres@localhost:5433/postgres"

# Проверка аргументов
if [ $# -ne 3 ]; then
    echo "Использование: $0 <csv_path> <table_name> <connection_string>"
    echo ""
    echo "Примеры:"
    echo "  $0 users.csv users \"postgresql://postgres:postgres@localhost:5432/postgres\""
    echo "  $0 orders.csv orders \"postgresql://postgres:postgres@localhost:5433/postgres\""
    exit 1
fi

CSV_PATH="$1"
TABLE_NAME="$2"
CONN_STRING="$3"

# Проверка существования файла
if [ ! -f "$CSV_PATH" ]; then
    echo "✗ Ошибка: файл '$CSV_PATH' не найден" >&2
    exit 1
fi

# Получаем список колонок из CSV (первая строка)
COLUMNS=$(head -n 1 "$CSV_PATH")

# Загрузка данных
echo "Подключение к базе данных..."
echo "Загрузка файла: $CSV_PATH"
echo "Колонки: $COLUMNS"

# Используем psql с командой \COPY, указывая колонки
psql "$CONN_STRING" <<EOF
\COPY $TABLE_NAME ($COLUMNS) FROM '$CSV_PATH' WITH (FORMAT csv, HEADER true, DELIMITER ',');
EOF

# Проверка результата
if [ $? -eq 0 ]; then
    ROW_COUNT=$(wc -l < "$CSV_PATH")
    ROW_COUNT=$((ROW_COUNT - 1))  # Минус заголовок
    echo "✓ Успешно загружено $ROW_COUNT строк в таблицу '$TABLE_NAME'"
else
    echo "✗ Ошибка при загрузке данных" >&2
    exit 1
fi
