#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <config_file1> [config_file2] ..."
    exit 1
fi

for CONFIG_FILE in "$@"; do
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: File '$CONFIG_FILE' not found"
        continue
    fi
    
    echo "Creating connector from $CONFIG_FILE..."
    curl -i -X POST \
        -H "Accept:application/json" \
        -H "Content-Type:application/json" \
        "$BASE_URL/connectors/" \
        -d @"$CONFIG_FILE"
done
