#!/bin/bash

if [ -z "$BASE_URL" ]; then
    echo "Error: BASE_URL environment variable is not set"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 <namespace1> [namespace2] ..."
    exit 1
fi

HAS_ERRORS=0

for NAMESPACE in "$@"; do
    echo "Creating namespace '$NAMESPACE'..."
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        "$BASE_URL/v1/namespaces" \
        -d "{\"namespace\": [\"$NAMESPACE\"]}")

    CURL_EXIT=$?
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    echo "$BODY"

    if [ $CURL_EXIT -ne 0 ]; then
        echo "✗ Failed to create namespace '$NAMESPACE' (curl error: $CURL_EXIT)"
        HAS_ERRORS=1
    elif [ "$HTTP_CODE" -eq 409 ]; then
        echo "ℹ Namespace '$NAMESPACE' already exists (HTTP $HTTP_CODE)"
    elif [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
        echo "✓ Namespace '$NAMESPACE' created successfully (HTTP $HTTP_CODE)"
    else
        echo "✗ Failed to create namespace '$NAMESPACE' (HTTP $HTTP_CODE)"
        HAS_ERRORS=1
    fi
done

exit $HAS_ERRORS
