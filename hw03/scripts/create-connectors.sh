#!/bin/bash

if [ -z "$BASE_URL" ]; then
    echo "Error: BASE_URL environment variable is not set"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 <config_file1> [config_file2] ..."
    exit 1
fi

HAS_ERRORS=0

for CONFIG_FILE in "$@"; do
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: File '$CONFIG_FILE' not found"
        HAS_ERRORS=1
        continue
    fi
    
    echo "Creating connector from $CONFIG_FILE..."
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Accept:application/json" \
        -H "Content-Type:application/json" \
        "$BASE_URL/connectors/" \
        -d @"$CONFIG_FILE")
    
    CURL_EXIT=$?
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    echo "$BODY"
    
    if [ $CURL_EXIT -ne 0 ]; then
        echo "✗ Failed to create connector (curl error: $CURL_EXIT)"
        HAS_ERRORS=1
    elif [ "$HTTP_CODE" -eq 409 ]; then
        echo "ℹ Connector already exists (HTTP $HTTP_CODE)"
    elif [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
        echo "✓ Connector created successfully (HTTP $HTTP_CODE)"
    else
        echo "✗ Failed to create connector (HTTP $HTTP_CODE)"
        HAS_ERRORS=1
    fi
done

exit $HAS_ERRORS
done
