#!/bin/bash

function transformJSON (){
    #from : http://stackoverflow.com/questions/28103489/create-object-from-array-of-keys-and-values
    read -r -d '' JQ_FILTER <<'EOF'
    .columns as $columns |
    .rows[] as $rows |
    reduce range(0; $columns|length) as $i ( {}; . + { ($columns[$i]): $rows[$i] })
EOF
    if [ $# -eq 0 ]; then
        jq "${JQ_FILTER}"
    else
        jq "${JQ_FILTER}" "$@"
    fi
}

