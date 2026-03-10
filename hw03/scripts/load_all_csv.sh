#!/bin/bash

# Скрипт для массовой загрузки всех CSV файлов mock_data в соответствующие БД
#
# Использование:
#   ./load_all_csv.sh <mock_data_dir>
#
# Пример:
#   ./load_all_csv.sh ~/Downloads/mock_data

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOAD_CSV="$SCRIPT_DIR/load_csv.sh"

# Connection strings (статические)
USER_CONN="postgresql://postgres:postgres@localhost:5432/postgres"
ORDER_CONN="postgresql://postgres:postgres@localhost:5433/postgres"
LOGISTICS_CONN="postgresql://postgres:postgres@localhost:5434/postgres"

if [ $# -ne 1 ]; then
    echo "Использование: $0 <mock_data_dir>"
    exit 1
fi

MOCK_DATA_DIR="$1"

if [ ! -d "$MOCK_DATA_DIR" ]; then
    echo "✗ Ошибка: директория '$MOCK_DATA_DIR' не найдена" >&2
    exit 1
fi

if [ ! -f "$LOAD_CSV" ]; then
    echo "✗ Ошибка: load_csv.sh не найден по пути '$LOAD_CSV'" >&2
    exit 1
fi

SUCCESS=0
FAIL=0

load() {
    local csv_path="$1"
    local table_name="$2"
    local conn="$3"

    echo ""
    echo "==> $table_name ($csv_path)"
    if bash "$LOAD_CSV" "$csv_path" "$table_name" "$conn"; then
        SUCCESS=$((SUCCESS + 1))
    else
        FAIL=$((FAIL + 1))
    fi
}

for csv in "$MOCK_DATA_DIR"/*.csv; do
    [ -f "$csv" ] || continue

    filename="$(basename "$csv" .csv)"

    if [[ "$filename" == user_service_* ]]; then
        table=$(echo "${filename#user_service_}" | tr '[:lower:]' '[:upper:]')
        load "$csv" "$table" "$USER_CONN"

    elif [[ "$filename" == order_service_* ]]; then
        table=$(echo "${filename#order_service_}" | tr '[:lower:]' '[:upper:]')
        load "$csv" "$table" "$ORDER_CONN"

    elif [[ "$filename" == logistics_service_* ]]; then
        table=$(echo "${filename#logistics_service_}" | tr '[:lower:]' '[:upper:]')
        load "$csv" "$table" "$LOGISTICS_CONN"

    else
        echo "⚠ Пропущен неизвестный файл: $filename.csv"
    fi
done

echo ""
echo "============================================"
echo "Готово: успешно=$SUCCESS, ошибок=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
