#!/bin/bash
. utils.sh

ES="http://localhost:9200"
TMP_BULK="/tmp/esBulk"
TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%S%:z')

# Template
#curl -XPUT "${ES}/_template/template" -d '
#{
#    "template" : "*",
#    "settings" : {
#        "number_of_shards" : 10
#    },
#    "mappings" : {
#        "_default_" : {
#            "properties": {
#                "timestamp" : {
#                    "type" : "date"
#                }
#            }
#        }
#    }
#}
#'

for f in $(find $* -iname '*.json' -exec realpath {} \;); do 
    image=$(echo "${f}" | sed -nre 's/.*\/(.+)-out\/(.*)\.json/\1/p')
    module=$(echo "${f}" | sed -nre 's/.*\/(.+)\.json/\1/p')

    read -r -d '' JQ_FILTER <<EOF
    { "index" : { "_index" : "${image}", "_type" : "${module}"} },
    { "timestamp" : "${TIMESTAMP}", "image" : "${image}", "module": "${module}" } + .
EOF
    transformJSON "${f}" | jq -c "${JQ_FILTER}" > "${TMP_BULK}"
    if [[ -s "${TMP_BULK}" ]]; then
        curl -s -XPOST "${ES}/_bulk" --data-binary "@${TMP_BULK}" | jq .
    fi
done
