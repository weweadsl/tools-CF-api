#!/bin/bash

tempData=$( curl -X GET "https://api.cloudflare.com/client/v4/zones?page=1&per_page=100" \
     -H "X-Auth-Email: < email >" \
     -H "X-Auth-Key: < key >" \
     -H "Content-Type: application/json"  )

result=$(echo $tempData | jq '.result' )

for row in $(echo "${result}" | jq -r '.[] | @base64' ); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}

    }

    echo $(_jq '.name') "\t" $(_jq '.id') >> it-dns-list

done