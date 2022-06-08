#!/bin/bash

email=
key=

# 依照 DNSList 取得行數
numbers=`wc -l DNSList | awk  '{print $1}'`

# 逐一行處理
for (( n=0; n<=$numbers; n++ ))
do
  zoneid=`sed  -n "${n}p" DNSList | awk '{print $2}'`

  # 取得 main domain 下各個 subdomain
  tempData=$( curl -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records" \
     -H "X-Auth-Email: $email " \
     -H "X-Auth-Key: $key" \
     -H "Content-Type: application/json"  )

  result=$(echo $tempData | jq '.result' )

  # 依照每個 subdomain
  for row in $(echo "${result}" | jq -r '.[] | @base64' ); do
      _jq() {
          echo ${row} | base64 --decode | jq -r ${1}
      }

      # 修改成指定的 ip，這邊是 127.0.0.1
      return_res=$( curl -X PATCH  "https://api.cloudflare.com/client/v4/zones/$(_jq '.zone_id')/dns_records/$(_jq '.id')" \
        -H "X-Auth-Email: $email" \
        -H "X-Auth-Key: $key" \
        -H "Content-Type: application/json" \
        --data '{"content":"127.0.0.1"}' )

      echo $(_jq '.name') "\t" $(_jq '.id') "\t" $return_res >> records/$(_jq '.zone_name')

  done

done
