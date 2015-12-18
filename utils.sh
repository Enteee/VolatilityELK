#!/bin/bash

function transformJSON (){
    #from : http://stackoverflow.com/questions/28103489/create-object-from-array-of-keys-and-values
    if [ "${1}" ]; then
        plugin="${1}"
    fi
    jq "
    .columns as \$columns |
    .rows[] as \$rows |
    reduce range(0; \$columns|length) as \$i ( {}; . * { (\$columns[\$i]): \$rows[\$i] } * { ${plugin}: { (\$columns[\$i]): \$rows[\$i] }})
    "
}

