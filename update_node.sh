#!/usr/bin/env bash

RESULT_FILE=/tmp/result.txt
FILE_WITH_CSRF=/tmp/output.html
COOKIES_FILE=/tmp/cookies.txt

echo "Start updating..."

if [ -z "$1" ]; then
    echo "No argument supplied: pass the name of the node to refresh"
    exit 1
else
    MODULE_NAME="$1"
fi

# remove any previous cookies
if [ -f "${COOKIES_FILE}" ]; then
    rm "${COOKIES_FILE}"
fi

# get the _csrf token
curl -s \
    -c "${COOKIES_FILE}" \
    -b "${COOKIES_FILE}" \
    -XGET "https://flows.nodered.org/add/node" > ${FILE_WITH_CSRF}

input=$(cat ${FILE_WITH_CSRF})
CSRF_TOKEN=$(echo "${input}" | ./get_token.py)

if [[ ! -z "${CSRF_TOKEN}" ]]; then
    echo "_csrf token was found to be: $CSRF_TOKEN"
else
    echo "_csrf token not found in HTML!"
    exit 1
fi

# Send a node update request, with the _csrf token
curl -s \
    -XPOST "https://flows.nodered.org/add/node" \
    -c "${COOKIES_FILE}" \
    -b "${COOKIES_FILE}" \
    -H "referer: https://flows.nodered.org/add/node" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "x-requested-with: XMLHttpRequest" \
    -d "module=${MODULE_NAME}&_csrf=$CSRF_TOKEN" > ${RESULT_FILE}

# Show the add/node page' response
cat ${RESULT_FILE}