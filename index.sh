#!/bin/bash
. utils.sh

TMP_BULK="/tmp/esBulk"

for f in $(find $* -iname '*.json' -exec realpath {} \;); do 
    image=$(echo "${f}" | sed -nre 's/.*\/(.+)-out\/(.*)\.json/\1/p')
    module=$(echo "${f}" | sed -nre 's/.*\/(.+)\.json/\1/p')

    echo ${profiles};
    exit;

    read -r -d '' JQ_FILTER <<EOF
    { "index" : { "_index" : "image", "_type" : "${module}"} },
    . + { "image" : "${image}", module: "${module}" }
EOF
    transformJSON "${f}" | jq -c "${JQ_FILTER}" > "${TMP_BULK}"
    if [[ -s "${TMP_BULK}" ]]; then
        curl -s -XPOST "http://localhost:9200/_bulk" --data-binary "@${TMP_BULK}" | jq .
    fi
done
