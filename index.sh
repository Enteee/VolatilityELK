#!/bin/bash
. utils.sh

ES="http://localhost:9200"
TMP_BULK="/tmp/esBulk"
TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%S%:z')

# Template
echo "Template"
curl -XPUT "${ES}/_template/template" -d '
{
    "template" : "*",
    "settings" : {
        "number_of_shards" : 10
    },
    "mappings" : {
        "_default_" : {
            "dynamic_templates" : [{
                    "notanalyzed" : {
                    "match" : "*", 
                    "match_mapping_type" : "string",
                  "mapping": {
                      "type" : "string",
                      "index" : "not_analyzed"
                  }
               }
            }],
            "properties": {
                "timestamp" : {
                    "type" : "date"
                }
            }
        }
    }
}
'
echo
echo "[ENTER]"
read

for f in $(find $* -iname '*.json' -exec realpath {} \;); do 
    image=$(echo "${f}" | sed -nre 's/.*\/(.+)-out\/(.*)\.json/\1/p')
    plugin=$(echo "${f}" | sed -nre 's/.*\/(.+)\.json/\1/p')

    read -r -d '' JQ_FILTER <<EOF
    { "index" : { "_index" : "${image}", "_type" : "${plugin}"} },
    { "timestamp" : "${TIMESTAMP}", "image" : "${image}", "plugin": "${plugin}" } + .
EOF
    cat ${f} |
    transformJSON "${plugin}" |
    jq -c "${JQ_FILTER}" > "${TMP_BULK}"

    if [[ -s "${TMP_BULK}" ]]; then
        curl -s -XPOST "${ES}/_bulk" --data-binary "@${TMP_BULK}" | jq .
    fi
done
